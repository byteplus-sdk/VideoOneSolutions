// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.ve;

import static com.bytedance.playerkit.player.Player.STATE_STOPPED;
import static com.bytedance.playerkit.player.Player.mapState;
import static com.bytedance.playerkit.player.source.Track.TRACK_TYPE_AUDIO;
import static com.bytedance.playerkit.player.source.Track.TRACK_TYPE_VIDEO;
import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_SCENE_SHORT_VIDEO;
import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_SCENE_SMALL_VIDEO;
import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_TYPE_PRELOAD;
import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_TYPE_PRE_RENDER;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Looper;
import android.text.TextUtils;
import android.util.SparseArray;
import android.view.Surface;
import android.view.SurfaceHolder;

import androidx.annotation.FloatRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.adapter.PlayerAdapter;
import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.playerkit.player.source.Quality;
import com.bytedance.playerkit.player.source.Subtitle;
import com.bytedance.playerkit.player.source.SubtitlePathInfo;
import com.bytedance.playerkit.player.source.SubtitleText;
import com.bytedance.playerkit.player.source.Track;
import com.bytedance.playerkit.player.source.TrackSelector;
import com.bytedance.playerkit.player.ve.utils.TTVideoEngineListenerAdapter;
import com.bytedance.playerkit.player.ve.utils.TTVideoEngineSubtitleCallbackAdapter;
import com.bytedance.playerkit.utils.Asserts;
import com.bytedance.playerkit.utils.L;
import com.google.gson.Gson;
import com.ss.ttm.player.PlaybackParams;
import com.ss.ttvideoengine.Resolution;
import com.ss.ttvideoengine.TTVideoEngine;
import com.ss.ttvideoengine.VideoEngineInfos;
import com.ss.ttvideoengine.model.IVideoModel;
import com.ss.ttvideoengine.model.VideoModel;
import com.ss.ttvideoengine.source.DirectUrlSource;
import com.ss.ttvideoengine.strategy.EngineStrategyListener;
import com.ss.ttvideoengine.strategy.StrategyManager;
import com.ss.ttvideoengine.strategy.source.StrategySource;
import com.ss.ttvideoengine.utils.Error;

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.WeakHashMap;

class VEPlayer implements PlayerAdapter {
    private final Context mContext;

    private TTVideoEngine mPlayer;
    private boolean mPreRenderPlayer;

    private final ListenerAdapter mListenerAdapter;
    private PlayerAdapter.Listener mListener;

    private Surface mSurface;
    private SurfaceHolder mSurfaceHolder;

    private boolean mStartWhenPrepared = true;
    private long mStartTime;
    private MediaSource mMediaSource;
    private StrategySource mStrategySource;

    @Player.PlayerState
    private int mState;
    private Exception mPlayerException;

    private boolean mPausedWhenChangeAVTrack;
    private long mPlaybackTimeWhenChangeAVTrack;
    private final PlaybackParams mPlaybackParams = new PlaybackParams();

    private final SparseArray<Track> mCurrentTrack = new SparseArray<>();
    private final SparseArray<Track> mPendingTrack = new SparseArray<>();

    public static String getDeviceId() {
        return TTVideoEngine.getDeviceID();
    }

    public static class Factory implements PlayerAdapter.Factory {
        private final Context mContext;
        private final MediaSource mMediaSource;


        public Factory(Context context, MediaSource mediaSource) {
            this.mContext = context;
            this.mMediaSource = mediaSource;
        }

        @Override
        public PlayerAdapter create(Looper eventLooper) {
            return new VEPlayer(mContext, mMediaSource);
        }
    }

    private static final class EngineParams {
        private final static WeakHashMap<TTVideoEngine, EngineParams> sPlayerParams = new WeakHashMap<>();

        private boolean mSuperResolutionInitialized;
        private int mVideoWidth;
        private int mVideoHeight;

        private synchronized static EngineParams get(TTVideoEngine engine) {
            EngineParams params = sPlayerParams.get(engine);
            if (params == null) {
                params = new EngineParams();
                sPlayerParams.put(engine, params);
            }
            return params;
        }

        private synchronized static EngineParams remove(TTVideoEngine engine) {
            return sPlayerParams.remove(engine);
        }
    }

    private static final List<MediaSource> sMediaSources = new ArrayList<>();

    private static MediaSource findMediaSource(StrategySource strategySource) {
        for (MediaSource mediaSource : sMediaSources) {
            if (TextUtils.equals(strategySource.vid(), mediaSource.getMediaId())) {
                return mediaSource;
            }
        }
        return null;
    }

    public static void setMediaSources(List<MediaSource> mediaSources) {
        if (mediaSources == null) return;

        sMediaSources.clear();
        sMediaSources.addAll(mediaSources);

        List<StrategySource> strategySources = Mapper.mediaSources2StrategySources(
                mediaSources,
                VEPlayerInit.getCacheKeyFactory(),
                VEPlayerInit.getTrackSelector(),
                TrackSelector.TYPE_PRELOAD);
        if (strategySources == null) return;
        TTVideoEngine.setStrategySources(strategySources);
    }

    public static void addMediaSources(List<MediaSource> mediaSources) {
        if (mediaSources == null) return;

        sMediaSources.addAll(mediaSources);

        List<StrategySource> strategySources = Mapper.mediaSources2StrategySources(
                mediaSources,
                VEPlayerInit.getCacheKeyFactory(),
                VEPlayerInit.getTrackSelector(),
                TrackSelector.TYPE_PRELOAD);
        if (strategySources == null) return;
        TTVideoEngine.addStrategySources(strategySources);
    }

    public static void renderFrame(MediaSource mediaSource, Surface surface, int[] frameInfo) {
        if (mediaSource == null) return;
        if (surface == null || !surface.isValid()) return;

        final TTVideoEngine player = get(mediaSource.getMediaId());
        if (player != null && player != StrategyManager.instance().getPlayEngine()) {
            player.setSurface(surface);
            player.forceDraw();
            frameInfo[0] = player.getVideoWidth();
            frameInfo[1] = player.getVideoHeight();
        }
    }

