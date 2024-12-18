package com.vertc.api.example.examples.video;

import android.os.Bundle;
import android.view.TextureView;
import android.view.View;
import android.widget.AdapterView;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.data.MirrorType;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.data.VideoFrameInfo;
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler;
import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.RTCRoomStats;
import com.ss.bytertc.engine.type.StreamRemoveReason;
import com.ss.bytertc.engine.video.VideoCaptureConfig;
import com.vertc.api.example.R;
import com.vertc.api.example.adapter.OnItemSelectedAdapter;
import com.vertc.api.example.base.ExampleBaseActivity;
import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.annotation.ApiExample;
import com.vertc.api.example.databinding.ActivityVideoConfigBinding;
import com.vertc.api.example.utils.IMEUtils;
import com.vertc.api.example.utils.RTCHelper;
import com.vertc.api.example.utils.ToastUtil;

import java.util.Locale;

/**
 * <pre>
 * Function name: BytePlusRTC common video configuration.
 * Function brief: Modify the commonly used video capture and encoding parameters.
 * Notes:
 *   1. For demonstration purposes, all tokens for the functionalities are generated by the client-side TokenGenerator class. However, please adjust accordingly based on the specific circumstances when integrating in a real environment.
 * Reference document: https://docs.byteplus.com/en/docs/byteplus-rtc/docs-70122
 * </pre>
 */
@ApiExample(title = "Video configuration", category = ExampleCategory.VIDEO, order = 2)
public class VideoCommonConfigActivity extends ExampleBaseActivity {

    private RTCVideo rtcVideo;
    private RTCRoom rtcRoom;
    private String roomId;
    private String curRemoteUid;

    ActivityVideoConfigBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityVideoConfigBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        binding.content.setOnClickListener(IMEUtils::closeIME);

        initUI(binding);

        rtcVideo = RTCHelper.createRTCVideo(this, rtcVideoEventHandler, "video-config-common");
        setLocalRenderView(VideoCanvas.RENDER_MODE_HIDDEN);

        rtcVideo.startVideoCapture();
        rtcVideo.startAudioCapture();

