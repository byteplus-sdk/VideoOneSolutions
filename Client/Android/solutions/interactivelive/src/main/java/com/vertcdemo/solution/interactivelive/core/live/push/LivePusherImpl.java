// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live.push;

import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureExternal;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureMuteFrame;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePusherStatus.VeLivePushStatusConnectSuccess;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureExternal;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCodec.VeLiveVideoCodecH264;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution1080P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution540P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution720P;

import androidx.annotation.NonNull;

import com.pandora.common.env.Env;
import com.ss.avframework.live.VeLivePusher;
import com.ss.avframework.live.VeLivePusherConfiguration;
import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.live.VeLivePusherObserver;
import com.ss.bytertc.engine.RTCVideo;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.interactivelive.bean.SeiAppData;
import com.vertcdemo.solution.interactivelive.core.live.LLog;
import com.vertcdemo.solution.interactivelive.core.live.LiveConfigParams;
import com.vertcdemo.solution.interactivelive.core.live.LiveCoreHolder;
import com.vertcdemo.solution.interactivelive.core.live.StatisticsInfo;
import com.vertcdemo.solution.interactivelive.core.live.TTSdkHelper;
import com.vertcdemo.solution.interactivelive.event.LiveCoreNetworkQualityEvent;
import com.vertcdemo.solution.interactivelive.feature.main.AudienceVideoPlayer;

public class LivePusherImpl implements LiveCoreHolder {
    private static final String TAG = "LivePusher";

    public static LivePusherImpl create(boolean video, boolean audio) {
        LLog.d(TAG, "VeLivePusher Version=" + VeLivePusher.getVersion() + "/" + Env.getVersion());
        return new LivePusherImpl(video, audio);
    }

    /**
     * For Live Info Dialog
     */
    @NonNull
    public static LiveConfigParams sLiveParams = new LiveConfigParams();

    final VeLivePusher mLivePusher;

    final LivePusherAVConsumer mConsumer;

    final StatisticsInfo mStatisticsInfo = new StatisticsInfo();

    @NonNull
    private VeLivePusherDef.VeLiveVideoCaptureType mVideoCaptureType;
    @NonNull
    private VeLivePusherDef.VeLiveAudioCaptureType mAudioCaptureType;

    private LivePusherImpl(boolean video, boolean audio) {
        mVideoCaptureType = video ? VeLiveVideoCaptureExternal : VeLiveVideoCaptureDummyFrame;
        mAudioCaptureType = audio ? VeLiveAudioCaptureExternal : VeLiveAudioCaptureMuteFrame;

        TTSdkHelper.initTTVodSdk();

        VeLivePusherConfiguration config = new VeLivePusherConfiguration()
                .setContext(AppUtil.getApplicationContext())
                .setReconnectCount(10);
        mLivePusher = config.build();

        VeLivePusherDef.VeLiveVideoEncoderConfiguration videoEncoderConfig = mLivePusher.getVideoEncoderConfiguration()
                .setResolution(VeLiveVideoResolution540P)
                .setCodec(VeLiveVideoCodecH264)
                .setEnableAccelerate(true);
        mLivePusher.setVideoEncoderConfiguration(videoEncoderConfig);

        mLivePusher.setProperty("VeLiveKeyBitrateAdaptStrategy", "NORMAL");

        mLivePusher.setObserver(new VeLivePusherObserver() {
            @Override
            public void onError(int code, int subCode, String msg) {
                LLog.e(TAG, "[onError] code: " + code + ", subCode: " + subCode + ", msg: " + msg);
            }

            @Override
            public void onStatusChange(VeLivePusherDef.VeLivePusherStatus status) {
                LLog.d(TAG, "[onStatusChange] status: " + status);
                if (status == VeLivePushStatusConnectSuccess) {
                    SeiAppData data = new SeiAppData();
                    // Because liveMode=1 is default status, so 60 times is enough to tell client change layout
                    final int repeat = 60;
                    final boolean isKeyFrame = true;
                    final boolean allowsCovered = true;
                    // https://docs.byteplus.com/en/byteplus-media-live/docs/broadcast-sdk-for-android-api?version=v1.0#VeLivePusher-sendseimessage
                    mLivePusher.sendSeiMessage(
                            AudienceVideoPlayer.SEI_KEY_APP_DATA,
                            GsonUtils.gson().toJson(data),
                            repeat,
                            isKeyFrame,
                            allowsCovered);
                }
            }

            @Override
            public void onFirstVideoFrame(VeLivePusherDef.VeLiveFirstFrameType type, long timestampMs) {
                LLog.d(TAG, "[onFirstVideoFrame] type: " + type);
            }

            @Override
            public void onFirstAudioFrame(VeLivePusherDef.VeLiveFirstFrameType type, long timestampMs) {
                LLog.d(TAG, "[onFirstAudioFrame] type: " + type);
            }

            @Override
            public void onScreenRecording(boolean open) {
                LLog.d(TAG, "[onScreenRecording] open: " + open);
            }

            @Override
            public void onNetworkQuality(VeLivePusherDef.VeLiveNetworkQuality quality) {
                LLog.d(TAG, "[onNetworkQuality] quality: " + quality);
                SolutionEventBus.post(new LiveCoreNetworkQualityEvent(quality));
            }

            @Override
            public void onAudioPowerQuality(VeLivePusherDef.VeLiveAudioPowerLevel level, float value) {
                LLog.d(TAG, "[onAudioPowerQuality] level: " + level + "， value: " + value);
            }
        });

        final int intervalInSeconds = 5;
        mLivePusher.setStatisticsObserver(new VeLivePusherDef.VeLivePusherStatisticsObserver() {
            @Override
            public void onStatistics(VeLivePusherDef.VeLivePusherStatistics statistics) {
                mStatisticsInfo.encodeFps = statistics.encodeFps;
                mStatisticsInfo.transportFps = statistics.transportFps;
                mStatisticsInfo.encodeVideoBitrate = statistics.encodeVideoBitrate;
                mStatisticsInfo.transportVideoBitrate = statistics.transportVideoBitrate;
            }
        }, intervalInSeconds);
        mConsumer = new LivePusherAVConsumer(mLivePusher);
    }