    public static void setSceneStrategyEnabled(int veScene) {
        final int engineScene = Mapper.mapVEScene2EngineScene(veScene);
        switch (engineScene) {
            case STRATEGY_SCENE_SMALL_VIDEO:
                TTVideoEngine.enableEngineStrategy(STRATEGY_TYPE_PRELOAD, STRATEGY_SCENE_SMALL_VIDEO);
                TTVideoEngine.enableEngineStrategy(STRATEGY_TYPE_PRE_RENDER, STRATEGY_SCENE_SMALL_VIDEO);
                break;
            case STRATEGY_SCENE_SHORT_VIDEO:
                TTVideoEngine.enableEngineStrategy(STRATEGY_TYPE_PRELOAD, STRATEGY_SCENE_SHORT_VIDEO);
                break;
        }
    }

    public static void clearSceneStrategy() {
        sMediaSources.clear();
        TTVideoEngine.clearAllStrategy();
    }

    private static TTVideoEngine get(String mediaId) {
        return TTVideoEngine.getPreRenderEngine(mediaId);
    }

    private static TTVideoEngine create(Context context, MediaSource mediaSource) {
        return TTVideoEngineFactory.Default.get().create(context, mediaSource);
    }


    private static void bind(TTVideoEngine player, MediaSource mediaSource) {
        if (mediaSource.getSourceType() == MediaSource.SOURCE_TYPE_ID) {
            player.setVideoInfoListener(new TTVideoEngineListenerAdapter() {
                @Override
                public boolean onFetchedVideoInfo(VideoModel videoModel) {
                    Mapper.updateMediaSource(mediaSource, videoModel);
                    @Track.TrackType
                    int trackType = mediaSource.getMediaType() == MediaSource.MEDIA_TYPE_AUDIO ? TRACK_TYPE_AUDIO : TRACK_TYPE_VIDEO;
                    List<Track> tracks = mediaSource.getTracks(trackType);
                    if (tracks != null) {
                        Track track = VEPlayerInit.getTrackSelector().selectTrack(TrackSelector.TYPE_PRELOAD, trackType, tracks, mediaSource);
                        if (track != null) {
                            Resolution resolution = Mapper.quality2Resolution(track.getQuality());
                            if (resolution != null) {
                                player.configResolution(resolution);
                            }
                        }
                    }
                    return false;
                }
            });
        }
    }

    static {
        TTVideoEngine.setEngineStrategyListener(new EngineStrategyListener() {
            @Override
            public TTVideoEngine createPreRenderEngine(StrategySource source) {
                final MediaSource mediaSource = findMediaSource(source);
                if (mediaSource == null) return null; // error

                Context context = VEPlayerInit.getContext();
                PlayerConfig playerConfig = PlayerConfig.get(mediaSource);

                final TTVideoEngine player = create(context, mediaSource);
                bind(player, mediaSource);
                setupSource(context, player, source, mediaSource.getHeaders(), playerConfig);
                return player;
            }
        });
    }

    private VEPlayer(final Context context, MediaSource mediaSource) {
        L.v(this, "constructor", "DEVICE_ID", TTVideoEngine.getDeviceID());
        mContext = context;

        mListenerAdapter = new ListenerAdapter(this);

        TTVideoEngine player = get(mediaSource.getMediaId());
        if (player == null) {
            player = create(mContext, mediaSource);
        } else {
            mPreRenderPlayer = true;
            mStartWhenPrepared = false;
        }
        bind(player);
        setState(Player.STATE_IDLE);
    }

    protected void bind(TTVideoEngine player) {
        player.setVideoEngineCallback(mListenerAdapter);
        player.setVideoEngineInfoListener(mListenerAdapter);
        player.setVideoInfoListener(mListenerAdapter);
        player.setPlayerEventListener(mListenerAdapter);
        player.setSubInfoCallBack(new TTVideoEngineSubtitleCallbackAdapter(mListenerAdapter));
        mPlayer = player;
    }

    protected void unbind() {
        final TTVideoEngine player = mPlayer;
        if (player == null) return;
        player.setVideoEngineCallback(null);
        player.setVideoEngineInfoListener(null);
        player.setVideoInfoListener(null);
        player.setPlayerEventListener(null);
        player.setSubInfoCallBack(null);
    }

    @Override
    public void setListener(Listener listener) {
        mListener = listener;
    }

    @Override
    public void setSurface(final Surface surface) {
        if (mSurface != surface) {
            mPlayer.setSurface(surface);
            mSurface = surface;
        } else if (surface != null) {
            refreshSurface();
        }
    }

    private void refreshSurface() {
        if (PlayerConfig.get(mMediaSource).enableTextureRender) {
            if (isInPlaybackState()) {
                mPlayer.forceDraw();
            }
        } else {
            mPlayer.setSurface(null);
            mPlayer.setSurface(mSurface);
        }
    }

    @Override
    public void setDisplay(SurfaceHolder display) {
        if (mSurfaceHolder != display) {
            mPlayer.setSurfaceHolder(display);
            mSurfaceHolder = display;
        }
    }

    @Override
    public void setVideoScalingMode(@Player.ScalingMode int mode) {
        final int scalingMode = Mapper.mapScalingMode(mode);
        mPlayer.setIntOption(TTVideoEngine.PLAYER_OPTION_IMAGE_LAYOUT, scalingMode);
    }

    @Override
    public void setDataSource(@NonNull MediaSource mediaSource) throws IOException {
        mMediaSource = mediaSource;
    }

