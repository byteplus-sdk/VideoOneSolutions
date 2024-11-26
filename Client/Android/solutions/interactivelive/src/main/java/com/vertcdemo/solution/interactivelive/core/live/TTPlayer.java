// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFill;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeFullFill;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatFLV;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatRTM;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerProtocol.VeLivePlayerProtocolTCP;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerProtocol.VeLivePlayerProtocolTLS;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get1080Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get480Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get540Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get720Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.getOriginUrl;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Consumer;

import com.pandora.common.env.Env;
import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerConfiguration;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VeLivePlayerStreamData;
import com.ss.videoarch.liveplayer.VideoLiveManager;
import com.vertcdemo.core.protocol.IVideoPlayer;
import com.vertcdemo.core.protocol.ScalingMode;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.core.utils.Utils;
import com.vertcdemo.solution.interactivelive.core.live.adapter.VeLivePlayerObserverAdapter;
import com.vertcdemo.solution.interactivelive.util.LiveCoreConfig;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Map;

public class TTPlayer implements IVideoPlayer {

    private static final String TAG = "TTPlayer";

    private VeLivePlayer mLivePlayer;

    private TextureView mTextureView;

    private Surface mSurface;
    private String mSourcePath;
    private Map<String, String> mSourcePaths;

    Consumer<String> mSEICallback;

    @Override
    public void startWithConfiguration(Context context, Consumer<String> seiCallback) {
        LLog.d(TAG, "startWithConfiguration");
        TTSdkHelper.initTTVodSdk();
        createLivePlayer();
        createTextureView(context);
        this.mSEICallback = seiCallback;
    }

