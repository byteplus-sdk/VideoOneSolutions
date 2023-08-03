// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_ENCODE_TYPE_H264;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_FORMAT_FLV;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_FORMAT_LLS;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_RESOLUTION_HD;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_RESOLUTION_LD;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_RESOLUTION_ORIGIN;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_RESOLUTION_SD;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_RESOLUTION_UHD;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_SOURCE_TYPE_BACKUP;
import static com.pandora.live.player.been.TTLiveURLComposer.MEDIA_SOURCE_TYPE_MAIN;
import static com.ss.ttm.player.MediaPlayer.IMAGE_LAYOUT_ASPECT_FILL;
import static com.ss.ttm.player.MediaPlayer.IMAGE_LAYOUT_ASPECT_FIT;
import static com.ss.ttm.player.MediaPlayer.IMAGE_LAYOUT_TO_FILL;
import static com.ss.videoarch.liveplayer.ILivePlayer.ENABLE;
import static com.ss.videoarch.liveplayer.ILivePlayer.LIVE_OPTION_IMAGE_LAYOUT;
import static com.ss.videoarch.liveplayer.ILivePlayer.LIVE_PLAYER_OPTION_H264_HARDWARE_DECODE;
import static com.ss.videoarch.liveplayer.ILivePlayer.LIVE_PLAYER_OPTION_RESOLUTION;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get1080Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get480Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get540Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.get720Url;
import static com.vertcdemo.solution.interactivelive.core.live.StreamUrls.getOriginUrl;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Consumer;

