package com.vertc.api.example.examples.audio;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;

import androidx.annotation.NonNull;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.data.AudioChannel;
import com.ss.bytertc.engine.data.AudioSampleRate;
import com.ss.bytertc.engine.data.AudioSourceType;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler;
import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.RTCRoomStats;
import com.ss.bytertc.engine.utils.AudioFrame;
import com.vertc.api.example.R;
import com.vertc.api.example.base.ExampleBaseActivity;
import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.annotation.ApiExample;
import com.vertc.api.example.databinding.ActivityCustomAudioCaptureBinding;
import com.vertc.api.example.utils.RTCHelper;
import com.vertc.api.example.utils.ToastUtil;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

@ApiExample(title = "Custom Audio Capture", category = ExampleCategory.AUDIO, order = 5)
public class CustomAudioCaptureActivity extends ExampleBaseActivity {

    private static final String RESOURCE_NAME = "rtc_audio_16k_mono.pcm";

    private static final String TAG = "CustomAudioCapture";

    private boolean isJoined;

    private RTCVideo rtcVideo;
    private RTCRoom rtcRoom;

    private byte[] pcmData;

    private final ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();

    ActivityCustomAudioCaptureBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityCustomAudioCaptureBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        initUI();

        rtcVideo = RTCHelper.createRTCVideo(this, rtcVideoEventHandler, "custom-audio-capture");
        rtcVideo.startVideoCapture();
        rtcVideo.setAudioSourceType(AudioSourceType.AUDIO_SOURCE_TYPE_EXTERNAL);

        setLocalRenderView();