    private void selectPlayTrack(@NonNull MediaSource mediaSource) {
        @Track.TrackType
        int trackType = mediaSource.getMediaType() == MediaSource.MEDIA_TYPE_AUDIO ? TRACK_TYPE_AUDIO : TRACK_TYPE_VIDEO;
        final List<Track> tracks = mediaSource.getTracks(trackType);
        if (tracks != null && !tracks.isEmpty()) {
            if (mListener != null) {
                mListener.onTrackInfoReady(this, trackType, tracks);
            }
            Track target = VEPlayerInit.getTrackSelector().selectTrack(TrackSelector.TYPE_PLAY, trackType, tracks, mediaSource);
            selectTrack(trackType, target);
        }
    }

    private static void setHeaders(TTVideoEngine player, @Nullable Map<String, String> headers) {
        if (headers != null) {
            for (Map.Entry<String, String> entry : headers.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();
                if (key != null && value != null) {
                    // compatible with ffmpeg
                    player.setCustomHeader(key, " " + value);
                }
            }
        }
    }

    @Override
    public boolean isSupportSmoothTrackSwitching(@Track.TrackType int trackType) {
        final MediaSource source = mMediaSource;
        if (mPlayer != null && source != null) {
            int contentType = source.getMediaProtocol();
            if (contentType == MediaSource.MEDIA_PROTOCOL_DASH) {
                IVideoModel videoModel = mPlayer.getIVideoModel();
                if (videoModel != null && videoModel.isSupportBash()) {
                    return PlayerConfig.get(mMediaSource).enableDash;
                }
            } else if (contentType == MediaSource.MEDIA_PROTOCOL_HLS) {
                IVideoModel videoModel = mPlayer.getIVideoModel();
                if (videoModel != null && videoModel.isSupportHLSSeamlessSwitch()) {
                    return PlayerConfig.get(mMediaSource).enableHlsSeamlessSwitch;
                }
            } else if (contentType == MediaSource.MEDIA_PROTOCOL_DEFAULT) {
                IVideoModel videoModel = mPlayer.getIVideoModel();
                if (videoModel != null && videoModel.isSupportBash()) {
                    return PlayerConfig.get(mMediaSource).enableMP4SeamlessSwitch;
                }
            }
        }
        return false;
    }

