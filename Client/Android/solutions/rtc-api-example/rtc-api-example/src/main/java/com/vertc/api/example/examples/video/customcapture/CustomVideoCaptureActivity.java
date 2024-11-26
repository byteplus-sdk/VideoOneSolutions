package com.vertc.api.example.examples.video.customcapture;

import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageInfo;
import androidx.camera.core.ImageProxy;

import com.example.android.camera.utils.YuvByteBuffer;
import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.data.VideoPixelFormat;
import com.ss.bytertc.engine.data.VideoRotation;
import com.ss.bytertc.engine.data.VideoSourceType;
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler;
import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.RTCRoomStats;
import com.ss.bytertc.engine.video.VideoFrame;
import com.ss.bytertc.engine.video.builder.CpuBufferVideoFrameBuilder;
import com.vertc.api.example.R;
import com.vertc.api.example.base.ExampleBaseActivity;
import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.annotation.ApiExample;
import com.vertc.api.example.databinding.ActivityCustomVideoCaptureBinding;
import com.vertc.api.example.utils.RTCHelper;
import com.vertc.api.example.utils.ToastUtil;

import java.nio.ByteBuffer;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@ApiExample(title = "External Video Frame", category = ExampleCategory.VIDEO, order = 6)
public class CustomVideoCaptureActivity extends ExampleBaseActivity {
    private static final String TAG = "CustomVideoCapture";

    private static final String SPINNER_I420 = "I420";
    private static final String SPINNER_NV12 = "NV12";
    private static final String SPINNER_RGBA = "RGBA";

    RTCVideo rtcVideo;
    RTCRoom rtcRoom;
    boolean isJoined;
    private String roomID;

    ActivityCustomVideoCaptureBinding binding;

    private CameraHelper cameraHelper;

    private ExecutorService executor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityCustomVideoCaptureBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        initUI();

        rtcVideo = RTCHelper.createRTCVideo(this, rtcVideoEventHandler, "external-video-frame");
        rtcVideo.startAudioCapture();

        rtcVideo.setVideoSourceType(StreamIndex.STREAM_INDEX_MAIN, VideoSourceType.VIDEO_SOURCE_TYPE_EXTERNAL);
        setLocalRenderView();

        executor = Executors.newSingleThreadExecutor();
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