    @Override
    public void changeConfig(int width, int height, int fps, int bitrateKbps) {
        int defaultBitrate = bitrateKbps;
        LLog.d(TAG, "changeConfig: width=" + width
                + ",\n height=" + height
                + ",\n fps=" + fps
                + ",\n bitrate=" + defaultBitrate);
        int minBitrate = defaultBitrate * 3 / 5;
        int maxBitrate = defaultBitrate * 5 / 3;

        VeLivePusherDef.VeLiveVideoResolution resolution;
        switch (width) {
            case 540:
                resolution = VeLiveVideoResolution540P;
                break;
            case 720:
                resolution = VeLiveVideoResolution720P;
                break;
            case 1080:
                resolution = VeLiveVideoResolution1080P;
                break;
            default:
                LLog.d(TAG, "fallback to 540p");
                resolution = VeLiveVideoResolution540P;
                break;
        }

        VeLivePusherDef.VeLiveVideoEncoderConfiguration videoEncoderConfig = new VeLivePusherDef.VeLiveVideoEncoderConfiguration()
                .setResolution(resolution)
                .setMinBitrate(minBitrate)
                .setMaxBitrate(maxBitrate)
                .setBitrate(defaultBitrate)
                .setFps(fps);
        mLivePusher.setVideoEncoderConfiguration(videoEncoderConfig);

        LiveConfigParams params = new LiveConfigParams();
        params.videoResolution(width, height);
        params.videoFps(fps);
        params.videoBitrate(defaultBitrate, minBitrate, maxBitrate);
        sLiveParams = params;
    }

    @Override
    public void start(@NonNull RTCVideo rtcVideo, String url) {
        LLog.d(TAG, "start: url=" + url);

        mLivePusher.startVideoCapture(mVideoCaptureType);
        mLivePusher.startAudioCapture(mAudioCaptureType);

        mLivePusher.startPush(url);

        mConsumer.start(rtcVideo);
    }

    @Override
    public void startFakeVideo() {
        LLog.d(TAG, "startFakeVideo");
        mVideoCaptureType = VeLiveVideoCaptureDummyFrame;
        mLivePusher.switchVideoCapture(mVideoCaptureType);
    }

    @Override
    public void stopFakeVideo() {
        LLog.d(TAG, "stopFakeVideo");
        mVideoCaptureType = VeLiveVideoCaptureExternal;
        mLivePusher.switchVideoCapture(mVideoCaptureType);
    }

    @Override
    public void startFakeAudio() {
        LLog.d(TAG, "startFakeAudio");
        mAudioCaptureType = VeLiveAudioCaptureMuteFrame;
        mLivePusher.switchAudioCapture(mAudioCaptureType);
    }

    @Override
    public void stopFakeAudio() {
        LLog.d(TAG, "stopFakeAudio");
        mAudioCaptureType = VeLiveAudioCaptureExternal;
        mLivePusher.switchAudioCapture(mAudioCaptureType);
    }

    @Override
    public void stop(@NonNull RTCVideo rtcVideo) {
        LLog.d(TAG, "stop: ");
        mConsumer.stop(rtcVideo);
        mLivePusher.stopPush();
        stopCapture();
    }

    @Override
    public void release() {
        LLog.d(TAG, "release: ");
        mLivePusher.release();
    }

    @NonNull
    public StatisticsInfo getStatisticsInfo() {
        return mStatisticsInfo;
    }

    private void stopCapture() {
        mLivePusher.stopVideoCapture();
        mLivePusher.stopAudioCapture();
    }
}
