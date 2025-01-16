// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_SCENE_SHORT_VIDEO;
import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_SCENE_SMALL_VIDEO;
import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_TYPE_PRELOAD;
import static com.ss.ttvideoengine.strategy.StrategyManager.STRATEGY_TYPE_PRE_RENDER;

import android.content.Context;
import android.os.Looper;
import android.view.Surface;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.source.TrackSelector;
import com.byteplus.playerkit.player.utils.ProgressRecorder;
import com.byteplus.playerkit.utils.L;
import com.ss.ttvideoengine.PreloaderURLItem;
import com.ss.ttvideoengine.PreloaderVidItem;
import com.ss.ttvideoengine.PreloaderVideoModelItem;
import com.ss.ttvideoengine.Resolution;
import com.ss.ttvideoengine.TTVideoEngine;
import com.ss.ttvideoengine.selector.strategy.GearStrategy;
import com.ss.ttvideoengine.source.DirectUrlSource;
import com.ss.ttvideoengine.source.VidPlayAuthTokenSource;
import com.ss.ttvideoengine.source.VideoModelSource;
import com.ss.ttvideoengine.strategy.EngineStrategyListener;
import com.ss.ttvideoengine.strategy.StrategyManager;
import com.ss.ttvideoengine.strategy.StrategySettings;
import com.ss.ttvideoengine.strategy.preload.PreloadTaskFactory;
import com.ss.ttvideoengine.strategy.source.StrategySource;

import org.json.JSONObject;

import java.util.List;

public class VolcEngineStrategy {


    private static int sCurrentScene = VolcScene.SCENE_UNKNOWN;
    private static boolean sSceneStrategyEnabled = false;

    static void init() {
        if (!VolcConfigGlobal.ENABLE_SCENE_STRATEGY_INIT) return;
        // preRender
        StrategyManager.instance().enableReleasePreRenderEngineInstanceByLRU(true);
        TTVideoEngine.setEngineStrategyListener(new EngineStrategyListener() {
            @Override
            public TTVideoEngine createPreRenderEngine(StrategySource strategySource) {
                final Context context = VolcPlayerInit.getContext();
                final MediaSource mediaSource = (MediaSource) strategySource.tag();
                final long recordPosition = ProgressRecorder.getProgress(mediaSource.getSyncProgressId());
                final VolcPlayer player = new VolcPlayer.Factory(context, mediaSource).preCreate(Looper.getMainLooper());
                player.setListener(new VolcPlayerEventRecorder());
                player.setDataSource(mediaSource);
                player.setStartTime(recordPosition > 0 ? recordPosition : 0);
                player.prepareAsync();
                return player.getTTVideoEngine();
            }
        });

        // preload
        StrategyManager.instance().setPreloadTaskFactory(new PreloadTaskFactory() {
            @Override
            public PreloaderVidItem createVidItem(VidPlayAuthTokenSource source, long preloadSize) {
                final PreloaderVidItem item = PreloadTaskFactory.super.createVidItem(source, preloadSize);
                final MediaSource mediaSource = (MediaSource) source.tag();
                if (mediaSource == null) return item; // error
                VolcPlayerInit.getConfigUpdater().updateVolcConfig(mediaSource);
                item.setFetchEndListener((videoModel, error) -> {
                    Mapper.updateMediaSource(mediaSource, videoModel);
                    final VolcConfig volcConfig = VolcConfig.get(mediaSource);
                    Track playTrack = null;
                    if (VolcQualityStrategy.isEnableStartupABR(volcConfig)) {
                        VolcQualityStrategy.StartupTrackResult result = VolcQualityStrategy.select(
                                GearStrategy.GEAR_STRATEGY_SELECT_TYPE_PRELOAD,
                                mediaSource,
                                videoModel);
                        playTrack = result.track;
                    }
                    if (playTrack == null) {
                        playTrack = selectPlayTrack(TrackSelector.TYPE_PRELOAD, mediaSource);
                    }
                    final Resolution resolution = playTrack != null ? Mapper.track2Resolution(playTrack) : null;
                    if (resolution != null) {
                        item.mResolution = resolution;
                    }
                });
                return item;
            }

            @Override
            public PreloaderVideoModelItem createVideoModelItem(VideoModelSource source, long preloadSize) {
                final PreloaderVideoModelItem item = PreloadTaskFactory.super.createVideoModelItem(source, preloadSize);
                final MediaSource mediaSource = (MediaSource) source.tag();
                if (mediaSource == null) return item; // error
                VolcPlayerInit.getConfigUpdater().updateVolcConfig(mediaSource);
                final VolcConfig volcConfig = VolcConfig.get(mediaSource);
                Track playTrack = null;
                if (VolcQualityStrategy.isEnableStartupABR(volcConfig)) {
                    VolcQualityStrategy.StartupTrackResult result = VolcQualityStrategy.select(
                            GearStrategy.GEAR_STRATEGY_SELECT_TYPE_PRELOAD,
                            mediaSource,
                            source.videoModel());
                    playTrack = result.track;
                }
                if (playTrack == null) {
                    playTrack = selectPlayTrack(TrackSelector.TYPE_PRELOAD, mediaSource);
                }
                final Resolution resolution = playTrack != null ? Mapper.track2Resolution(playTrack) : null;
                if (resolution != null) {
                    item.mResolution = resolution;
                }
                return item;
            }

            @Override
            public PreloaderURLItem createUrlItem(DirectUrlSource source, long preloadSize) {
                PreloaderURLItem item = PreloadTaskFactory.super.createUrlItem(source, preloadSize);
                final MediaSource mediaSource = (MediaSource) source.tag();
                if (mediaSource == null) return item; // error
                VolcPlayerInit.getConfigUpdater().updateVolcConfig(mediaSource);
                return item;
            }
        });
    }