    private void attachTextureTo(View container) {
        if (container instanceof ViewGroup && mTextureView != null) {
            ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT);
            Utils.attachViewToViewGroup((ViewGroup) container, mTextureView, params);
        }
    }

    @Override
    public void setPlayerUrl(String url, View container) {
        LLog.d(TAG, String.format("setPlayerUrl: %s", url));
        mSourcePath = url;
        mSourcePaths = null;

        attachTextureTo(container);

        if (mLivePlayer != null) {
            mLivePlayer.setSurface(mSurface);

            VeLivePlayerStreamData streamData = singleUrlStreaming(url);
            mLivePlayer.setPlayStreamData(streamData);
        }
    }

    public void setPlayerUrls(Map<String, String> urls, View container) {
        LLog.d(TAG, "setPlayerUrls: " + urls);
        mSourcePaths = urls;
        mSourcePath = null;

        attachTextureTo(container);

        if (mLivePlayer == null) {
            return;
        }

        boolean rtmPullStreaming = LiveCoreConfig.getRtmPullStreaming();
        if (rtmPullStreaming) { // RTM Pull Streaming
            VeLivePlayerStreamData streamData = createRTMPullStreaming(urls);
            mLivePlayer.setPlayStreamData(streamData);
            return;
        }

        boolean abr = LiveCoreConfig.getABR();
        if (abr) { // ABR
            VeLivePlayerStreamData streamData = createABRStreaming(urls);
            mLivePlayer.setPlayStreamData(streamData);
            return;
        }

        // Play origin stream
        {
            LLog.d(TAG, "setPlayerUrls: RTM Pull Streaming/ABR: BOTH OFF");
            final String url = getOriginUrl(urls);
            assert url != null;
            LLog.d(TAG, "setPlayerUrls: origin=" + url);
            VeLivePlayerStreamData streamData = singleUrlStreaming(url);
            mLivePlayer.setPlayStreamData(streamData);
        }
    }

    private static VeLivePlayerStreamData singleUrlStreaming(String url) {
        VeLivePlayerStreamData.VeLivePlayerStream flvStream = new VeLivePlayerStreamData.VeLivePlayerStream();
        flvStream.url = url;

        VeLivePlayerStreamData streamData = new VeLivePlayerStreamData();
        streamData.mainStreamList = Collections.singletonList(flvStream);

        return streamData;
    }

    private static VeLivePlayerStreamData createRTMPullStreaming(Map<String, String> urls) {
        LLog.d(TAG, "setPlayerUrls: RTM Pull Streaming: ON");
        final String url = getOriginUrl(urls);
        assert url != null;

        final String sdpUrl = url.replaceFirst("\\.flv$", ".sdp");
        LLog.d(TAG, "setPlayerUrls: origin=" + url);
        LLog.d(TAG, "setPlayerUrls: sdp=" + sdpUrl);

        VeLivePlayerStreamData.VeLivePlayerStream rtmStream = new VeLivePlayerStreamData.VeLivePlayerStream();
        rtmStream.url = sdpUrl;
        rtmStream.format = VeLivePlayerFormatRTM;
        rtmStream.resolution = LivePlayerResolution.Origin;
        rtmStream.streamType = VeLivePlayerStreamTypeMain;

        VeLivePlayerStreamData.VeLivePlayerStream flvStream = new VeLivePlayerStreamData.VeLivePlayerStream();
        flvStream.url = url;
        flvStream.format = VeLivePlayerFormatFLV;
        flvStream.resolution = LivePlayerResolution.Origin;
        flvStream.streamType = VeLivePlayerStreamTypeMain;

        VeLivePlayerStreamData streamData = new VeLivePlayerStreamData();
        streamData.mainStreamList = Arrays.asList(rtmStream, flvStream);

        streamData.defaultFormat = VeLivePlayerFormatRTM;
        streamData.defaultProtocol = getProtocol(sdpUrl);

        return streamData;
    }

    private static VeLivePlayerStreamData createABRStreaming(Map<String, String> urls) {
        LLog.d(TAG, "setPlayerUrls: ABR: ON");
        final ArrayList<VeLivePlayerStreamData.VeLivePlayerStream> streams = new ArrayList<>();

        { // 480p
            final String url = get480Url(urls);
            LLog.d(TAG, "setPlayerUrls: 480p=" + url);
            if (url != null) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = new VeLivePlayerStreamData.VeLivePlayerStream();
                stream.url = url;
                stream.format = VeLivePlayerFormatFLV;
                stream.resolution = LivePlayerResolution.LD;
                stream.streamType = VeLivePlayerStreamTypeMain;
                stream.bitrate = 1024;

                streams.add(stream);
            }
        }

        { // 540p
            final String url = get540Url(urls);
            LLog.d(TAG, "setPlayerUrls: 540p=" + url);
            if (url != null) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = new VeLivePlayerStreamData.VeLivePlayerStream();
                stream.url = url;
                stream.format = VeLivePlayerFormatFLV;
                stream.resolution = LivePlayerResolution.SD;
                stream.streamType = VeLivePlayerStreamTypeMain;
                stream.bitrate = 1638;

                streams.add(stream);
            }
        }

        { // 720p
            final String url = get720Url(urls);
            LLog.d(TAG, "setPlayerUrls: 720p=" + url);
            if (url != null) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = new VeLivePlayerStreamData.VeLivePlayerStream();
                stream.url = url;
                stream.format = VeLivePlayerFormatFLV;
                stream.resolution = LivePlayerResolution.HD;
                stream.streamType = VeLivePlayerStreamTypeMain;
                stream.bitrate = 2048;

                streams.add(stream);
            }
        }

        { // 1080p
            final String url = get1080Url(urls);
            LLog.d(TAG, "setPlayerUrls: 1080p=" + url);
            if (url != null) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = new VeLivePlayerStreamData.VeLivePlayerStream();
                stream.url = url;
                stream.format = VeLivePlayerFormatFLV;
                stream.resolution = LivePlayerResolution.UHD;
                stream.streamType = VeLivePlayerStreamTypeMain;
                stream.bitrate = 3200;

                streams.add(stream);
            }
        }

        { // origin
            final String url = getOriginUrl(urls);
            LLog.d(TAG, "setPlayerUrls: origin=" + url);
            if (url != null) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = new VeLivePlayerStreamData.VeLivePlayerStream();
                stream.url = url;
                stream.format = VeLivePlayerFormatFLV;
                stream.resolution = LivePlayerResolution.Origin;
                stream.streamType = VeLivePlayerStreamTypeMain;
                stream.bitrate = 5000;

                streams.add(stream);
            }
        }

        VeLivePlayerStreamData streamData = new VeLivePlayerStreamData();
        streamData.mainStreamList = streams;
        streamData.defaultResolution = LivePlayerResolution.HD;
        streamData.enableABR = true;
        return streamData;
    }

    @Override
    public void updatePlayScaleModel(int scalingMode) {
        LLog.d(TAG, "updatePlayScaleModel: " + scalingMode);
        if (scalingMode == ScalingMode.NONE) {
            return;
        }
        VeLivePlayerDef.VeLivePlayerFillMode mode;
        if (scalingMode == ScalingMode.ASPECT_FIT) {
            mode = VeLivePlayerFillModeAspectFit;
        } else if (scalingMode == ScalingMode.ASPECT_FILL) {
            mode = VeLivePlayerFillModeAspectFill;
        } else {
            mode = VeLivePlayerFillModeFullFill;
        }

        if (mLivePlayer != null) {
            mLivePlayer.setRenderFillMode(mode);
        }
    }

    @Override
    public void play() {
        LLog.d(TAG, "play");
        if (mLivePlayer != null) {
            mLivePlayer.play();
        }
    }

    @Override
    public void replacePlayWithUrl(String url) {
        LLog.d(TAG, String.format("replacePlayWithUrl: %s", url));
        if (mTextureView != null && mTextureView.getParent() instanceof ViewGroup) {
            setPlayerUrl(url, (ViewGroup) mTextureView.getParent());
            play();
        }
    }

    public void replacePlayWithUrls(Map<String, String> urls) {
        LLog.d(TAG, String.format("replacePlayWithUrls: %s", urls));
        if (mTextureView != null && mTextureView.getParent() instanceof ViewGroup) {
            setPlayerUrls(urls, (ViewGroup) mTextureView.getParent());
            play();
        }
    }

    @Override
    public void stop() {
        LLog.d(TAG, "stop");
        if (mLivePlayer != null) {
            mLivePlayer.stop();
        }
    }

    @Override
    public boolean isSupportSEI() {
        return true;
    }

    @Override
    public void destroy() {
        LLog.d(TAG, "destroy");
        if (mLivePlayer != null) {
            mLivePlayer.destroy();
            mLivePlayer = null;
        }
        mSourcePath = null;
        removeFromParent(mTextureView);
        mTextureView = null;
    }

    private void createTextureView(Context context) {
        mTextureView = new TextureView(context);
        mTextureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {

            @Override
            public void onSurfaceTextureAvailable(@NonNull SurfaceTexture surface, int width, int height) {
                mSurface = new Surface(surface);
                if (mLivePlayer == null) {
                    createLivePlayer();
                }
                mLivePlayer.setSurface(mSurface);

                if (mSourcePaths != null) {
                    replacePlayWithUrls(mSourcePaths);
                } else if (mSourcePath != null) {
                    replacePlayWithUrl(mSourcePath);
                }
            }

            @Override
            public void onSurfaceTextureSizeChanged(@NonNull SurfaceTexture surface, int width, int height) {

            }

            @Override
            public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surface) {
                surface.release();
                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surface) {

            }
        });
    }

    private void removeFromParent(@Nullable View view) {
        if (view == null) {
            return;
        }
        ViewParent parent = view.getParent();
        if (parent instanceof ViewGroup) {
            ((ViewGroup) parent).removeView(view);
        }
    }

    private void createLivePlayer() {
        if (mLivePlayer != null) {
            mLivePlayer.destroy();
        }

        LLog.d(TAG, "VideoLiveManager Version=" + VideoLiveManager.getVersion() + "/" + Env.getVersion());
        mLivePlayer = new VideoLiveManager(AppUtil.getApplicationContext());
        VeLivePlayerConfiguration config = new VeLivePlayerConfiguration();
        config.enableSei = true; // UI need sei info to update layout
        config.statisticsCallbackInterval = 5; // per seconds
        config.enableStatisticsCallback = true;

        mLivePlayer.setConfig(config);

        mLivePlayer.setObserver(new VeLivePlayerObserverAdapter() {
            @Override
            public void onReceiveSeiMessage(VeLivePlayer player, String message) {
                super.onReceiveSeiMessage(player, message);
                if (mSEICallback != null) {
                    mSEICallback.accept(message);
                }
            }
        });
    }

    private static VeLivePlayerDef.VeLivePlayerProtocol getProtocol(@NonNull String url) {
        String scheme = Uri.parse(url).getScheme();
        if ("https".equalsIgnoreCase(scheme)) {
            return VeLivePlayerProtocolTCP;
        } else {
            return VeLivePlayerProtocolTLS;
        }
    }
}
