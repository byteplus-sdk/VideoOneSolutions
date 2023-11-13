// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import static com.ss.avframework.livestreamv2.Constants.MSG_ERROR_ADM_PLAYER;
import static com.ss.avframework.livestreamv2.Constants.MSG_ERROR_ADM_RECORDING;
import static com.ss.avframework.livestreamv2.Constants.MSG_ERROR_AUDIO_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_ERROR_AUDIO_ENCODER;
import static com.ss.avframework.livestreamv2.Constants.MSG_ERROR_RTMP;
import static com.ss.avframework.livestreamv2.Constants.MSG_ERROR_VIDEO_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_ERROR_VIDEO_ENCODER;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_STARTED_PUBLISH;
import static com.ss.avframework.livestreamv2.Constants.MSG_REPORT_NETWORK_QUALITY;
import static com.ss.avframework.livestreamv2.Constants.MSG_STATUS_EXCEPTION;

import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import com.pandora.ttsdk.newapi.LiveCoreBuilder;
import com.pandora.ttsdk.newapi.LiveCoreEngine;
import com.ss.avframework.livestreamv2.LiveStreamBuilder;
import com.ss.avframework.livestreamv2.core.LiveCore;
import com.ss.bytertc.engine.RTCVideo;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.solution.interactivelive.feature.main.AudienceVideoPlayer;
import com.vertcdemo.solution.interactivelive.bean.SeiAppData;
import com.vertcdemo.solution.interactivelive.event.LiveCoreNetworkQualityEvent;
import com.vertcdemo.solution.interactivelive.util.LiveCoreConfig;
import com.vertcdemo.core.utils.AppUtil;

import java.util.ArrayList;

public class LiveCoreHolder {
    private static final String TAG = "LiveCore";

    public static LiveCoreEngine createEngine() {
        TTSdkHelper.initTTVodSdk();

        final int videoWidth = 540;
        final int videoHeight = 960;
        final int videoFps = 15;
        final int bitrate = 1000 * 1000;

        LiveCoreBuilder builder = new LiveCoreBuilder();
        builder.setContext(AppUtil.getApplicationContext())
                .setEnableVideoEncodeAccelera(true)
                .setVideoWidth(videoWidth)
                .setVideoHeight(videoHeight)
                .setVideoFps(videoFps)
                .setVideoBitrate(bitrate)
                .setVideoMaxBitrate(bitrate * 5 / 3)
                .setVideoMinBitrate(bitrate * 2 / 5)
                // - BITRATE_ADAPT_STRATEGY_NORMAL
                // - BITRATE_ADAPT_STRATEGY_SENSITIVE
                // - BITRATE_ADAPT_STRATEGY_MORE_SENSITIVE
                .setBitrateAdaptStrategy(LiveStreamBuilder.BITRATE_ADAPT_STRATEGY_NORMAL)
                // - VIDEO_ENCODER_PROFILE_BASELINE
                // - VIDEO_ENCODER_PROFILE_MAIN
                // - VIDEO_ENCODER_PROFILE_HIGH
                .setVideoProfile(LiveStreamBuilder.VIDEO_ENCODER_PROFILE_HIGH)
                .setEnableVideoBFrame(false)
                .setVideoEncoder(LiveStreamBuilder.VIDEO_ENCODER_AVC);
        builder.setVideoCaptureDevice(LiveStreamBuilder.VIDEO_CAPTURE_DEVICE_EXTERN);
        builder.setAudioCaptureDevice(LiveStreamBuilder.AUDIO_CAPTURE_DEVICE_EXTERN);

        return builder.getLiveCoreEngine();
    }

    public static LiveCoreHolder createLiveCore() {
        return new LiveCoreHolder(createEngine());
    }

    final LiveCoreEngine mEngine;
    final LiveCore mLiveCore;

    final AVConsumer mConsumer;