        binding.btnJoinRoom.setOnClickListener(v -> {
            if (v.isSelected()) {
                leaveRoom();

                v.setSelected(false);
                binding.btnJoinRoom.setText(R.string.button_join_room);
                return;
            }
            String roomId = binding.roomIdInput.getText().toString();
            if (!RTCHelper.checkValid(roomId)) {
                ToastUtil.showToast(this, R.string.toast_check_valid_false);
                return;
            }
            joinRoom(roomId);
            v.setSelected(true);
            binding.btnJoinRoom.setText(R.string.button_leave_room);
        });
    }

    private void initUI(ActivityVideoConfigBinding binding) {
        binding.localRenderModeSpinner.setOnItemSelectedListener(new OnItemSelectedAdapter() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = (String) binding.localRenderModeSpinner.getSelectedItem();
                switch (item) {
                    case "RENDER_MODE_HIDDEN":
                        setLocalRenderView(VideoCanvas.RENDER_MODE_HIDDEN);
                        break;
                    case "RENDER_MODE_FIT":
                        setLocalRenderView(VideoCanvas.RENDER_MODE_FIT);
                        break;
                    case "RENDER_MODE_FILL":
                        setLocalRenderView(VideoCanvas.RENDER_MODE_FILL);
                        break;
                }
            }
        });
        binding.remoteRenderModeSpinner.setOnItemSelectedListener(new OnItemSelectedAdapter() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = (String) binding.remoteRenderModeSpinner.getSelectedItem();
                switch (item) {
                    case "RENDER_MODE_HIDDEN":
                        setRemoteRenderView(curRemoteUid, VideoCanvas.RENDER_MODE_HIDDEN);
                        break;
                    case "RENDER_MODE_FIT":
                        setRemoteRenderView(curRemoteUid, VideoCanvas.RENDER_MODE_FIT);
                        break;
                    case "RENDER_MODE_FILL":
                        setRemoteRenderView(curRemoteUid, VideoCanvas.RENDER_MODE_FILL);
                        break;
                }
            }
        });
        binding.mirrorTypeSpinner.setOnItemSelectedListener(new OnItemSelectedAdapter() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = (String) binding.mirrorTypeSpinner.getSelectedItem();
                switch (item) {
                    case "MIRROR_TYPE_NONE":
                        rtcVideo.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_NONE);
                        break;
                    case "MIRROR_TYPE_RENDER":
                        rtcVideo.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER);
                        break;
                    case "MIRROR_TYPE_RENDER_AND_ENCODER":
                        rtcVideo.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER);
                        break;
                }
            }
        });

        binding.btnEncoderConfig.setOnClickListener(v -> setVideoEncoderConfig());
        binding.btnCaptureConfig.setOnClickListener(v -> setVideoCaptureConfig());
    }

    private void joinRoom(String roomId) {
        this.roomId = roomId;
        requestRoomToken(roomId, localUid, token -> {
            rtcRoom = rtcVideo.createRTCRoom(roomId);
            rtcRoom.setRTCRoomEventHandler(rtcRoomEventHandler);
            UserInfo userInfo = new UserInfo(localUid, "");
            boolean isAutoPublish = true;
            boolean isAutoSubscribeAudio = true;
            boolean isAutoSubscribeVideo = true;
            RTCRoomConfig roomConfig = new RTCRoomConfig(
                    ChannelProfile.CHANNEL_PROFILE_CHAT_ROOM,
                    isAutoPublish,
                    isAutoSubscribeAudio,
                    isAutoSubscribeVideo);
            rtcRoom.joinRoom(token, userInfo, roomConfig);
        });
    }

    private void setLocalRenderView(int renderMode) {
        TextureView textureView = new TextureView(this);
        binding.localViewContainer.removeAllViews();
        binding.localViewContainer.addView(textureView);

        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = textureView;
        videoCanvas.renderMode = renderMode;
        rtcVideo.setLocalVideoCanvas(StreamIndex.STREAM_INDEX_MAIN, videoCanvas);
    }

    private void setRemoteRenderView(String uid, int renderMode) {
        TextureView textureView = new TextureView(this);

        binding.remoteViewContainer.removeAllViews();
        binding.remoteViewContainer.addView(textureView);

        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = textureView;
        videoCanvas.renderMode = renderMode;

        RemoteStreamKey remoteStreamKey = new RemoteStreamKey(roomId, uid, StreamIndex.STREAM_INDEX_MAIN);
        rtcVideo.setRemoteVideoCanvas(remoteStreamKey, videoCanvas);
    }

    private void removeRemoteView(String uid) {
        RemoteStreamKey remoteStreamKey = new RemoteStreamKey(roomId, uid, StreamIndex.STREAM_INDEX_MAIN);
        rtcVideo.setRemoteVideoCanvas(remoteStreamKey, null);
    }

    private void setVideoEncoderConfig() {
        String width = binding.encoderWidth.getText().toString();
        String height = binding.encoderHeight.getText().toString();
        String frameRate = binding.encoderFrameRate.getText().toString();
        String minBitrateStr = binding.minBitrate.getText().toString();
        String maxBitrateStr = binding.maxBitrate.getText().toString();

        VideoEncoderConfig config = new VideoEncoderConfig();
        config.width = width.isEmpty() ? 1920 : Integer.parseInt(width);
        config.height = height.isEmpty() ? 1080 : Integer.parseInt(height);
        config.frameRate = frameRate.isEmpty() ? 30 : Integer.parseInt(frameRate);
        if (!minBitrateStr.isEmpty()) {
            config.minBitrate = Integer.parseInt(minBitrateStr);
        }
        if (!maxBitrateStr.isEmpty()) {
            config.maxBitrate = Integer.parseInt(maxBitrateStr);
        }
        switch ((String) binding.encoderPreferenceSpinner.getSelectedItem()) {
            case "MaintainFramerate":
                config.encodePreference = VideoEncoderConfig.EncoderPreference.MAINTAIN_FRAMERATE;
                break;
            case "MaintainQuality":
                config.encodePreference = VideoEncoderConfig.EncoderPreference.MAINTAIN_QUALITY;
                break;
            case "Disabled":
                config.encodePreference = VideoEncoderConfig.EncoderPreference.DISABLED;
                break;
            case "Balance":
                config.encodePreference = VideoEncoderConfig.EncoderPreference.BALANCE;
                break;

        }
        rtcVideo.setVideoEncoderConfig(config);
    }

    private void setVideoCaptureConfig() {
        String width = binding.captureWidth.getText().toString();
        String height = binding.captureHeight.getText().toString();
        String frameRate = binding.captureFrameRate.getText().toString();

        VideoCaptureConfig config = new VideoCaptureConfig();
        switch ((String) binding.capturePreferenceSpinner.getSelectedItem()) {
            case "AUTO":
                config.capturePreference = VideoCaptureConfig.CapturePreference.AUTO;
                break;
            case "MANUAL":
                config.capturePreference = VideoCaptureConfig.CapturePreference.MANUAL;
                break;
            case "AUTO_PERFORMANCE":
                config.capturePreference = VideoCaptureConfig.CapturePreference.AUTO_PERFORMANCE;
                break;
        }
        config.width = width.isEmpty() ? 1920 : Integer.parseInt(width);
        config.height = height.isEmpty() ? 1080 : Integer.parseInt(height);
        config.frameRate = frameRate.isEmpty() ? 30 : Integer.parseInt(frameRate);
        rtcVideo.setVideoCaptureConfig(config);
    }

    IRTCVideoEventHandler rtcVideoEventHandler = new IRTCVideoEventHandler() {
        @Override
        public void onLocalVideoSizeChanged(StreamIndex streamIndex, VideoFrameInfo frameInfo) {
            super.onLocalVideoSizeChanged(streamIndex, frameInfo);
            String info = String.format(Locale.ENGLISH, "onLocalVideoSizeChanged, width:%d, height:%d, rotation:%d", frameInfo.getWidth(), frameInfo.getHeight(), frameInfo.rotation);
            ToastUtil.showToast(VideoCommonConfigActivity.this, info);
        }
    };

    IRTCRoomEventHandler rtcRoomEventHandler = new IRTCRoomEventHandler() {
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            String info = String.format(Locale.ENGLISH, "roomId:%s, uid:%s, state:%d, extraInfo:%s", roomId, uid, state, extraInfo);
            ToastUtil.showToast(VideoCommonConfigActivity.this, info);
        }

        @Override
        public void onUserPublishStream(String uid, MediaStreamType type) {
            super.onUserPublishStream(uid, type);
            curRemoteUid = uid;
            runOnUiThread(() -> {
                setRemoteRenderView(uid, VideoCanvas.RENDER_MODE_HIDDEN);
            });
        }

        @Override
        public void onUserUnpublishStream(String uid, MediaStreamType type, StreamRemoveReason reason) {
            super.onUserUnpublishStream(uid, type, reason);
            runOnUiThread(() -> {
                removeRemoteView(uid);
            });
        }

        @Override
        public void onUserJoined(UserInfo userInfo, int elapsed) {
            super.onUserJoined(userInfo, elapsed);
            ToastUtil.showToast(VideoCommonConfigActivity.this, "onUserJoined, uid:" + userInfo.getUid());
        }

        @Override
        public void onLeaveRoom(RTCRoomStats stats) {
            super.onLeaveRoom(stats);
            ToastUtil.showLongToast(VideoCommonConfigActivity.this, "onLeaveRoom, stats:" + stats.toString());
        }
    };

    private void leaveRoom() {
        if (rtcRoom != null) {
            rtcRoom.leaveRoom();
            rtcRoom.destroy();
            rtcRoom = null;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        leaveRoom();
        if (rtcVideo != null) {
            rtcVideo.stopAudioCapture();
            rtcVideo.stopVideoCapture();
        }
        RTCVideo.destroyRTCVideo();
    }
}