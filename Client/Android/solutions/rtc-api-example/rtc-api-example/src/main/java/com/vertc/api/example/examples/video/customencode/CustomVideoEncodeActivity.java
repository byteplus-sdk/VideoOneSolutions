package com.vertc.api.example.examples.video.customencode;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.data.VideoSourceType;
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler;
import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.RTCRoomStats;
import com.vertc.api.example.R;
import com.vertc.api.example.base.ExampleBaseActivity;
import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.annotation.ApiExample;
import com.vertc.api.example.databinding.ActivityCustomVideoEncodeBinding;
import com.vertc.api.example.utils.RTCHelper;
import com.vertc.api.example.utils.ToastUtil;

@ApiExample(title = "Custom Video Encode", category = ExampleCategory.VIDEO, order = 8)
public class CustomVideoEncodeActivity extends ExampleBaseActivity {

    private static final String TAG = "EncodeVideoFrame";

    RTCVideo rtcVideo;
    RTCRoom rtcRoom;
    boolean isJoined;
    private String roomID;

    VideoCaptureCamera videoCaptureCamera;
    TextureView textureView;

    ActivityCustomVideoEncodeBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityCustomVideoEncodeBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setTitle(R.string.title_encode_video_frame);

        initUI();
        rtcVideo = RTCHelper.createRTCVideo(this, rtcVideoEventHandler, "custom-video-encode");
        rtcVideo.startAudioCapture();
        setLocalRenderView();
        videoCaptureCamera = new VideoCaptureCamera(rtcVideo, textureView);
        textureView.setSurfaceTextureListener(videoCaptureCamera);

        rtcVideo.setVideoSourceType(StreamIndex.STREAM_INDEX_MAIN, VideoSourceType.VIDEO_SOURCE_TYPE_ENCODED_WITHOUT_SIMULCAST);
        int ret = rtcVideo.setExternalVideoEncoderEventHandler(videoCaptureCamera);
        Log.i(TAG, "handler ret: " + ret);
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

    }

    private void setLocalRenderView() {
        textureView = new TextureView(this);
        binding.localViewContainer.removeAllViews();
        binding.localViewContainer.addView(textureView);
    }

    private void setRemoteRenderView(String uid) {
        TextureView remoteTextureView = new TextureView(this);
        binding.remoteViewContainer.removeAllViews();
        binding.remoteViewContainer.addView(remoteTextureView);
        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = remoteTextureView;
        videoCanvas.renderMode = VideoCanvas.RENDER_MODE_HIDDEN;

        RemoteStreamKey remoteStreamKey = new RemoteStreamKey(roomID, uid, StreamIndex.STREAM_INDEX_MAIN);
        rtcVideo.setRemoteVideoCanvas(remoteStreamKey, videoCanvas);
    }

    private void joinRoom(String roomId) {
        this.roomID = roomId;
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

    IRTCRoomEventHandler rtcRoomEventHandler = new IRTCRoomEventHandler() {
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            String info = String.format("roomId:%s, uid:%s, state:%d, extraInfo:%s", roomId, uid, state, extraInfo);
            ToastUtil.showToast(CustomVideoEncodeActivity.this, info);
        }

        @Override
        public void onLeaveRoom(RTCRoomStats stats) {
            super.onLeaveRoom(stats);
            ToastUtil.showLongToast(CustomVideoEncodeActivity.this, "onLeaveRoom, stats:" + stats.toString());
        }

        @Override
        public void onUserPublishStream(String uid, MediaStreamType type) {
            super.onUserPublishStream(uid, type);
            runOnUiThread(() -> {
                setRemoteRenderView(uid);
            });
        }
    };

    IRTCVideoEventHandler rtcVideoEventHandler = new IRTCVideoEventHandler() {};

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (rtcVideo != null) {
            rtcVideo.stopAudioCapture();
            rtcVideo.stopVideoCapture();
        }
        if (rtcRoom != null) {
            rtcRoom.destroy();
            rtcRoom = null;
        }
        if (videoCaptureCamera != null) {
            videoCaptureCamera.releaseCamera();
        }
        RTCVideo.destroyRTCVideo();
    }
}