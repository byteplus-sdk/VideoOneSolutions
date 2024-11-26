package com.vertc.api.example.examples.video;

import android.content.Context;
import android.content.Intent;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;
import android.widget.EditText;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;

import com.ss.bytertc.base.media.screen.RXScreenCaptureService;
import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.ScreenVideoEncoderConfig;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.data.ScreenMediaType;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler;
import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.RTCRoomStats;
import com.ss.bytertc.engine.type.StreamRemoveReason;
import com.ss.bytertc.engine.type.VideoDeviceType;
import com.vertc.api.example.R;
import com.vertc.api.example.base.ExampleBaseActivity;
import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.annotation.ApiExample;
import com.vertc.api.example.databinding.ActivityScreenShareBinding;
import com.vertc.api.example.utils.RTCHelper;
import com.vertc.api.example.utils.ToastUtil;

@ApiExample(title = "Screen Share", category = ExampleCategory.VIDEO, order = 5)
public class ScreenShareActivity extends ExampleBaseActivity {

    private static final String TAG = "ScreenShareActivity";

    private boolean isJoined;
    private boolean isSharing;
    private RTCVideo rtcVideo;
    private RTCRoom rtcRoom;
    private String roomID;
    private String userID;

    ActivityScreenShareBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityScreenShareBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        rtcVideo = RTCHelper.createRTCVideo(this, rtcVideoEventHandler, "screen-share");
        rtcVideo.startVideoCapture();
        rtcVideo.startAudioCapture();

        setLocalRenderView();

        binding.btnJoinRoom.setOnClickListener(v -> {
            String roomId = binding.roomIdInput.getText().toString();
            if (!RTCHelper.checkValid(roomId)) {
                ToastUtil.showToast(this, R.string.toast_check_valid_false);
                return;
            }

            String userId = binding.userIdInput.getText().toString();
            if (!RTCHelper.checkValid(userId)) {
                ToastUtil.showToast(this, R.string.toast_check_valid_false);
                return;
            }

            userID = userId;
            if (isJoined) {
                leaveRoom();

                isJoined = false;
                binding.btnJoinRoom.setText(R.string.button_join_room);
                return;
            }

            joinRoom(roomId);
            isJoined = true;
            binding.btnJoinRoom.setText(R.string.button_leave_room);
        });