    private LiveCoreHolder(LiveCoreEngine engine) {
        this.mEngine = engine;
        this.mLiveCore = engine.getLiveCore();

        mLiveCore.setInfoListener((code1, code2, code3) -> {
            switch (code1) {
                case MSG_INFO_STARTED_PUBLISH:
                    SeiAppData data = new SeiAppData();
                    mLiveCore.addSeiField(AudienceVideoPlayer.SEI_KEY_APP_DATA, GsonUtils.gson().toJson(data), Integer.MAX_VALUE);
                    Log.d(TAG, "[Holder] onInfo: STARTED_PUBLISH; code2=" + code2 + "; code3=" + code3);
                    break;
                case MSG_REPORT_NETWORK_QUALITY:
                    Log.d(TAG, "[Holder] onInfo: REPORT_NETWORK_QUALITY; code2=" + code2 + "; code3=" + code3);
                    SolutionEventBus.post(new LiveCoreNetworkQualityEvent(code2, code3));
                    break;
                default:
                    Log.d(TAG, "[Holder] onInfo: " + InfoMapper.get(code1) + "; code2 = " + code2 + "; code3 = " + code3);
                    break;
            }
        });

        mLiveCore.setErrorListener((code1, code2, e) -> {
            switch (code1) {
                case MSG_STATUS_EXCEPTION:
                    Log.e(TAG, "[Holder] onError: STATUS_EXCEPTION; code2=" + code2, e);
                    break;
                case MSG_ERROR_VIDEO_CAPTURE:
                    Log.e(TAG, "[Holder] onError: ERROR_VIDEO_CAPTURE; code2=" + code2, e);
                    break;
                case MSG_ERROR_AUDIO_CAPTURE:
                    Log.e(TAG, "[Holder] onError: ERROR_AUDIO_CAPTURE; code2=" + code2, e);
                    break;
                case MSG_ERROR_RTMP:
                    Log.e(TAG, "[Holder] onError: ERROR_RTMP; code2=" + code2, e);
                    break;
                case MSG_ERROR_VIDEO_ENCODER:
                    Log.e(TAG, "[Holder] onError: ERROR_VIDEO_ENCODER; code2=" + code2, e);
                    break;
                case MSG_ERROR_AUDIO_ENCODER:
                    Log.e(TAG, "[Holder] onError: ERROR_AUDIO_ENCODER; code2=" + code2, e);
                    break;
                case MSG_ERROR_ADM_RECORDING:
                    Log.e(TAG, "[Holder] onError: ERROR_ADM_RECORDING; code2=" + code2, e);
                    break;
                case MSG_ERROR_ADM_PLAYER:
                    Log.e(TAG, "[Holder] onError: ERROR_ADM_PLAYER; code2=" + code2, e);
                    break;
                default:
                    Log.e(TAG, "[Holder] onError: code1=" + code1 + "; code2=" + code2, e);
                    break;
            }
        });

        mConsumer = new AVConsumer(mLiveCore);
    }

    public void changeConfig(int width, int height, int fps, int defaultBitrate) {
        Log.d(TAG, "changeConfig: width=" + width
                + ",\n height=" + height
                + ",\n fps=" + fps
                + ",\n bitrate=" + defaultBitrate);
        mLiveCore.changeVideoResolution(width, height);
        mLiveCore.changeVideoFps(fps);
        int minBitrate = defaultBitrate * 3 / 5;
        int maxBitrate = defaultBitrate * 5 / 3;
        mLiveCore.changeVideoBitrate(defaultBitrate, minBitrate, maxBitrate);

        LiveConfigParams params = new LiveConfigParams();
        params.videoResolution(width, height);
        params.videoFps(fps);
        params.videoBitrate(defaultBitrate, minBitrate, maxBitrate);
        sLiveParams = params;
    }

    /**
     * For Live Info Dialog
     */
    @NonNull
    public static LiveConfigParams sLiveParams = new LiveConfigParams();

    public void start(RTCVideo rtcVideo, String url) {
        Log.d(TAG, "start: url=" + url);

        startCapture();

        // NOTE: ILiveStream need a mutable List, so we can't use Arrays.asList(...)
        final ArrayList<String> urls = new ArrayList<>();
        if (LiveCoreConfig.getRtmPushStreaming()) {
            String sdp = convertToSDPUrl(url);
            Log.d(TAG, "RTM push Streaming: ON: sdp=" + sdp);
            urls.add(sdp);
        } else {
            Log.d(TAG, "RTM push Streaming: OFF");
        }
        urls.add(url);
        mLiveCore.start(urls);

        mConsumer.start(rtcVideo);
    }

    public void stop(RTCVideo rtcVideo) {
        Log.d(TAG, "stop: ");
        mConsumer.stop(rtcVideo);
        mLiveCore.stop();
        stopCapture();
    }

    public void release() {
        Log.d(TAG, "release: ");
        mLiveCore.release();
        mEngine.release();
    }

    public void addSeiField(String key, Object value, int sendTimes) {
        Log.d(TAG, "addSeiField: key=" + key + ", value=" + value);
        mLiveCore.addSeiField(key, value, sendTimes);
    }

    private void startCapture() {
        mLiveCore.startAudioCapture();
        mLiveCore.startVideoCapture();
    }

    private void stopCapture() {
        mLiveCore.stopAudioCapture();
        mLiveCore.stopVideoCapture();
    }

    @NonNull
    public LiveCore getLiveCore() {
        return mLiveCore;
    }

    static String convertToSDPUrl(String url) {
        Uri uri = Uri.parse(url);
        Uri.Builder builder = uri.buildUpon();
        builder.scheme("http");
        builder.path(uri.getPath() + ".sdp");
        return builder.toString();
    }
}
