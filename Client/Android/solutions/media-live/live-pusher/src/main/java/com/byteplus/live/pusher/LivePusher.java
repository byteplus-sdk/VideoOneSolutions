// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.View;

import java.nio.ByteBuffer;

public interface LivePusher {
    interface InfoListener {
        void updateSettings(boolean isNeedRebuild);

        void onEnableCycleInfo(boolean enable);

        void onEnableCallbackRecord(boolean enable);
    }

    interface LivePusherObserver {
        void onCycleInfoUpdate(LivePusherCycleInfo info);

        void onCallbackRecordUpdate(String content);

        void onNetworkQuality(int quality);

        void onRebuildLivePusher();
    }

    interface FileRecordingListener {
        void onFileRecordingStarted();

        void onFileRecordingStopped();

        void onFileRecordingError(int errorCode, String message);
    }

    interface MediaPlayerListener {
        void onProgress(int progress);
    }

    default Object getEffectHandler() {
        return null;
    }

    void setOrientation(int orientation);

    void setRenderView(View view);

    void startVideoCapture(int type);

    void stopVideoCapture();

    void startAudioCapture(int type);

    void stopAudioCapture();

    void startScreenRecording(Intent screenIntent);

    void stopScreenRecording();

    void updateCustomImage(Bitmap bm);

    int pushExternalVideoFrame(VideoFrame frame);

    int pushExternalAudioFrame(AudioFrame frame);

    void switchVideoCapture(int type);

    void switchAudioCapture(int type);

    int enableTorch(boolean enable);

    void updateSettings(boolean isNeedRebuild);

    void startPush();

    void stopPush();

    boolean isMute();

    void setMute(boolean mute);

    void setFileRecordingConfig(int resolution, int fps, int bitrate);

    void startFileRecording(FileRecordingListener listener);

    void stopFileRecording();

    void setVideoMirror(int mirrorType, boolean enable);

    void snapshot();

    void sendSeiMessage(String content, int repeatCount);

    void setWatermark(Bitmap bm, float x, float y, float scale);

    Object addAudioStream();

    void sendAudioFrame(Object streamHandle, AudioFrame frame);

    void removeAudioStream(Object streamHandle);

    Object addVideoStream();

    void sendVideoFrame(Object streamHandle, VideoFrame frame);

    void updateStreamMixDescription(Object streamHandle, float x, float y, float alpha, int renderMode);

    void removeVideoStream(Object streamHandle);

    void updateMixBgColor(int color);

    float getVoiceLoudness();

    void setVoiceLoudness(float level);

    boolean enableEcho(boolean enable);

    boolean isEnableEcho();

    int startBgm(String filePath, MediaPlayerListener listener);

    void stopBgm();

    int seekBgm(int pos);

    void resumeBgm();

    void pauseBgm();

    void enableBgmMixer(boolean enable);

    void enableBgmFrameListener(boolean enable);

    void setBgmVolume(float volume);

    void setVoiceVolume(float volume);

    void enableBgmLoop(boolean loop);

    void enableAudioFrameListener(boolean enable);

    void enableVideoFrameListener(boolean enable);

    void setFocusPosition(int width, int height, int x, int y);

    float getCurrentZoomRatio();

    float getMaxZoomRatio();

    float getMinZoomRatio();

    void setZoomRatio(float ratio);

    void release();

    class AudioFrame {
        //        static final int AUDIO_BUFFER_TYPE_UNKNOWN = 0;
//        static final int AUDIO_BUFFER_TYPE_BYTE_BUFFER = 1;
//        int bufferType = AUDIO_BUFFER_TYPE_UNKNOWN;
        int sampleRate = 44100;
        int channels = 2;
        int bitDepth = 16;
        long pts;
        ByteBuffer buffer;

        public AudioFrame() {
        }

        public AudioFrame(int bufferType, int sampleRate, int channels, long pts, ByteBuffer buffer) {
//            this.bufferType = bufferType;
//            this.sampleRate = sampleRate;
//            this.channels = channels;
            this.pts = pts;
            this.buffer = buffer;
        }
    }

    class VideoFrame {
        public static final int VIDEO_BUFFER_TYPE_BYTE_BUFFER = 0;
        public static final int VIDEO_BUFFER_TYPE_BYTE_ARRAY = 1;
        public static final int VIDEO_BUFFER_TYPE_TEXTURE_ID = 2;
        public static final int VIDEO_BUFFER_TYPE_UNKNOWN = 3;

        public static final int VIDEO_PIXEL_FMT_I420 = 0;
        public static final int VIDEO_PIXEL_FMT_NV12 = 1;
        public static final int VIDEO_PIXEL_FMT_NV21 = 2;
        public static final int VIDEO_PIXEL_FMT_2D_TEXTURE = 3;
        public static final int VIDEO_PIXEL_FMT_OES_TEXTURE = 4;
        public static final int VIDEO_PIXEL_FMT_UNKNOWN = 5;

        public static final int VIDEO_ROTATION_0 = 0;
        public static final int VIDEO_ROTATION_1 = 90;
        public static final int VIDEO_ROTATION_2 = 180;
        public static final int VIDEO_ROTATION_3 = 270;

        int bufferType = VIDEO_BUFFER_TYPE_BYTE_BUFFER;
        int pixelFormat = VIDEO_PIXEL_FMT_I420;
        int rotation = VIDEO_ROTATION_0;
        int width;
        int height;
        long pts;
        int textureId;
        ByteBuffer buffer;
        byte[] data;

        public VideoFrame(int pixelFormat, int rotation, int width, int height,
                          long pts) {
            this.pixelFormat = pixelFormat;
            this.rotation = rotation;
            this.width = width;
            this.height = height;
            this.pts = pts;
        }

        public VideoFrame(int pixelFormat, int rotation, int width, int height,
                          long pts, ByteBuffer buffer) {
            this(pixelFormat, rotation, width, height, pts);
            this.bufferType = VIDEO_BUFFER_TYPE_BYTE_BUFFER;
            this.buffer = buffer;
        }

        public VideoFrame(int pixelFormat, int rotation, int width, int height,
                          long pts, byte[] data) {
            this(pixelFormat, rotation, width, height, pts);
            this.bufferType = VIDEO_BUFFER_TYPE_BYTE_ARRAY;
            this.data = data;
        }

        public VideoFrame(int pixelFormat, int rotation, int width, int height,
                          long pts, int textureId) {
            this(pixelFormat, rotation, width, height, pts);
            this.bufferType = VIDEO_BUFFER_TYPE_TEXTURE_ID;
            this.textureId = textureId;
        }
    }
}