    /**
     * For vid only
     */
    private static Track selectPlayTrack(@TrackSelector.Type int type, MediaSource mediaSource) {
        @Track.TrackType final int trackType = MediaSource.mediaType2TrackType(mediaSource);
        List<Track> tracks = mediaSource.getTracks(trackType);
        if (tracks != null) {
            return VolcPlayerInit.getTrackSelector().selectTrack(type, trackType, tracks, mediaSource);
        }
        return null;
    }

    public synchronized static void setEnabled(int volcScene, boolean enabled) {
        L.d(VolcEngineStrategy.class, "setEnabled", VolcScene.mapScene(volcScene), enabled);
        if (sCurrentScene != volcScene) {
            if (sSceneStrategyEnabled) {
                clearSceneStrategy();
                sSceneStrategyEnabled = false;
            }
        }
        sCurrentScene = volcScene;
        if (sSceneStrategyEnabled != enabled) {
            sSceneStrategyEnabled = enabled;
            if (enabled) {
                setEnabled(volcScene);
            } else {
                clearSceneStrategy();
            }
        }
    }

    public static void clearSceneStrategy() {
        TTVideoEngine.clearAllStrategy();
    }

    public static void setMediaSources(List<MediaSource> mediaSources) {
        if (mediaSources == null) return;
        List<StrategySource> strategySources = Mapper.mediaSources2StrategySources(
                mediaSources,
                VolcPlayerInit.getCacheKeyFactory(),
                VolcPlayerInit.getTrackSelector(),
                TrackSelector.TYPE_PRELOAD);
        if (strategySources == null) return;
        TTVideoEngine.setStrategySources(strategySources);
    }

    public static void addMediaSources(List<MediaSource> mediaSources) {
        if (mediaSources == null) return;
        List<StrategySource> strategySources = Mapper.mediaSources2StrategySources(
                mediaSources,
                VolcPlayerInit.getCacheKeyFactory(),
                VolcPlayerInit.getTrackSelector(),
                TrackSelector.TYPE_PRELOAD);
        if (strategySources == null) return;
        TTVideoEngine.addStrategySources(strategySources);
    }

    @Nullable
    public static JSONObject getPreloadConfig(int scene) {
        switch (scene) {
            case VolcScene.SCENE_SHORT_VIDEO: // Short
                return StrategySettings.getInstance().getPreload(StrategyManager.STRATEGY_SCENE_SMALL_VIDEO);
            case VolcScene.SCENE_FEED_VIDEO: // Feed
                return StrategySettings.getInstance().getPreload(StrategyManager.STRATEGY_SCENE_SHORT_VIDEO);
        }
        return null;
    }

    public static void renderFrame(MediaSource mediaSource, Surface surface, int[] frameInfo) {
        if (mediaSource == null) return;
        if (surface == null || !surface.isValid()) return;

        final TTVideoEngine player = getPreRenderEngine(mediaSource);
        if (player != null && player != StrategyManager.instance().getPlayEngine()) {
            player.setSurface(surface);
            player.forceDraw();
            frameInfo[0] = player.getVideoWidth();
            frameInfo[1] = player.getVideoHeight();
        }
    }

    private static void setEnabled(int volcScene) {
        final int engineScene = Mapper.mapVolcScene2EngineScene(volcScene);
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

    static TTVideoEngine getPreRenderEngine(MediaSource mediaSource) {
        if (mediaSource == null) return null;

        final String key = key(mediaSource);

        TTVideoEngine player = StrategyManager.instance().getPreRenderEngine(key);
        if (player != null && player.isPrepared()) {
            L.d(VolcEngineStrategy.class, "getPreRenderEngine", key, player);
            return player;
        }
        return null;
    }

    static TTVideoEngine removePreRenderEngine(MediaSource mediaSource) {
        if (mediaSource == null) return null;

        final String key = key(mediaSource);

        TTVideoEngine player = StrategyManager.instance().removePreRenderEngine(key);
        if (player != null && player.isPrepared()) {
            L.e(VolcEngineStrategy.class, "removePreRenderEngine", key, player);
            return player;
        }
        return null;
    }

    private static String key(MediaSource mediaSource) {
        return mediaSource.getMediaId();
    }
}