    @Override
    public void selectTrack(@Track.TrackType int trackType, @Nullable Track track) throws IllegalStateException {
        if (mState == Player.STATE_RELEASED || mState == Player.STATE_ERROR) return;

        final MediaSource source = mMediaSource;

        if (source == null) return;

        if (track == null) return; //TODO abr auto support

        final Track selected = getSelectedTrack(trackType);

        if (!Objects.equals(selected, track)) {

            setPendingTrack(trackType, track);

            if (mListener != null) {
                mListener.onTrackWillChange(this, trackType, selected, track);
            }

            if (selected == null) {
                // Select Track when playback start
                final int sourceType = source.getSourceType();
                switch (sourceType) {
                    case MediaSource.SOURCE_TYPE_ID: {
                        /**
                         * invoked in {@link ListenerAdapter#onFetchedVideoInfo(VideoModel)}
                         * -> {@link #selectPlayTrack(MediaSource, int)}
                         */
                        mPlayer.configResolution(Mapper.track2Resolution(track));
                        break;
                    }
                    case MediaSource.SOURCE_TYPE_URL: {
                        /**
                         * invoked in {@link #prepareAsync(MediaSource)}
                         * -> {@link #selectPlayTrack(MediaSource)}
                         */
                        prepareDirectUrl(source, track);
                        break;
                    }
                    case MediaSource.SOURCE_TYPE_MODEL:
                        /**
                         * invoked in {@link #prepareAsync(MediaSource)}
                         * -> {@link #selectPlayTrack(MediaSource)}
                         */
                        prepareVideoModel(source, track);
                        break;
                }
            } else {
                // Select Track during playback
                if (isInPlaybackState()) {
                    mPausedWhenChangeAVTrack = mState == Player.STATE_PAUSED;
                    mPlaybackTimeWhenChangeAVTrack = mState == Player.STATE_COMPLETED ? 0 : mPlayer.getCurrentPlaybackTime();
                } else {
                    mPlaybackTimeWhenChangeAVTrack = mStartTime;
                }

                final int sourceType = source.getSourceType();
                switch (sourceType) {
                    case MediaSource.SOURCE_TYPE_ID:
                    case MediaSource.SOURCE_TYPE_MODEL: {
                        Resolution resolution = Mapper.track2Resolution(track);
                        if (resolution == null) return;

                        if (!isSupportSmoothTrackSwitching(trackType)) {
                            setState(Player.STATE_PREPARING);
                        }

                        // for VID/VideoModel TTVideoEngine will take care of startTime sync after
                        // resolution change

                        // mPlayer.setStartTime((int) mPlaybackTimeWhenChangeAVTrack);
                        mPlayer.configResolution(resolution);
                        break;
                    }
                    case MediaSource.SOURCE_TYPE_URL: {
                        if (Mapper.isDirectUrlSeamlessSwitchEnabled(source) && mPlayer.getIVideoModel() != null) {
                            Resolution resolution = Mapper.track2Resolution(track);
                            if (resolution == null) return;

                            // for video model TTVideoEngine will take care of startTime sync after
                            // resolution change

                            // mPlayer.setStartTime((int) mPlaybackTimeWhenChangeAVTrack);
                            mPlayer.configResolution(resolution);
                        } else {
                            if (mState != Player.STATE_IDLE) {
                                stop();
                            }

                            TTVideoEngine player = mPlayer;

                            bind(player);

                            player.setSurface(mSurface);

                            setState(Player.STATE_PREPARING);

                            if (mPlaybackTimeWhenChangeAVTrack > 0) {
                                player.setStartTime((int) mPlaybackTimeWhenChangeAVTrack);
                            }

                            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_START_AUTOMATICALLY, mPausedWhenChangeAVTrack ? 0 : 1);

                            prepareDirectUrl(source, track);
                        }
                        break;
                    }
                }
            }
        }
    }

    @Override
    public Track getPendingTrack(@Track.TrackType int trackType) throws IllegalStateException {
        return mPendingTrack.get(trackType);
    }

    private Track removePendingTrack(@Track.TrackType int type) {
        final Track track = mPendingTrack.get(type);
        if (track != null) {
            mPendingTrack.remove(type);
        }
        return track;
    }

    private void setPendingTrack(@Track.TrackType int type, Track track) {
        mPendingTrack.put(type, track);
    }

    private void setCurrentTrack(@Track.TrackType int type, Track track) {
        this.mCurrentTrack.put(type, track);
    }

    @Override
    public Track getCurrentTrack(@Track.TrackType int trackType) throws IllegalStateException {
        return mCurrentTrack.get(trackType);
    }

    private Track getSelectedTrack(@Track.TrackType int trackType) throws IllegalStateException {
        final Track current = getCurrentTrack(trackType);
        final Track pending = getPendingTrack(trackType);
        return pending == null ? current : pending;
    }

    @Override
    public List<Track> getTracks(@Track.TrackType int trackType) throws IllegalStateException {
        return mMediaSource.getTracks(trackType);
    }

    @Override
    public void prepareAsync() throws IllegalStateException {
        setState(Player.STATE_PREPARING);

        final MediaSource mediaSource = mMediaSource;
        if (mediaSource == null) {
            throw new IllegalStateException("You should invoke VEPlayer#setDataSource(MediaSource) method first!", new NullPointerException("source == null"));
        }

        if (mPreRenderPlayer) {
            syncPreRenderState(mediaSource);
        } else {
            prepareAsync(mediaSource);
        }
    }

    private void syncPreRenderState(MediaSource mediaSource) {
        @MediaSource.SourceType final int sourceType = mediaSource.getSourceType();
        @Track.TrackType int trackType = mediaSource.getMediaType() == MediaSource.MEDIA_TYPE_AUDIO
                ? TRACK_TYPE_AUDIO : TRACK_TYPE_VIDEO;
        if (sourceType == MediaSource.SOURCE_TYPE_ID || sourceType == MediaSource.SOURCE_TYPE_MODEL) {
            IVideoModel videoModel = mPlayer.getIVideoModel();
            if (videoModel != null) {
                Mapper.updateMediaSource(mediaSource, videoModel);
            }
            if (mListener != null) {
                mListener.onSourceInfoLoadComplete(this, SourceLoadInfo.SOURCE_INFO_PLAY_INFO_FETCHED, mediaSource);
            }
        }

        final List<Track> tracks = mediaSource.getTracks(trackType);
        if (tracks != null && !tracks.isEmpty()) {

            if (mListener != null) {
                mListener.onTrackInfoReady(this, trackType, tracks);
            }
            if (trackType == TRACK_TYPE_VIDEO) {
                Track track = null;
                switch (sourceType) {
                    case MediaSource.SOURCE_TYPE_ID:
                    case MediaSource.SOURCE_TYPE_MODEL: {
                        Resolution resolution = mPlayer.getCurrentResolution();
                        if (resolution != null) {
                            track = Mapper.findTrackWithResolution(tracks, resolution);
                        }
                        break;
                    }
                    case MediaSource.SOURCE_TYPE_URL: {
                        if (mPlayer.getIVideoModel() != null) {
                            Resolution resolution = mPlayer.getCurrentResolution();
                            if (resolution != null) {
                                track = Mapper.findTrackWithResolution(tracks, resolution);
                            }
                        } else {
                            DirectUrlSource directUrlSource = (DirectUrlSource) mPlayer.getStrategySource();
                            if (directUrlSource != null) {
                                track = Mapper.findTrackWithDirectUrlSource(mediaSource, tracks, directUrlSource, VEPlayerInit.getCacheKeyFactory());
                            }
                        }
                        break;
                    }
                }

                if (track == null) return; // TODO throw error

                setPendingTrack(trackType, track);

                if (mListener != null) {
                    mListener.onTrackWillChange(this, trackType, getCurrentTrack(trackType), track);
                }
            } else {
                throw new IllegalArgumentException("Only support video track for now. " + Track.mapTrackType(trackType));
            }
        }

        final Track current = getCurrentTrack(trackType);
        final Track pending = removePendingTrack(trackType);

        if (pending != null) {
            String fileHash = VEPlayerInit.getCacheKeyFactory().generateCacheKey(mMediaSource, pending);
            if (fileHash != null) {
                long cachedSize = TTVideoEngine.quickGetCacheFileSize(fileHash);
                if (mListener != null) {
                    mListener.onCacheHint(this, cachedSize);
                }
            }
            setCurrentTrack(trackType, pending);
            if (mListener != null) {
                mListener.onTrackChanged(this, trackType, current, pending);
                setState(Player.STATE_PREPARED);
                mListener.onPrepared(this);
                mListener.onVideoSizeChanged(this, mPlayer.getVideoWidth(), mPlayer.getVideoHeight());
            }
        }
    }

    private void prepareAsync(MediaSource mediaSource) {
        @MediaSource.SourceType final int sourceType = mediaSource.getSourceType();
        switch (sourceType) {
            case MediaSource.SOURCE_TYPE_ID:
                prepareVid(mediaSource);
                break;
            case MediaSource.SOURCE_TYPE_MODEL:
                Mapper.updateVideoModelMediaSource(mediaSource);
                selectPlayTrack(mediaSource);
                break;
            case MediaSource.SOURCE_TYPE_URL:
                selectPlayTrack(mediaSource);
                break;
            default:
                throw new IllegalArgumentException("unsupported sourceType " + sourceType);
        }
    }

    private void prepareVid(MediaSource mediaSource) {
        StrategySource strategySource = Mapper.mediaSource2VidPlayAuthTokenSource(mediaSource, null);
        Map<String, String> headers = mediaSource.getHeaders();
        PlayerConfig playerConfig = PlayerConfig.get(mediaSource);
        if (!TextUtils.isEmpty(mediaSource.getSubtitleAuthToken())) {
            mPlayer.setSubAuthToken(mediaSource.getSubtitleAuthToken());
        }
        preparePlayer(strategySource, headers, playerConfig);
    }

    private void prepareDirectUrl(MediaSource mediaSource, Track track) {
        Map<String, String> headers = track.getHeaders() == null ? mediaSource.getHeaders() : track.getHeaders();
        PlayerConfig playerConfig = PlayerConfig.get(mediaSource);

        final StrategySource strategySource;
        if (Mapper.isDirectUrlSeamlessSwitchEnabled(mediaSource)) {
            strategySource = Mapper.mediaSource2VideoModelSource(
                    mediaSource,
                    track,
                    VEPlayerInit.getCacheKeyFactory()
            );
        } else {
            strategySource = Mapper.mediaSource2DirectUrlSource(
                    mediaSource,
                    track,
                    VEPlayerInit.getCacheKeyFactory());
        }
        preparePlayer(strategySource, headers, playerConfig);
    }

    private void prepareVideoModel(MediaSource mediaSource, Track track) {
        Map<String, String> headers = track.getHeaders() == null ? mediaSource.getHeaders() : track.getHeaders();
        PlayerConfig playerConfig = PlayerConfig.get(mediaSource);
        StrategySource strategySource = Mapper.mediaSource2VideoModelSource(
                mediaSource,
                track,
                VEPlayerInit.getCacheKeyFactory()
        );
        if (!TextUtils.isEmpty(mediaSource.getSubtitleAuthToken())) {
            mPlayer.setSubAuthToken(mediaSource.getSubtitleAuthToken());
        }
        preparePlayer(strategySource, headers, playerConfig);
    }

    private void preparePlayer(StrategySource source,
                               Map<String, String> headers,
                               PlayerConfig config) {
        mStrategySource = source;
        setupSource(mContext, mPlayer, source, headers, config);
        mPlayer.play();
    }

    private static void setupSource(Context context,
                                    TTVideoEngine player,
                                    StrategySource source,
                                    Map<String, String> headers,
                                    PlayerConfig config) {
        player.setStrategySource(source);
        setHeaders(player, headers);

        if (config.enableSuperResolutionAbility) {
            initSuperResolution(context, player, config.enableSuperResolution);
        }
    }

    @Override
    public void start() {
        Asserts.checkState(mState, Player.STATE_PREPARED, Player.STATE_STARTED,
                Player.STATE_PAUSED, Player.STATE_COMPLETED);

        if (mState == Player.STATE_STARTED) {
            return;
        }

        if (mState == Player.STATE_PREPARED) {
            if (!mStartWhenPrepared || mPreRenderPlayer) {
                L.d(this, "start");
                mPlayer.play();
            }
        } else {
            L.d(this, "start");
            mPlayer.play();
        }
        setState(Player.STATE_STARTED);
    }

    @Override
    public boolean isPlaying() {
        return mState == Player.STATE_STARTED;
    }

    @Override
    public void pause() {
        Asserts.checkState(getState(), Player.STATE_PREPARING, Player.STATE_PREPARED, Player.STATE_STARTED,
                Player.STATE_PAUSED, Player.STATE_COMPLETED);

        if (mState == Player.STATE_PAUSED) return;

        mPlayer.pause();
        setState(Player.STATE_PAUSED);
    }

    @Override
    public void stop() {
        Asserts.checkState(getState(), Player.STATE_PREPARING, Player.STATE_PREPARED,
                Player.STATE_STARTED, Player.STATE_PAUSED, Player.STATE_COMPLETED, Player.STATE_STOPPED);

        if (mState == STATE_STOPPED) return;

        mPlayer.stop();
        setState(Player.STATE_STOPPED);
    }

    @Override
    public void setStartTime(long startTime) {
        mStartTime = startTime;
        if (!mPreRenderPlayer) {
            mPlayer.setStartTime((int) startTime);
        }
    }

    @Override
    public void setStartWhenPrepared(boolean startWhenPrepared) {
        if (mStartWhenPrepared != startWhenPrepared) {
            mStartWhenPrepared = startWhenPrepared;
            mPlayer.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_START_AUTOMATICALLY, startWhenPrepared ? 1 : 0);
        }
    }

    @Override
    public boolean isStartWhenPrepared() {
        return mStartWhenPrepared;
    }

    @Override
    public long getStartTime() {
        return mStartTime;
    }

    @Override
    public void seekTo(final long seekTo) {
        mPlayer.seekTo((int) seekTo, mListenerAdapter);
    }

    @Override
    public void reset() {
        L.e(this, "reset", "unsupported reset method, stop instead");
        resetInner();
        mPlayer.stop();
        setState(Player.STATE_IDLE);
    }

    private void resetInner() {
        mPreRenderPlayer = false;
        mSurface = null;
        mSurfaceHolder = null;
        mStartTime = 0L;
        mPausedWhenChangeAVTrack = false;
        mPlaybackTimeWhenChangeAVTrack = 0L;
        mMediaSource = null;
        mStrategySource = null;
        mCurrentTrack.clear();
        mPendingTrack.clear();
        mPlaybackParams.setPitch(1f);
        mPlaybackParams.setSpeed(1f);
        mListener = null;
        mPlayerException = null;
        mStartWhenPrepared = true;
        EngineParams.remove(mPlayer);
    }

    @Override
    public void release() {
        if (mState == Player.STATE_RELEASED) {
            return;
        }
        mPlayer.setIsMute(true);
        resetInner();
        mPlayer.releaseAsync();
        unbind();
        setState(Player.STATE_RELEASED);
    }

    @Override
    public long getDuration() {
        if (isInPlaybackState()) {
            return Math.max(0, mPlayer.getDuration());
        }
        return 0L;
    }

    @Override
    public long getCurrentPosition() {
        if (isInPlaybackState()) {
            return Math.max(0, mPlayer.getCurrentPlaybackTime());
        }
        return 0L;
    }

    @Override
    public int getBufferedPercentage() {
        return mPlayer.getLoadedProgress();
    }

    @Override
    public long getBufferedDuration() {
        long videoBufferedDuration = getBufferedDuration(TRACK_TYPE_VIDEO);
        long audioBufferedDuration = getBufferedDuration(TRACK_TYPE_AUDIO);
        return Math.min(videoBufferedDuration, audioBufferedDuration);
    }

    @Override
    public long getBufferedDuration(@Track.TrackType int trackType) {
        switch (trackType) {
            case TRACK_TYPE_AUDIO:
                return mPlayer.getLongOption(TTVideoEngine.PLAYER_OPTION_GET_AUDIO_CACHE_DURATION);
            case TRACK_TYPE_VIDEO:
                return mPlayer.getLongOption(TTVideoEngine.PLAYER_OPTION_GET_VIDEO_CACHE_DURATION);
            case Track.TRACK_TYPE_UNKNOWN:
                return 0L;
            default:
                throw new IllegalArgumentException("Unsupported trackType " + trackType);
        }
    }

    @Override
    public int getVideoWidth() {
        if (isSupportSmoothTrackSwitching(TRACK_TYPE_VIDEO)) {
            // Opt video TTVideoEngine#getVideoWidth/Height is not change after resolution changed
            // when using seamless video switching
            final EngineParams params = EngineParams.get(mPlayer);
            if (params.mVideoWidth > 0) {
                return params.mVideoWidth;
            }
        }
        return mPlayer.getVideoWidth();
    }

    @Override
    public int getVideoHeight() {
        if (isSupportSmoothTrackSwitching(TRACK_TYPE_VIDEO)) {
            // Opt video TTVideoEngine#getVideoWidth/Height is not change after resolution changed
            // when using seamless video switching
            final EngineParams params = EngineParams.get(mPlayer);
            if (params.mVideoHeight > 0) {
                return params.mVideoHeight;
            }
        }
        return mPlayer.getVideoHeight();
    }

    @Override
    public void setLooping(final boolean looping) {
        mPlayer.setLooping(looping);
    }

    @Override
    public boolean isLooping() {
        return mPlayer.isLooping();
    }

    private final float[] mVolume = new float[]{1f, 1f};

    @Override
    public void setVolume(float leftVolume, float rightVolume) {
        float left;
        float right;
        if (PlayerConfig.get(mMediaSource).enableAudioTrackVolume) {
            left = leftVolume;
            right = rightVolume;
        } else {
            float maxVolume = mPlayer.getMaxVolume();
            left = maxVolume * leftVolume;
            right = maxVolume * rightVolume;
        }
        mPlayer.setVolume(left, right);
        mVolume[0] = left;
        mVolume[1] = right;
    }

    @Override
    public float[] getVolume() {
        if (!PlayerConfig.get(mMediaSource).enableAudioTrackVolume) {
            float maxVolume = mPlayer.getMaxVolume();
            float volume = mPlayer.getVolume();
            if (volume >= 0 && volume <= maxVolume) {
                volume = volume / maxVolume;
            }
            mVolume[0] = volume;
            mVolume[1] = volume;
        }
        return mVolume;
    }

    @Override
    public void setMuted(boolean muted) {
        mPlayer.setIsMute(muted);
    }

    @Override
    public boolean isMuted() {
        return mPlayer.isMute();
    }

    @Override
    public void setSpeed(@FloatRange(from = 0.0, fromInclusive = false, to = 3.0) float speed) {
        mPlaybackParams.setSpeed(speed);
        mPlayer.setPlaybackParams(mPlaybackParams);
    }

    @Override
    public float getSpeed() {
        float speed = mPlaybackParams.getSpeed();
        return speed == -1f ? 1f : speed;
    }

    @Override
    public void setAudioPitch(float audioPitch) {
        mPlaybackParams.setPitch(audioPitch);
        mPlayer.setPlaybackParams(mPlaybackParams);
    }

    @Override
    public float getAudioPitch() {
        return mPlaybackParams.getPitch();
    }

    @Override
    public void setAudioSessionId(int audioSessionId) {
        mPlayer.setIntOption(TTVideoEngine.PLAYER_OPTION_AUDIOTRACK_SESSIONID, audioSessionId);
    }

    @Override
    public int getAudioSessionId() {
        return mPlayer.getIntOption(TTVideoEngine.PLAYER_OPTION_AUDIOTRACK_SESSIONID);
    }

    @Override
    public void setSuperResolutionEnabled(boolean enabled) {
        if (EngineParams.get(mPlayer).mSuperResolutionInitialized) {
            mPlayer.openTextureSR(true, enabled);
            if (isInPlaybackState() && !isPlaying()) {
                mPlayer.forceDraw();
            }
        }
    }

    private static void initSuperResolution(Context context, TTVideoEngine player, boolean enabled) {
        if (!EngineParams.get(player).mSuperResolutionInitialized) {
            File file = new File(context.getFilesDir(), "bytedance/playerkit/bmf");
            if (!file.exists()) {
                file.mkdirs();
            }
            player.asyncInitSR(false);
            player.dynamicControlSR(true);
            player.setSRInitConfig(5, file.getAbsolutePath(), "SR", "SR", 2, 0, 0);
            player.ignoreSRResolutionLimit(true);
            EngineParams.get(player).mSuperResolutionInitialized = true;
        }
        player.openTextureSR(true, enabled);
    }

    @Override
    public boolean isSuperResolutionEnabled() {
        return mPlayer != null && EngineParams.get(mPlayer).mSuperResolutionInitialized && mPlayer.isplaybackUsedSR();
    }

    @Override
    public void setSubtitleEnabled(boolean enabled) {
        if (enabled == isSubtitleEnabled()) {
            return;
        }
        TTVideoEngine player = mPlayer;
        if (player != null) {
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_OPEN_SUB, enabled ? 1 : 0);
        }
        Listener listener = mListener;
        if (listener == null) return;
        listener.onSubtitleStateChanged(this, enabled);
    }

    @Override
    public boolean isSubtitleEnabled() {
        TTVideoEngine player = mPlayer;
        return player != null && player.getIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_OPEN_SUB) == 1;
    }

    @Override
    public void selectSubtitle(Subtitle subtitle) {
        MediaSource mediaSource = mMediaSource;
        TTVideoEngine player = mPlayer;
        if (mediaSource == null || player == null || subtitle == null) {
            return;
        }
        mediaSource.setSubtitle(subtitle);
        player.setIntOption(TTVideoEngine.PLAYER_OPTION_SWITCH_SUB_ID, subtitle.subtitleId);
        Listener listener = mListener;
        if (listener == null) return;
        listener.onSubtitleChanged(this, subtitle);
    }

    @Override
    public Subtitle getSelectedSubtitle() {
        MediaSource mediaSource = mMediaSource;
        return mediaSource == null ? null : mediaSource.getSubtitle();
    }

    @Override
    public List<Subtitle> getSupportSubtitles() {
        MediaSource mediaSource = mMediaSource;
        return mediaSource == null ? null : mediaSource.getSubtitles();
    }

    @Override
    public String dump() {
        return L.obj2String(this)
                + " " + resolvePlayerDecoderType(mPlayer)
                + " " + resolvePlayerCoreType(mPlayer)
                + (mPreRenderPlayer ? " pre" : "");
    }

    @SuppressLint("SwitchIntDef")
    private boolean isInPlaybackState() {
        synchronized (this) {
            switch (mState) {
                case Player.STATE_PREPARED:
                case Player.STATE_STARTED:
                case Player.STATE_PAUSED:
                case Player.STATE_COMPLETED:
                    return true;
                default:
                    return false;
            }
        }
    }


    @Player.PlayerState
    private int getState() {
        synchronized (this) {
            return mState;
        }
    }

    private void setState(@Player.PlayerState int newState) {
        int state;
        synchronized (this) {
            state = this.mState;
            this.mState = newState;
        }
        L.d(this, "setState", mapState(state), mapState(newState));
    }

    private void moveToErrorState(int code, Exception e) {
        L.e(this, "moveToErrorState", e, code);
        mPlayerException = e;
        setState(Player.STATE_ERROR);
        if (mListener != null) {
            mListener.onError(this, code, String.valueOf(e));
        }
    }

    private static class ListenerAdapter extends TTVideoEngineListenerAdapter {

        private final WeakReference<VEPlayer> mPlayerRef;
        private final Gson mGson = new Gson();

        ListenerAdapter(VEPlayer player) {
            this.mPlayerRef = new WeakReference<>(player);
        }

        @Override
        public void onPrepared(final TTVideoEngine engine) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;

            Listener listener = player.mListener;
            if (listener == null) return;

            MediaSource source = player.mMediaSource;
            if (source == null) return;

            if (player.mState != Player.STATE_PREPARING) return;

            player.setState(Player.STATE_PREPARED);

            String enginePlayerType = resolvePlayerCoreType(engine);
            L.v(player, "onPrepared", "enginePlayerType", engine, enginePlayerType);

            @MediaSource.SourceType final int sourceType = source.getSourceType();
            @MediaSource.MediaType final int mediaType = source.getMediaType();
            @Track.TrackType final int trackType = mediaType == MediaSource.MEDIA_TYPE_AUDIO ? TRACK_TYPE_AUDIO : TRACK_TYPE_VIDEO;

            //TODO dash abr
            final Track current = player.getCurrentTrack(trackType);
            final Track pending = player.removePendingTrack(trackType);

            if (pending != null) {
                player.setCurrentTrack(trackType, pending);
                listener.onTrackChanged(player, trackType, current, pending);
            }

            if (player.isSupportSmoothTrackSwitching(trackType)) {
                listener.onPrepared(player);
            } else {
                if (current == null) {
                    listener.onPrepared(player);
                } else {
                    if (player.mPausedWhenChangeAVTrack) {
                        player.mPausedWhenChangeAVTrack = false;
                        player.setState(Player.STATE_PAUSED);
                    } else {
                        player.start();
                    }
                }
            }
        }

        @Override
        public void onBufferStart(final int reason, final int afterFirstFrame, final int action) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onInfo(player, PlayerAdapter.Info.MEDIA_INFO_BUFFERING_START, 0);
        }

        @Override
        public void onBufferEnd(final int code) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onInfo(player, PlayerAdapter.Info.MEDIA_INFO_BUFFERING_END, 0);
        }

        @Override
        public void onBufferingUpdate(final TTVideoEngine engine, final int percent) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onBufferingUpdate(player, percent);
        }

        @Override
        public void onCompletion(final TTVideoEngine engine) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            player.setState(Player.STATE_COMPLETED);
            listener.onCompletion(player);
        }

        @Override
        public void onError(final Error error) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            player.moveToErrorState(error.code, new Exception(error.toString()));
        }

        @Override
        public void onRenderStart(final TTVideoEngine engine) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onInfo(player, PlayerAdapter.Info.MEDIA_INFO_VIDEO_RENDERING_START, 0/*TODO*/);
        }

        @Override
        public void onReadyForDisplay(TTVideoEngine engine) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onInfo(player, Info.MEDIA_INFO_VIDEO_RENDERING_START_BEFORE_START, 0/*TODO*/);
        }

        @Override
        public void onVideoSizeChanged(final TTVideoEngine engine, final int width, final int height) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            EngineParams params = EngineParams.get(player.mPlayer);
            params.mVideoWidth = width;
            params.mVideoHeight = height;

            listener.onVideoSizeChanged(player, width, height);
        }

        @Override
        public void onSARChanged(int num, int den) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onSARChanged(player, num, den);
        }

        @Override
        public void onVideoStreamBitrateChanged(Resolution resolution, int bitrate) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            Track current = player.getCurrentTrack(TRACK_TYPE_VIDEO);
            Track track = player.getPendingTrack(TRACK_TYPE_VIDEO);

            final Quality quality = Mapper.resolution2Quality(resolution);

            if (track != null && Objects.equals(track.getQuality(), quality)) {
                player.removePendingTrack(TRACK_TYPE_VIDEO);
                player.setCurrentTrack(TRACK_TYPE_VIDEO, track);
                listener.onTrackChanged(player, TRACK_TYPE_VIDEO, current, track);
            }
        }

        @Override
        public boolean onFetchedVideoInfo(VideoModel videoModel) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return false;
            Listener listener = player.mListener;
            if (listener == null) return false;

            // NOTE: fix onFetchedVideoInfo callback multi times
            if (player.isInPlaybackState()) return false;

            MediaSource source = player.mMediaSource;
            if (source == null) return false;

            Mapper.updateMediaSource(source, videoModel);

            listener.onSourceInfoLoadComplete(player, SourceLoadInfo.SOURCE_INFO_PLAY_INFO_FETCHED, source);

            player.selectPlayTrack(source);
            return false;
        }

        @Override
        public void onVideoEngineInfos(VideoEngineInfos videoEngineInfos) {
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            switch (videoEngineInfos.getKey()) {
                case VideoEngineInfos.USING_RENDER_SEEK_COMPLETE:
                    listener.onSeekComplete(player);
                    return;
                case VideoEngineInfos.USING_MDL_HIT_CACHE_SIZE:
                    String taskKey = videoEngineInfos.getUsingMDLPlayTaskKey();
                    long hitCacheSize = videoEngineInfos.getUsingMDLHitCacheSize();
                    listener.onCacheHint(player, hitCacheSize);
                    return;
                case VideoEngineInfos.USING_MDL_CACHE_END:
                    return;
            }
        }


        @Override
        public void onAudioRenderOpened(int renderType, long start, long end) {
            final VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onInfo(player, Info.MEDIA_INFO_AUDIO_RENDERING_START, 0);
        }

        @Override
        public void onCurrentPlaybackTimeUpdate(TTVideoEngine engine, int currentPlaybackTime) {
            final VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;

            listener.onProgressUpdate(player, currentPlaybackTime);
        }

        @Override
        public void onSubPathInfo(String subPathInfo, Error error) {
            super.onSubPathInfo(subPathInfo, error);
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;
            SubtitlePathInfo subtitlePathInfo = mGson.fromJson(subPathInfo, SubtitlePathInfo.class);
            L.d(this, "onSubPathInfo Error :  " + error + " ,info : " + subPathInfo);
            if (subtitlePathInfo == null || subtitlePathInfo.list == null || subtitlePathInfo.list.isEmpty()) {
                listener.onSubtitleInfoReady(player, null);
                return;
            }
            Subtitle lastSubtitle = null;
            if (player.mMediaSource != null) {
                lastSubtitle = player.mMediaSource.getSubtitle();
                player.mMediaSource.setSubtitles(subtitlePathInfo.list);
            }
            listener.onSubtitleInfoReady(player, subtitlePathInfo.list);
            Subtitle selectSubtitle = null;
            for (Subtitle subtitle : subtitlePathInfo.list) {
                if (lastSubtitle != null && lastSubtitle.subtitleId == subtitle.subtitleId) {
                    selectSubtitle = subtitle;
                    break;
                }
                if ("ASR".equals(subtitle.source) && selectSubtitle == null) {
                    selectSubtitle = subtitle;
                }
            }
            player.selectSubtitle(selectSubtitle);
        }

        @Override
        public void onSubInfoCallback(int code, String info) {
            super.onSubInfoCallback(code, info);
            // info {"duration":1980,"info":"can i help you","pts":10120}
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;
            SubtitleText subtitleText = mGson.fromJson(info, SubtitleText.class);
            listener.onSubtitleTextUpdate(player, subtitleText);
        }

        @Override
        public void onSubLoadFinished2(int success, String info) {
            super.onSubLoadFinished2(success, info);
            VEPlayer player = mPlayerRef.get();
            if (player == null) return;
            Listener listener = player.mListener;
            if (listener == null) return;
            listener.onSubtitleFileLoadFinish(player, success, info);
        }
    }

    private static String resolvePlayerDecoderType(TTVideoEngine engine) {
        if (engine == null) return "unknown";
        int videoCodecType = engine.getIntOption(TTVideoEngine.PLAYER_OPTION_GET_VIDEO_CODEC_TYPE);
        if (videoCodecType == TTVideoEngine.PLAY_CODEC_NAME_AN_HW) {
            return "hw";
        } else {
            return "sw";
        }
    }

    @NonNull
    private static String resolvePlayerCoreType(TTVideoEngine engine) {
        String enginePlayerType = "";
        if (engine != null) {
            if (engine.isPlayerType(TTVideoEngine.PLAYER_TYPE_EXO)) {
                enginePlayerType = "exo";
            } else if (engine.isPlayerType(TTVideoEngine.PLAYER_TYPE_OWN)) {
                enginePlayerType = "own";
            } else if (engine.isPlayerType(TTVideoEngine.PLAYER_TYPE_OS)) {
                enginePlayerType = "os";
            }
        }
        return enginePlayerType;
    }
}