            joinRoom(roomId);
            isJoined = true;
            binding.btnJoinRoom.setText(R.string.button_leave_room);
        });

        binding.btnStartPush.setOnClickListener(v -> {
            if (cameraHelper != null) {
                Log.w(TAG, "CameraHelper already started");
                return;
            }

            String selectedItem = binding.videoTypeSpinner.getSelectedItem().toString();
            VideoPixelFormat format = switch (selectedItem) {
                case SPINNER_I420 -> VideoPixelFormat.I420;
                case SPINNER_NV12 -> VideoPixelFormat.NV12;
                case SPINNER_RGBA -> VideoPixelFormat.RGBA;
                default -> VideoPixelFormat.I420;
            };

            if (SPINNER_RGBA.equals(selectedItem)) {
                cameraHelper = new CameraHelper(
                        ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888,
                        executor,
                        new RTCVideoFrameConsumer(rtcVideo, format)
                );
            } else {
                cameraHelper = new CameraHelper(
                        ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888,
                        executor,
                        new RTCVideoFrameConsumer(rtcVideo, format)
                );
            }

            cameraHelper.bind(this);
        });

        binding.btnStopPush.setOnClickListener(v -> {
            if (cameraHelper != null) {
                cameraHelper.unbind(this);
            }
            cameraHelper = null;
        });
    }

    private void setLocalRenderView() {
        TextureView textureView = new TextureView(this);
        binding.localViewContainer.removeAllViews();
        binding.localViewContainer.addView(textureView);

        VideoCanvas videoCanvas = new VideoCanvas();
        videoCanvas.renderView = textureView;
        videoCanvas.renderMode = VideoCanvas.RENDER_MODE_HIDDEN;
        rtcVideo.setLocalVideoCanvas(StreamIndex.STREAM_INDEX_MAIN, videoCanvas);
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
            RTCRoomConfig roomConfig = new RTCRoomConfig(
                    ChannelProfile.CHANNEL_PROFILE_CHAT_ROOM,
                    /*isAutoPublish*/true,
                    /*isAutoSubscribeAudio*/true,
                    /*isAutoSubscribeVideo*/true
            );
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

    /**
     * Note: RTCVideo only supports I420, NV12, RGBA format.
     *
     * @see RTCVideo#pushExternalVideoFrame(VideoFrame)
     * @see VideoPixelFormat
     */
    static class RTCVideoFrameConsumer implements ImageAnalysis.Analyzer {
        private final RTCVideo rtcVideo;
        private final VideoPixelFormat rtcVideoFrameFormat;

        RTCVideoFrameConsumer(RTCVideo rtcVideo, VideoPixelFormat format) {
            this.rtcVideo = rtcVideo;
            this.rtcVideoFrameFormat = format;
        }

        private ByteBuffer reuse;

        @Override
        public void analyze(@NonNull ImageProxy image) {
            final ImageInfo info = image.getImageInfo();
            final int width = image.getWidth();
            final int height = image.getHeight();
            final int degrees = info.getRotationDegrees();

            final int imageFormat = image.getFormat();

            if (imageFormat == ImageFormat.YUV_420_888) { // NV21
                YuvByteBuffer yuv = new YuvByteBuffer(image, reuse);
                ByteBuffer data = reuse = yuv.getBuffer();

                if (VideoPixelFormat.NV12 == rtcVideoFrameFormat) {
                    pushNV12ToRTC(data, width, height, degrees);
                } else {
                    pushI420ToRTC(data, width, height, degrees);
                }
            } else if (imageFormat == PixelFormat.RGBA_8888) {
                ByteBuffer data = image.getPlanes()[0].getBuffer();
                pushRGBAToRTC(data, width, height, degrees);
            } else {
                Log.w(TAG, "Unknown image format: " + imageFormat + "(0x" + Integer.toHexString(imageFormat) + ")");
            }

            image.close();
        }

        /**
         * Push RGBA to RTC
         *
         * @param source  RGBA buffer
         * @param width   image width
         * @param height  image height
         * @param degrees image rotation degrees
         */
        private void pushRGBAToRTC(ByteBuffer source, int width, int height, int degrees) {
            CpuBufferVideoFrameBuilder builder = new CpuBufferVideoFrameBuilder(VideoPixelFormat.RGBA)
                    .setWidth(width)
                    .setHeight(height)
                    .setRotation(toRotation(degrees))
                    .setTimeStampUs(System.nanoTime())
                    .setPlaneData(0, source)
                    .setPlaneStride(0, width * 4);

            rtcVideo.pushExternalVideoFrame(builder.build());
        }

        /**
         * Push I420 to RTC
         *
         * @param source  NV21 YUV buffer
         * @param width   image width
         * @param height  image height
         * @param degrees image rotation degrees
         */
        private void pushI420ToRTC(ByteBuffer source, int width, int height, int degrees) {
            int sizeLuma = width * height;
            int sizeChroma = width * height / 4;

            ByteBuffer luma = clipBuffer(source, 0, sizeLuma);
            ByteBuffer chromaUV = clipBuffer(source, sizeLuma, sizeChroma * 2);

            ByteBuffer chromaU = ByteBuffer.allocateDirect(sizeChroma);
            ByteBuffer chromaV = ByteBuffer.allocateDirect(sizeChroma);

            // Split NV21     =>   I420
            //       V U V U       U U U U
            //       V U V U       V V V V
            while (chromaUV.hasRemaining()) {
                byte v = chromaUV.get();
                byte u = chromaUV.get();

                chromaU.put(u);
                chromaV.put(v);
            }

            CpuBufferVideoFrameBuilder builder = new CpuBufferVideoFrameBuilder(VideoPixelFormat.I420)
                    .setWidth(width)
                    .setHeight(height)
                    .setRotation(toRotation(degrees))
                    .setTimeStampUs(System.nanoTime())
                    .setPlaneData(0, luma)
                    .setPlaneStride(0, width)
                    .setPlaneData(1, chromaU)
                    .setPlaneStride(1, width / 2)
                    .setPlaneData(2, chromaV)
                    .setPlaneStride(2, width / 2);

            rtcVideo.pushExternalVideoFrame(builder.build());
        }

        /**
         * Push NV12 to RTC
         *
         * @param source  NV21 YUV buffer
         * @param width   image width
         * @param height  image height
         * @param degrees image rotation degrees
         */
        void pushNV12ToRTC(ByteBuffer source, int width, int height, int degrees) {
            int sizeLuma = width * height;
            int sizeChroma = width * height / 4;

            ByteBuffer luma = clipBuffer(source, 0, sizeLuma);
            ByteBuffer chromaUV = clipBuffer(source, sizeLuma, sizeChroma * 2);

            // Swipe VU to UV
            for (int i = 0; i < chromaUV.limit(); i += 2) {
                byte v = chromaUV.get(i);
                byte u = chromaUV.get(i + 1);

                chromaUV.put(i, u);
                chromaUV.put(i + 1, v);
            }

            CpuBufferVideoFrameBuilder builder = new CpuBufferVideoFrameBuilder(VideoPixelFormat.NV12)
                    .setWidth(width)
                    .setHeight(height)
                    .setRotation(toRotation(degrees))
                    .setTimeStampUs(System.nanoTime())
                    .setPlaneData(0, luma)
                    .setPlaneStride(0, width)
                    .setPlaneData(1, chromaUV)
                    .setPlaneStride(1, width);

            rtcVideo.pushExternalVideoFrame(builder.build());
        }

        private static VideoRotation toRotation(int degrees) {
            return switch (degrees) {
                case 90 -> VideoRotation.VIDEO_ROTATION_90;
                case 180 -> VideoRotation.VIDEO_ROTATION_180;
                case 270 -> VideoRotation.VIDEO_ROTATION_270;
                default -> VideoRotation.VIDEO_ROTATION_0;
            };
        }

        private static ByteBuffer clipBuffer(ByteBuffer buffer, int start, int size) {
            ByteBuffer duplicate = buffer.duplicate();
            duplicate.position(start);
            duplicate.limit(start + size);
            return duplicate.slice();
        }
    }

    private final IRTCRoomEventHandler rtcRoomEventHandler = new IRTCRoomEventHandler() {
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            String info = String.format("roomId:%s, uid:%s, state:%d, extraInfo:%s", roomId, uid, state, extraInfo);
            ToastUtil.showToast(CustomVideoCaptureActivity.this, info);
        }

        @Override
        public void onLeaveRoom(RTCRoomStats stats) {
            super.onLeaveRoom(stats);
            ToastUtil.showLongToast(CustomVideoCaptureActivity.this, "onLeaveRoom, stats:" + stats.toString());
        }

        @Override
        public void onUserPublishStream(String uid, MediaStreamType type) {
            super.onUserPublishStream(uid, type);
            runOnUiThread(() -> {
                setRemoteRenderView(uid);
            });
        }
    };

    IRTCVideoEventHandler rtcVideoEventHandler = new IRTCVideoEventHandler() {
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

        rtcVideo = null;
        RTCVideo.destroyRTCVideo();
    }
}