import com.pandora.live.player.LivePlayerBuilder;
import com.pandora.live.player.been.TTLiveURLABRParams;
import com.pandora.live.player.been.TTLiveURLComponent;
import com.pandora.live.player.been.TTLiveURLComposer;
import com.ss.videoarch.liveplayer.ILiveListener;
import com.ss.videoarch.liveplayer.ILivePlayer;
import com.ss.videoarch.liveplayer.INetworkClient;
import com.ss.videoarch.liveplayer.VideoLiveManager;
import com.ss.videoarch.liveplayer.log.LiveError;
import com.ss.videoarch.liveplayer.model.LiveURL;
import com.vertcdemo.solution.interactivelive.util.LiveCoreConfig;
import com.vertcdemo.core.protocol.IVideoPlayer;
import com.vertcdemo.core.protocol.ScalingMode;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.core.utils.Utils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class TTPlayer implements IVideoPlayer {

    private static final String TAG = "TTPlayer";

    private static final int RETRY_TIME_LIMIT = 5;
    private ILivePlayer mLivePlayer;

    private TextureView mTextureView;

    private Surface mSurface;
    private String mSourcePath;
    private Map<String, String> mSourcePaths;

    private int mScaleMode = ScalingMode.NONE;

    Consumer<String> mSEICallback;

    @Override
    public void startWithConfiguration(Context context, Consumer<String> seiCallback) {
        Log.d(TAG, "startWithConfiguration");
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
        Log.d(TAG, String.format("setPlayerUrl: %s", url));
        mSourcePath = url;
        mSourcePaths = null;

        attachTextureTo(container);

        if (mLivePlayer != null) {
            mLivePlayer.setSurface(mSurface);

            LiveURL liveURL = new LiveURL(url, null, "{\"VCodec\":\"h264\"}");
            LiveURL[] urls = {liveURL};
            mLivePlayer.setPlayURLs(urls);
        }
    }

    public void setPlayerUrls(Map<String, String> urls, View container) {
        Log.d(TAG, "setPlayerUrls: " + urls);
        mSourcePaths = urls;
        mSourcePath = null;

        attachTextureTo(container);

        if (mLivePlayer == null) {
            return;
        }

        boolean rtmPullStreaming = LiveCoreConfig.getRtmPullStreaming();
        if (rtmPullStreaming) { // RTM Pull Streaming
            TTLiveURLComposer urlComposer = createRTMPullStreamingComposer(urls);
            mLivePlayer.setStreamInfo(urlComposer.getStreamInfo());
            return;
        }

        boolean abr = LiveCoreConfig.getABR();
        if (abr) { // ABR
            TTLiveURLComposer urlComposer = createABRComposer(urls);
            mLivePlayer.setStringOption(LIVE_PLAYER_OPTION_RESOLUTION, "auto");
            mLivePlayer.setStreamInfo(urlComposer.getStreamInfo());
            return;
        }

        // Play origin stream
        {
            Log.d(TAG, "setPlayerUrls: RTM Pull Streaming/ABR: BOTH OFF");
            final String url = getOriginUrl(urls);
            assert url != null;
            Log.d(TAG, "setPlayerUrls: origin=" + url);
            LiveURL liveURL = new LiveURL(url, null, "{\"VCodec\":\"h264\"}");
            mLivePlayer.setPlayURLs(new LiveURL[]{liveURL});
        }
    }

    private static TTLiveURLComposer createRTMPullStreamingComposer(Map<String, String> urls) {
        Log.d(TAG, "setPlayerUrls: RTM Pull Streaming: ON");
        final String url = getOriginUrl(urls);
        assert url != null;

        final String sdpUrl = url.replaceFirst("\\.flv$", ".sdp");
        Log.d(TAG, "setPlayerUrls: origin=" + url);
        Log.d(TAG, "setPlayerUrls: sdp=" + sdpUrl);

        TTLiveURLComposer urlComposer = new TTLiveURLComposer();
        urlComposer.addUrl(sdpUrl,
                MEDIA_ENCODE_TYPE_H264,
                MEDIA_SOURCE_TYPE_MAIN,
                MEDIA_FORMAT_LLS);
        urlComposer.addUrl(url,
                MEDIA_ENCODE_TYPE_H264,
                MEDIA_SOURCE_TYPE_BACKUP,
                MEDIA_FORMAT_FLV);

        return urlComposer;
    }

    private static TTLiveURLComposer createABRComposer(Map<String, String> urls) {
        Log.d(TAG, "setPlayerUrls: ABR: ON");
        final TTLiveURLComposer urlComposer = new TTLiveURLComposer();
        final ArrayList<String> resolutions = new ArrayList<>();

        { // 480p
            final String url = get480Url(urls);
            Log.d(TAG, "setPlayerUrls: 480p=" + url);
            if (url != null) {
                TTLiveURLComponent component = new TTLiveURLComponent();
                component.setURL(url);
                component.setResolution(MEDIA_RESOLUTION_LD);
                TTLiveURLABRParams abrParams = new TTLiveURLABRParams();
                abrParams.setVbitrate(1024_000);
                component.setTTLiveURLABRParams(abrParams);

                urlComposer.addUrl(component);
                resolutions.add(MEDIA_RESOLUTION_LD);
            }
        }

        { // 540p
            final String url = get540Url(urls);
            Log.d(TAG, "setPlayerUrls: 540p=" + url);
            if (url != null) {
                TTLiveURLComponent component = new TTLiveURLComponent();
                component.setURL(url);
                component.setResolution(MEDIA_RESOLUTION_SD);
                TTLiveURLABRParams abrParams = new TTLiveURLABRParams();
                abrParams.setVbitrate(1638_000);
                component.setTTLiveURLABRParams(abrParams);

                urlComposer.addUrl(component);
                resolutions.add(MEDIA_RESOLUTION_SD);
            }
        }

        { // 720p
            final String url = get720Url(urls);
            Log.d(TAG, "setPlayerUrls: 720p=" + url);
            if (url != null) {
                TTLiveURLComponent component = new TTLiveURLComponent();
                component.setURL(url);
                component.setResolution(MEDIA_RESOLUTION_HD);
                TTLiveURLABRParams abrParams = new TTLiveURLABRParams();
                abrParams.setVbitrate(2048_000);
                component.setTTLiveURLABRParams(abrParams);

                urlComposer.addUrl(component);
                resolutions.add(MEDIA_RESOLUTION_HD);
            }
        }

        { // 1080p
            final String url = get1080Url(urls);
            Log.d(TAG, "setPlayerUrls: 1080p=" + url);
            if (url != null) {
                TTLiveURLComponent component = new TTLiveURLComponent();
                component.setURL(url);
                component.setResolution(MEDIA_RESOLUTION_UHD);
                TTLiveURLABRParams abrParams = new TTLiveURLABRParams();
                abrParams.setVbitrate(3200_000);
                component.setTTLiveURLABRParams(abrParams);

                urlComposer.addUrl(component);
                resolutions.add(MEDIA_RESOLUTION_UHD);
            }
        }

        { // origin
            final String url = getOriginUrl(urls);
            Log.d(TAG, "setPlayerUrls: origin=" + url);
            if (url != null) {
                TTLiveURLComponent component = new TTLiveURLComponent();
                component.setURL(url);
                component.setResolution(MEDIA_RESOLUTION_ORIGIN);
                TTLiveURLABRParams abrParams = new TTLiveURLABRParams();
                abrParams.setVbitrate(5000_000);
                component.setTTLiveURLABRParams(abrParams);

                urlComposer.addUrl(component);
                resolutions.add(MEDIA_RESOLUTION_ORIGIN);
            }
        }

        urlComposer.enableABR(true, MEDIA_RESOLUTION_HD, resolutions);
        return urlComposer;
    }

    @Override
    public void updatePlayScaleModel(int scalingMode) {
        Log.d(TAG, String.format("updatePlayScaleModel: %d", scalingMode));
        mScaleMode = scalingMode;
        if (scalingMode == ScalingMode.NONE) {
            return;
        }
        int op;
        if (scalingMode == ScalingMode.ASPECT_FIT) {
            op = IMAGE_LAYOUT_ASPECT_FIT;
        } else if (scalingMode == ScalingMode.ASPECT_FILL) {
            op = IMAGE_LAYOUT_ASPECT_FILL;
        } else {
            op = IMAGE_LAYOUT_TO_FILL;
        }
        if (mLivePlayer != null) {
            mLivePlayer.setIntOption(LIVE_OPTION_IMAGE_LAYOUT, op);
        }
    }

    @Override
    public void play() {
        Log.d(TAG, "play");
        if (mLivePlayer != null) {
            mLivePlayer.play();
        }
    }

    @Override
    public void replacePlayWithUrl(String url) {
        Log.d(TAG, String.format("replacePlayWithUrl: %s", url));
        if (mTextureView != null && mTextureView.getParent() instanceof ViewGroup) {
            setPlayerUrl(url, (ViewGroup) mTextureView.getParent());
            play();
        }
    }

    public void replacePlayWithUrls(Map<String, String> urls) {
        Log.d(TAG, String.format("replacePlayWithUrls: %s", urls));
        if (mTextureView != null && mTextureView.getParent() instanceof ViewGroup) {
            setPlayerUrls(urls, (ViewGroup) mTextureView.getParent());
            play();
        }
    }

    @Override
    public void stop() {
        Log.d(TAG, "stop");
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
        Log.d(TAG, "destroy");
        if (mLivePlayer != null) {
            mLivePlayer.release();
            mLivePlayer = null;
        }
        mSourcePath = null;
        removeFromParent(mTextureView);
        mTextureView = null;
        mScaleMode = ScalingMode.NONE;
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
        ILiveListener liveListener = new ILiveListener.Stub() {
            @Override
            public void onError(LiveError liveError) {
                Log.d(TAG, String.format("onError(): %s", liveError));
            }

            @Override
            public void onFirstFrame(boolean retry) {
                Log.d(TAG, String.format("onFirstFrame(): %b", retry));
            }

            @Override
            public void onPrepared() {
                Log.d(TAG, "onPrepared()");
            }

            @Override
            public void onCompletion() {
                Log.d(TAG, "onCompletion()");
            }

            @Override
            public void onVideoSizeChanged(int width, int height) {
                Log.d(TAG, String.format("onVideoSizeChanged() %d %d: ", width, height));
            }

            @Override
            public void onMonitorLog(JSONObject jsonObject, String s) {
                Log.d(TAG, "onMonitorLog jsonObject:");
            }

            @Override
            public void onSeiUpdate(String message) {
                Log.d(TAG, "onSeiUpdate: ");
                if (mSEICallback != null) {
                    mSEICallback.accept(message);
                }

                final JSONObject log = mLivePlayer.getStaticLog();
                Log.d(TAG, "onSeiUpdate: StaticLog: push_fps=" + log.optInt("push_client_fps:") + "; render_fps=" + log.optInt("render_fps:"));
            }
        };
        if (mLivePlayer != null) {
            mLivePlayer.release();
        }

        mLivePlayer = LivePlayerBuilder.newBuilder(AppUtil.getApplicationContext())
                .setRetryTimeout(RETRY_TIME_LIMIT)
                .setNetworkClient(new LiveTTSDKHttpClient())
                .setForceHttpDns(false)
                .setForceTTNetHttpDns(false)
                .setPlayerType(VideoLiveManager.PLAYER_OWN)
                .setListener(liveListener)
                .build();
    }

    private static class LiveTTSDKHttpClient implements INetworkClient {
        private final OkHttpClient mClient;

        public LiveTTSDKHttpClient() {
            mClient = new OkHttpClient().newBuilder()
                    .connectTimeout(10, TimeUnit.SECONDS)
                    .readTimeout(10, TimeUnit.SECONDS)
                    .writeTimeout(10, TimeUnit.SECONDS)
                    .build();
        }

        @Override
        public Result doRequest(String url, String host) {
            String body = null;
            JSONObject response = null;
            String header = null;
            Request request = new Request.Builder().url(url).addHeader("host", host).build();
            try (Response rsp = mClient.newCall(request).execute()) {
                if (rsp.isSuccessful()) {
                    ResponseBody responseBody = rsp.body();
                    if (responseBody != null) {
                        body = responseBody.string();
                    }
                    header = rsp.headers().toString();
                    if (body != null) {
                        response = new JSONObject(body);
                    }
                }
            } catch (JSONException e) {
                return Result.newBuilder().setBody(body).setHeader(header).setException(e).build();
            } catch (Exception e) {
                return Result.newBuilder().setException(e).build();
            }
            return Result.newBuilder().setResponse(response).setBody(body).build();
        }

        @Override
        public Result doPost(String s, String s1) {
            return null;
        }
    }
}
