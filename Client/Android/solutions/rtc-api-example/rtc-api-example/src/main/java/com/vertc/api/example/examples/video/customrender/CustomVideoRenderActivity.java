package com.vertc.api.example.examples.video.customrender;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.data.VideoFrameInfo;
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler;
import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.RTCRoomStats;
import com.ss.bytertc.engine.video.IVideoSink;
import com.ss.bytertc.engine.video.LocalVideoSinkConfig;
import com.vertc.api.example.R;
import com.vertc.api.example.base.ExampleBaseActivity;
import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.annotation.ApiExample;
import com.vertc.api.example.databinding.ActivityCustomVideoRenderBinding;
import com.vertc.api.example.utils.RTCHelper;
import com.vertc.api.example.utils.ToastUtil;

@ApiExample(title = "Custom Video Render", category = ExampleCategory.VIDEO, order = 7)
public class CustomVideoRenderActivity extends ExampleBaseActivity {

    RTCVideo rtcVideo;
    RTCRoom rtcRoom;
    boolean isJoined;
    private CustomRenderView videoSink;

    ActivityCustomVideoRenderBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityCustomVideoRenderBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setTitle(R.string.title_video_render);

        initUI();

        rtcVideo = RTCHelper.createRTCVideo(this, rtcVideoEventHandler, "custom-video-render");
        rtcVideo.startVideoCapture();
        rtcVideo.startAudioCapture();
    }

    private void initUI() {
        videoSink = new CustomRenderView(this);

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

        binding.btnStartRender.setOnClickListener(v -> {
            renderLocalVideo();
        });

        binding.btnStopRender.setOnClickListener(v -> {
            stopLocalRender();
        });
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

    private void renderLocalVideo() {
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        binding.localViewContainer.removeAllViews();
        binding.localViewContainer.addView((View) videoSink, params);
        LocalVideoSinkConfig config = new LocalVideoSinkConfig();
        String format = binding.videoFormatSpinner.getSelectedItem().toString();
        if ("I420".equals(format)) {
            config.pixelFormat = IVideoSink.PixelFormat.I420;
        } else {
            config.pixelFormat = IVideoSink.PixelFormat.RGBA;
        }
        rtcVideo.setLocalVideoRender(StreamIndex.STREAM_INDEX_MAIN, videoSink, config);
    }

    private void stopLocalRender() {
        binding.localViewContainer.removeAllViews();
        LocalVideoSinkConfig config = new LocalVideoSinkConfig();
        String format = binding.videoFormatSpinner.getSelectedItem().toString();
        if ("I420".equals(format)) {
            config.pixelFormat = IVideoSink.PixelFormat.I420;
        } else {
            config.pixelFormat = IVideoSink.PixelFormat.Original;
        }
        rtcVideo.setLocalVideoRender(StreamIndex.STREAM_INDEX_MAIN, null, config);
    }

    IRTCRoomEventHandler rtcRoomEventHandler = new IRTCRoomEventHandler() {
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            String info = String.format("roomId:%s, uid:%s, state:%d, extraInfo:%s", roomId, uid, state, extraInfo);
            ToastUtil.showToast(CustomVideoRenderActivity.this, info);
        }

        @Override
        public void onLeaveRoom(RTCRoomStats stats) {
            super.onLeaveRoom(stats);
            ToastUtil.showLongToast(CustomVideoRenderActivity.this, "onLeaveRoom, stats:" + stats.toString());
        }
    };

    IRTCVideoEventHandler rtcVideoEventHandler = new IRTCVideoEventHandler() {
        @Override
        public void onFirstLocalVideoFrameCaptured(StreamIndex streamIndex, VideoFrameInfo frameInfo) {
            super.onFirstLocalVideoFrameCaptured(streamIndex, frameInfo);
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (rtcVideo != null) {
            rtcVideo.stopAudioCapture();
            rtcVideo.stopVideoCapture();
        }
        RTCVideo.destroyRTCVideo();
        if (videoSink != null) {
            videoSink.release();
            videoSink = null;
        }
    }
}
