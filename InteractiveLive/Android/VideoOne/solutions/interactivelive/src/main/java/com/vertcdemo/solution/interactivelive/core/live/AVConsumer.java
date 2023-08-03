// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import com.ss.avframework.livestreamv2.core.LiveCore;
import com.ss.avframework.opengl.YuvHelper;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.data.AudioChannel;
import com.ss.bytertc.engine.data.AudioFormat;
import com.ss.bytertc.engine.data.AudioFrameCallbackMethod;
import com.ss.bytertc.engine.data.AudioSampleRate;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.utils.IAudioFrame;
import com.ss.bytertc.engine.video.IVideoSink;
import com.ss.bytertc.engine.video.VideoFrame;

import java.nio.ByteBuffer;

public class AVConsumer {
    private static final String TAG = "AVConsumer";

    private final LiveCore liveCore;

    AVConsumer(LiveCore liveCore) {
        this.liveCore = liveCore;
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
        final ByteBuffer buffer = audioFrame.getDataBuffer();
        final int sampleHZ = audioFrame.sample_rate().value();
        final int channel = audioFrame.channel().value();
        final int bitWidth = 16;
        final int sampleCounts = audioFrame.data_size() / 2;
        final long timestampUS = audioFrame.timestamp_us();
        liveCore.pushAudioFrame(buffer, sampleHZ, channel, bitWidth, sampleCounts, timestampUS);
    }

    private void pushVideoFrameToLiveCore(VideoFrame videoFrame) {
        final int width = videoFrame.getWidth();
        final int height = videoFrame.getHeight();
        final int chromaHeight = (height + 1) / 2;
        final int chromaWidth = (width + 1) / 2;
        int bufferSize = width * height + chromaWidth * chromaHeight * 2;
        final ByteBuffer dstBuffer = ByteBuffer.allocateDirect(bufferSize);

        YuvHelper.I420Rotate(videoFrame.getPlaneData(0), videoFrame.getPlaneStride(0),
                videoFrame.getPlaneData(1), videoFrame.getPlaneStride(1),
                videoFrame.getPlaneData(2), videoFrame.getPlaneStride(2),
                dstBuffer, width, height, videoFrame.getRotation().value());

        dstBuffer.position(0);
        liveCore.pushVideoFrame(dstBuffer,
                videoFrame.getHeight(),
                videoFrame.getWidth(),
                0,
                videoFrame.getTimeStampUs());
    }
}