        executor.submit(() -> {
            pcmData = readPcmContent(this);
        });
    }

    private void initUI() {
        binding.btnJoinRoom.setOnClickListener(v -> {
            String roomId = binding.roomIdInput.getText().toString();
            if (!RTCHelper.checkValid(roomId)) {
                ToastUtil.showToast(this, R.string.toast_check_valid_false);
                return;
            }

            if (isJoined) {
                leaveRoom();

                isJoined = false;
                binding.btnJoinRoom.setText(R.string.button_join_room);
                return;
            }
            if (TextUtils.isEmpty(roomId)) {
                ToastUtil.showToast(this, "roomID is null");
                return;
            }
            joinRoom(roomId);
            isJoined = true;
            binding.btnJoinRoom.setText(R.string.button_leave_room);
        });

        binding.btnStartPush.setOnClickListener(v -> startPushPCM());
        binding.btnStopPush.setOnClickListener(v -> stopPushPCM());
    }

    /**
     * set local render view, support TextureView and SurfaceView
     */
    private void setLocalRenderView() {
        TextureView textureView = new TextureView(this);
        binding.localViewContainer.removeAllViews();
        binding.localViewContainer.addView(textureView);

        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = textureView;
        videoCanvas.renderMode = VideoCanvas.RENDER_MODE_HIDDEN;
        rtcVideo.setLocalVideoCanvas(StreamIndex.STREAM_INDEX_MAIN, videoCanvas);
    }


    private ScheduledFuture<?> pushTask;

    private void startPushPCM() {
        if (pushTask == null) {
            pushTask = executor.scheduleAtFixedRate(
                    new PushAudioFrameTask(rtcVideo, pcmData),
                    10,
                    10,
                    TimeUnit.MILLISECONDS);
        }
    }

    private void stopPushPCM() {
        if (pushTask != null) {
            pushTask.cancel(true);
            pushTask = null;
        }
    }

    static class PushAudioFrameTask implements Runnable {
        private final RTCVideo rtcVideo;

        private boolean isFirstPush = true;

        private final byte[] pcmData;
        private final int dataLength;

        private int readingOffset = 0;

        private final AudioFrame audioFrame;

        public PushAudioFrameTask(RTCVideo rtcVideo, byte[] pcmData) {
            this.rtcVideo = rtcVideo;
            this.pcmData = pcmData;
            this.dataLength = pcmData.length;

            audioFrame = new AudioFrame();
            audioFrame.channel = AudioChannel.AUDIO_CHANNEL_MONO;
            audioFrame.sampleRate = AudioSampleRate.AUDIO_SAMPLE_RATE_16000;
        }

        @Override
        public void run() {
            // data size of each 10ms
            int size = 16 * 10;
            if (isFirstPush) {
                // It is recommended to pass in 200ms buffer data for the first time to avoid noise
                size = size * 20;
                isFirstPush = false;
            }

            int nRead = Math.min(size * 2, dataLength - readingOffset);
            if (nRead == 0) {
                readingOffset = 0;
                return;
            }

            byte[] buffer = Arrays.copyOfRange(pcmData, readingOffset, readingOffset + nRead);
            readingOffset += nRead;

            Log.i(TAG, "offset:" + readingOffset + " read:" + nRead);

            audioFrame.samples = size;
            audioFrame.buffer = buffer;
            rtcVideo.pushExternalAudioFrame(audioFrame);
        }
    }

    private void joinRoom(String roomId) {
        rtcRoom = rtcVideo.createRTCRoom(roomId);
        rtcRoom.setRTCRoomEventHandler(rtcRoomEventHandler);
        requestRoomToken(roomId, localUid, token -> {
            UserInfo userInfo = new UserInfo(localUid, "");
            boolean isAutoPublish = true;
            boolean isAutoSubscribeAudio = true;
            boolean isAutoSubscribeVideo = true;
            RTCRoomConfig roomConfig = new RTCRoomConfig(ChannelProfile.CHANNEL_PROFILE_CHAT_ROOM, isAutoPublish, isAutoSubscribeAudio, isAutoSubscribeVideo);
            rtcRoom.joinRoom(token, userInfo, roomConfig);
        });
    }

    private void leaveRoom() {
        if (rtcRoom != null) {
            rtcRoom.leaveRoom();
            rtcRoom.destroy();
            rtcRoom = null;
        }
    }

    IRTCVideoEventHandler rtcVideoEventHandler = new IRTCVideoEventHandler() {
    };

    IRTCRoomEventHandler rtcRoomEventHandler = new IRTCRoomEventHandler() {
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            String info = String.format("onRoomStateChanged,roomId:%s, uid:%s, state:%d, extraInfo:%s", roomId, uid, state, extraInfo);
            ToastUtil.showLongToast(CustomAudioCaptureActivity.this, info);
        }

        @Override
        public void onLeaveRoom(RTCRoomStats stats) {
            super.onLeaveRoom(stats);
            ToastUtil.showLongToast(CustomAudioCaptureActivity.this, "onLeaveRoom, stats:" + stats.toString());
        }

        @Override
        public void onUserJoined(UserInfo userInfo, int elapsed) {
            super.onUserJoined(userInfo, elapsed);
            ToastUtil.showToast(CustomAudioCaptureActivity.this, "onUserJoined, uid:" + userInfo.getUid());
        }

        @Override
        public void onUserLeave(String uid, int reason) {
            super.onUserLeave(uid, reason);
            String info = String.format("onUserLeave, uid:%s, reason:%s", uid, reason + "");
            ToastUtil.showLongToast(CustomAudioCaptureActivity.this, info);
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();

        executor.shutdown();

        leaveRoom();

        if (rtcVideo != null) {
            rtcVideo.stopAudioCapture();
            rtcVideo.stopVideoCapture();
        }

        RTCVideo.destroyRTCVideo();
    }

    static byte[] readPcmContent(@NonNull Context context) {
        try (InputStream is = context.getAssets().open(RESOURCE_NAME)) {
            ByteArrayOutputStream fos = new ByteArrayOutputStream();
            byte[] buffer = new byte[4096];
            int len;
            while ((len = is.read(buffer)) != -1) {
                fos.write(buffer, 0, len);
            }
            byte[] data = fos.toByteArray();
            Log.i(TAG, "read pcm data: length=" + data.length);

            return data;
        } catch (IOException e) {
            Log.e(TAG, "read pcm data error: ", e);
            throw new RuntimeException(e);
        }
    }
}