// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live.push;

import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioChannel.VeLiveAudioChannelMono;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioChannel.VeLiveAudioChannelStereo;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate16000;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate32000;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate44100;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate48000;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate8000;

import androidx.annotation.NonNull;

import com.bytedance.realx.video.YuvHelper;
import com.ss.avframework.live.VeLiveAudioFrame;
import com.ss.avframework.live.VeLivePusher;
import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.live.VeLiveVideoFrame;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.data.AudioChannel;
import com.ss.bytertc.engine.data.AudioFormat;
import com.ss.bytertc.engine.data.AudioFrameCallbackMethod;
import com.ss.bytertc.engine.data.AudioSampleRate;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.data.VideoRotation;
import com.ss.bytertc.engine.utils.IAudioFrame;
import com.ss.bytertc.engine.video.IVideoSink;
import com.ss.bytertc.engine.video.VideoFrame;
import com.vertcdemo.solution.interactivelive.core.live.adapter.AudioSink;
import com.vertcdemo.solution.interactivelive.core.live.adapter.VideoSink;

import java.nio.ByteBuffer;

public class LivePusherAVConsumer {
    private final VeLivePusher livePusher;

    public LivePusherAVConsumer(VeLivePusher livePusher) {
        this.livePusher = livePusher;
    }

    public void start(RTCVideo rtcVideo) {
        rtcVideo.setLocalVideoSink(StreamIndex.STREAM_INDEX_MAIN,
                new VideoSink(this::pushVideoFrameToLiveCore),
                IVideoSink.PixelFormat.I420);

        rtcVideo.registerAudioFrameObserver(new AudioSink(this::pushAudioFrameToLiveCore));
        final AudioFormat audioFormat = new AudioFormat(AudioSampleRate.AUDIO_SAMPLE_RATE_44100, AudioChannel.AUDIO_CHANNEL_STEREO);
        rtcVideo.enableAudioFrameCallback(AudioFrameCallbackMethod.AUDIO_FRAME_CALLBACK_RECORD, audioFormat);
    }

    public void stop(RTCVideo rtcVideo) {
        rtcVideo.setLocalVideoSink(StreamIndex.STREAM_INDEX_MAIN,
                null,
                IVideoSink.PixelFormat.I420);

        rtcVideo.disableAudioFrameCallback(AudioFrameCallbackMethod.AUDIO_FRAME_CALLBACK_RECORD);
        rtcVideo.registerAudioFrameObserver(null);
    }

    void pushAudioFrameToLiveCore(IAudioFrame audioFrame) {
        VeLiveAudioFrame frame = new VeLiveAudioFrame(
                convertFrom(audioFrame.sample_rate()),
                convertFrom(audioFrame.channel()),
                System.currentTimeMillis() * 1000,
                audioFrame.getDataBuffer());
        livePusher.pushExternalAudioFrame(frame);
    }

    private ByteBuffer dstBuffer = ByteBuffer.allocateDirect(0);
    private int lastWidth = 0;
    private int lastHeight = 0;

    private void pushVideoFrameToLiveCore(VideoFrame videoFrame) {
        final int width = videoFrame.getWidth();
        final int height = videoFrame.getHeight();

        if (lastWidth != width || lastHeight != height) { // Size changed, reallocate the buffer
            final int chromaHeight = (height + 1) / 2;
            final int chromaWidth = (width + 1) / 2;
            final int bufferSize = width * height + chromaWidth * chromaHeight * 2;
            dstBuffer = ByteBuffer.allocateDirect(bufferSize);

            lastWidth = width;
            lastHeight = height;
        } else {
            dstBuffer.clear();
        }

        final VideoRotation rotation = videoFrame.getRotation();
        YuvHelper.I420Rotate(videoFrame.getPlaneData(0), videoFrame.getPlaneStride(0),
                videoFrame.getPlaneData(1), videoFrame.getPlaneStride(1),
                videoFrame.getPlaneData(2), videoFrame.getPlaneStride(2),
                dstBuffer, width, height, rotation.value());
        dstBuffer.position(0);

        final boolean needSwapWidthHeight = (rotation == VideoRotation.VIDEO_ROTATION_90 || rotation == VideoRotation.VIDEO_ROTATION_270);
        final int dstWidth = needSwapWidthHeight ? height : width;
        final int dstHeight = needSwapWidthHeight ? width : height;

        VeLiveVideoFrame liveVideoFrame = new VeLiveVideoFrame(
                dstWidth,
                dstHeight,
                System.currentTimeMillis() * 1000,
                dstBuffer
        );
        livePusher.pushExternalVideoFrame(liveVideoFrame);
        liveVideoFrame.release();
    }

    private static VeLivePusherDef.VeLiveAudioSampleRate convertFrom(@NonNull AudioSampleRate rtcAudioSampleRate) {
        switch (rtcAudioSampleRate) {
            case AUDIO_SAMPLE_RATE_8000:
                return VeLiveAudioSampleRate8000;
            case AUDIO_SAMPLE_RATE_16000:
                return VeLiveAudioSampleRate16000;
            case AUDIO_SAMPLE_RATE_32000:
                return VeLiveAudioSampleRate32000;
            case AUDIO_SAMPLE_RATE_48000:
                return VeLiveAudioSampleRate48000;
            case AUDIO_SAMPLE_RATE_44100:
            default:
                return VeLiveAudioSampleRate44100;
        }
    }

    private static VeLivePusherDef.VeLiveAudioChannel convertFrom(@NonNull AudioChannel rtcAudioChannel) {
        if (rtcAudioChannel == AudioChannel.AUDIO_CHANNEL_MONO) {
            return VeLiveAudioChannelMono;
        } else {
            return VeLiveAudioChannelStereo;
        }
    }
}