        binding.btnStartScreenShare.setOnClickListener(v -> {
            if (isSharing) {
                stopScreenShare();
                return;
            }

            startScreenShare();
        });
    }

    private void startScreenShare() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            ToastUtil.showToast(this, R.string.msg_sharing_low_os_version);
            return;
        }

        MediaProjectionManager projectionManager = (MediaProjectionManager) getSystemService(Context.MEDIA_PROJECTION_SERVICE);
        assert projectionManager != null;
        mediaProjectionLauncher.launch(projectionManager.createScreenCaptureIntent());
    }

    final ActivityResultLauncher<Intent> mediaProjectionLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() == RESULT_OK) {
                    startScreenCapture(result.getData());

                    if (rtcRoom != null) {
                        rtcRoom.publishScreen(MediaStreamType.RTC_MEDIA_STREAM_TYPE_BOTH);
                    }
                }

                isSharing = result.getResultCode() == RESULT_OK;
                if (isSharing) {
                    binding.btnStartScreenShare.setText(R.string.button_stop_screen_sharing);
                } else {
                    binding.btnStartScreenShare.setText(R.string.button_start_screen_sharing);
                }
            });

    private void stopScreenShare() {
        isSharing = false;
        binding.btnStartScreenShare.setText(R.string.button_start_screen_sharing);

        if (rtcRoom != null) {
            rtcRoom.unpublishScreen(MediaStreamType.RTC_MEDIA_STREAM_TYPE_BOTH);
        }
        rtcVideo.stopScreenCapture();
    }

    private void startScreenCapture(Intent data) {
        startRXScreenCaptureService(data);
        ScreenVideoEncoderConfig config = new ScreenVideoEncoderConfig();
        config.width = 720;
        config.height = 1280;
        config.frameRate = 15;
        config.maxBitrate = 1600;
        rtcVideo.setScreenVideoEncoderConfig(config);
        rtcVideo.startScreenCapture(ScreenMediaType.SCREEN_MEDIA_TYPE_VIDEO_AND_AUDIO, data);
    }

    private void startRXScreenCaptureService(@Nullable Intent data) {
        Context context = getApplicationContext();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Intent iData = new Intent();
            iData.putExtra(RXScreenCaptureService.KEY_LARGE_ICON, R.mipmap.screen_sharing_icon);
            iData.putExtra(RXScreenCaptureService.KEY_SMALL_ICON, R.mipmap.screen_sharing_icon);
            iData.putExtra(RXScreenCaptureService.KEY_LAUNCH_ACTIVITY, this.getClass().getCanonicalName());
            iData.putExtra(RXScreenCaptureService.KEY_CONTENT_TEXT, R.string.msg_sharing);
            iData.putExtra(RXScreenCaptureService.KEY_RESULT_DATA, data);
            context.startForegroundService(RXScreenCaptureService.getServiceIntent(context, RXScreenCaptureService.COMMAND_LAUNCH, iData));
        }
    }

    private void joinRoom(String roomId) {
        this.roomID = roomId;
        rtcRoom = rtcVideo.createRTCRoom(roomId);
        rtcRoom.setRTCRoomEventHandler(rtcRoomEventHandler);
        requestRoomToken(roomId, userID, token -> {
            UserInfo userInfo = new UserInfo(userID, "");
            boolean isAutoPublish = false;
            boolean isAutoSubscribeAudio = true;
            boolean isAutoSubscribeVideo = true;
            RTCRoomConfig roomConfig = new RTCRoomConfig(ChannelProfile.CHANNEL_PROFILE_CHAT_ROOM, isAutoPublish, isAutoSubscribeAudio, isAutoSubscribeVideo);
            rtcRoom.joinRoom(token, userInfo, roomConfig);
            rtcRoom.publishStream(MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);

            if (isSharing) {
                rtcRoom.publishScreen(MediaStreamType.RTC_MEDIA_STREAM_TYPE_BOTH);
            }
        });
    }

    private void setLocalRenderView() {
        TextureView localTextureView = new TextureView(this);
        binding.localContainer.removeAllViews();
        binding.localContainer.addView(localTextureView);

        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = localTextureView;
        videoCanvas.renderMode = VideoCanvas.RENDER_MODE_HIDDEN;
        rtcVideo.setLocalVideoCanvas(StreamIndex.STREAM_INDEX_MAIN, videoCanvas);
    }

    private void setRemoteRenderView(String uid) {
        TextureView textureView = new TextureView(this);

        binding.remoteContainer.removeAllViews();
        binding.remoteContainer.addView(textureView);

        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = textureView;
        videoCanvas.renderMode = VideoCanvas.RENDER_MODE_HIDDEN;

        RemoteStreamKey remoteStreamKey = new RemoteStreamKey(roomID, uid, StreamIndex.STREAM_INDEX_SCREEN);
        rtcVideo.setRemoteVideoCanvas(remoteStreamKey, videoCanvas);
    }

    private void removeRemoteView(String uid) {
        binding.remoteContainer.removeAllViews();

        RemoteStreamKey remoteStreamKey = new RemoteStreamKey(roomID, uid, StreamIndex.STREAM_INDEX_SCREEN);
        rtcVideo.setRemoteVideoCanvas(remoteStreamKey, null);
    }

    private void leaveRoom() {
        if (rtcRoom != null) {
            if (isSharing) {
                rtcRoom.unpublishScreen(MediaStreamType.RTC_MEDIA_STREAM_TYPE_BOTH);
            }
            rtcRoom.leaveRoom();
            rtcRoom.destroy();
            rtcRoom = null;
        }
        this.roomID = null;
    }

    IRTCVideoEventHandler rtcVideoEventHandler = new IRTCVideoEventHandler() {
        @Override
        public void onVideoDeviceStateChanged(String deviceId, VideoDeviceType deviceType, int deviceState, int deviceError) {
            Log.i(TAG, "onVideoDeviceStateChanged, type: " + deviceType + " state:" + deviceState);
        }
    };

    IRTCRoomEventHandler rtcRoomEventHandler = new IRTCRoomEventHandler() {
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            String info = String.format("roomId:%s, uid:%s, state:%d, extraInfo:%s", roomId, uid, state, extraInfo);
            ToastUtil.showToast(ScreenShareActivity.this, info);
        }

        @Override
        public void onUserPublishScreen(String uid, MediaStreamType type) {
            super.onUserPublishScreen(uid, type);
            Log.i(TAG, "onUserPublishScreen, uid: " + uid + " type:" + type);
            ToastUtil.showToast(ScreenShareActivity.this, "onUserPublishScreen, uid: " + uid + " type:" + type);
            runOnUiThread(() -> {
                setRemoteRenderView(uid);
            });
        }

        @Override
        public void onUserUnpublishScreen(String uid, MediaStreamType type, StreamRemoveReason reason) {
            super.onUserUnpublishScreen(uid, type, reason);
            Log.i(TAG, "onUserUnpublishScreen, uid: " + uid + " type:" + type);
            ToastUtil.showToast(ScreenShareActivity.this, "onUserUnpublishScreen, uid: " + uid + " type:" + type);
            runOnUiThread(() -> {
                removeRemoteView(uid);
            });
        }

        @Override
        public void onLeaveRoom(RTCRoomStats stats) {
            super.onLeaveRoom(stats);
            ToastUtil.showLongToast(ScreenShareActivity.this, "onLeaveRoom, stats:" + stats);
        }

        @Override
        public void onUserLeave(String uid, int reason) {
            super.onUserLeave(uid, reason);
            runOnUiThread(() -> {
                removeRemoteView(uid);
            });
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();

        leaveRoom();

        if (rtcVideo != null) {
            rtcVideo.stopAudioCapture();
            rtcVideo.stopVideoCapture();
            rtcVideo.stopScreenCapture();
        }

        RTCVideo.destroyRTCVideo();
    }
}