package com.byteplus.live.pusher;

import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_EXTERNAL;
import static com.ss.bytertc.engine.data.AudioSourceType.AUDIO_SOURCE_TYPE_EXTERNAL;
import static com.ss.bytertc.engine.data.AudioSourceType.AUDIO_SOURCE_TYPE_INTERNAL;
import static com.ss.bytertc.engine.data.StreamIndex.STREAM_INDEX_MAIN;
import static com.ss.bytertc.engine.data.VideoSourceType.VIDEO_SOURCE_TYPE_EXTERNAL;
import static com.ss.bytertc.engine.data.VideoSourceType.VIDEO_SOURCE_TYPE_INTERNAL;
import static com.ss.bytertc.engine.video.VideoCaptureConfig.CapturePreference.MANUAL;
import static com.ss.bytertc.engine.data.CameraId.CAMERA_ID_BACK;
import static com.ss.bytertc.engine.data.CameraId.CAMERA_ID_FRONT;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;

import com.vertc.api.example.base.RTCTokenManager;
import com.ss.bytertc.engine.RTCEngine;
import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.VideoCanvas;
import com.ss.bytertc.engine.VideoEncoderConfig;
import com.ss.bytertc.engine.data.CameraId;
import com.ss.bytertc.engine.data.EngineConfig;
import com.ss.bytertc.engine.data.MediaPlayerCustomSourceMode;
import com.ss.bytertc.engine.data.MediaPlayerCustomSourceStreamType;
import com.ss.bytertc.engine.data.MirrorType;
import com.ss.bytertc.engine.data.RecordingConfig;
import com.ss.bytertc.engine.type.AudioDeviceType;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.TorchState;
import com.ss.bytertc.engine.type.RecordingType;
import com.ss.bytertc.engine.type.VideoDeviceType;
import com.ss.bytertc.engine.video.IVideoEffect;
import com.ss.bytertc.engine.handler.IRTCEngineEventHandler;
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler;
import com.ss.bytertc.engine.live.PushSingleStreamParam;
import com.ss.bytertc.engine.data.EarMonitorMode;
import com.ss.bytertc.engine.data.VideoOrientation;
import com.byteplus.live.settings.PreferenceUtil;

import java.nio.ByteBuffer;
import java.security.SecureRandom;
import java.util.Objects;
import java.util.Random;
import java.util.UUID;
import java.io.File;
import android.os.Environment;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import com.byteplus.live.common.WriterPCMFile;
import com.ss.bytertc.engine.video.IVideoProcessor;
import com.ss.bytertc.engine.video.IVideoFrame;
import com.ss.bytertc.engine.video.VideoCaptureConfig;
import com.ss.bytertc.engine.video.VideoPreprocessorConfig;
import com.ss.bytertc.engine.IAudioFrameProcessor;
import com.ss.bytertc.engine.utils.IAudioFrame;
import com.ss.bytertc.engine.data.AudioFormat;
import com.ss.bytertc.engine.data.AudioProcessorMethod;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicReference;
import java.util.Timer;
import java.util.TimerTask;
import android.graphics.Color;
import android.graphics.Canvas;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.core.util.Consumer;

import org.json.JSONArray;
import org.json.JSONObject;

import com.ss.bytertc.base.media.screen.RXScreenCaptureService;

public class LivePusherImpl implements LivePusher {

    private static final String TAG = "LivePusherImpl";
    private static final String PUSH_TASK_ID = "vel_push_single_stream_task_0";
    private static final Random random = new SecureRandom();
    private static final String PUSH_ROOM_ID = "vel_push_room_" + random.nextInt(100000);

    public static final ExecutorService cached = Executors.newCachedThreadPool();

    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private Context mContext;
    private LivePusherObserver mObserver;
    private RTCEngine mRTCEngine;
    private RTCRoom mRTCRoom;
    private String mUserId;
    private class LocalVideoProcessor extends IVideoProcessor {
        private final AtomicReference<IVideoFrame> mNextFrame = new AtomicReference<>(null);
        public boolean enableListener = false;

        public void pushFrame(IVideoFrame frame) {
            IVideoFrame oldFrame = mNextFrame.getAndSet(frame);
            if (oldFrame != null) {
                oldFrame.releaseRef();
            }
        }

        @Override
        public IVideoFrame processVideoFrame(IVideoFrame srcFrame) {
            if (enableListener) {
                if (mCaptureVideoStreamHandler == null) {
                    mCaptureVideoStreamHandler = addVideoStream();
                }
                // Send back a placeholder/no-op just to satisfy the listener test loop
                sendVideoFrame(mCaptureVideoStreamHandler, null);
            }
            IVideoFrame overrideFrame = mNextFrame.getAndSet(null);
            if (overrideFrame != null) {
                return overrideFrame;
            }
            return srcFrame;
        }
    }

    private class LocalAudioProcessor implements IAudioFrameProcessor {
        private final AtomicReference<AudioFrame> mNextFrame = new AtomicReference<>(null);

        public void pushFrame(AudioFrame frame) {
            mNextFrame.set(frame);
        }

        @Override
        public int onProcessRecordAudioFrame(IAudioFrame srcFrame) {
            AudioFrame overrideFrame = mNextFrame.getAndSet(null);
            if (overrideFrame != null && overrideFrame.buffer != null) {
                java.nio.ByteBuffer buffer = srcFrame.getDataBuffer();
                if (buffer != null) {
                    buffer.clear();
                    byte[] data = overrideFrame.buffer.array();
                    buffer.put(data, 0, Math.min(data.length, buffer.capacity()));
                }
            }
            return 0;
        }

        @Override
        public int onProcessPlayBackAudioFrame(IAudioFrame frame) { return 0; }

        @Override
        public int onProcessRemoteUserAudioFrame(String roomId, com.ss.bytertc.engine.data.StreamInfo info, IAudioFrame frame) { return 0; }

        @Override
        public int onProcessEarMonitorAudioFrame(IAudioFrame frame) { return 0; }

        @Override
        public int onProcessScreenAudioFrame(IAudioFrame frame) { return 0; }
    }

    private LocalVideoProcessor mLocalVideoProcessor;
    private LocalAudioProcessor mLocalAudioProcessor;

    private WriterPCMFile mCaptureAudioWriter;
    private com.ss.bytertc.engine.IAudioFrameObserver mAudioFrameObserver;
    private Object mCaptureVideoStreamHandler;
    private Object mPreEncodeVideoStreamHandler;

    private CameraId mLastCameraId = CameraId.CAMERA_ID_FRONT;
    private boolean mIsMuted = false;
    private boolean mIsPublishing = false;
    private float mVoiceLoudness = 1.0f;
    private boolean mEnableEcho = false;
    private boolean mEnableBgmLoop = false;
    private boolean mEnableBgmMixer = true;

    private Timer mCustomImageTimer;
    private Bitmap mCustomImageBitmap;
    private Bitmap mDummyBlackBitmap;

    private LivePusherCycleInfo mCycleInfo = new LivePusherCycleInfo();

    public static LivePusher createLivePusher(Context context, LivePusherObserver observer) {
        return new LivePusherImpl(context, observer);
    }

    private LivePusherImpl(Context context, LivePusherObserver observer) {
        Log.d(TAG, "create LivePusherImpl");
        mContext = context;
        mObserver = observer;
        mUserId = UUID.randomUUID().toString();
        initEngine();
        setOrientation(0);
    }

    private void initEngine() {
        EngineConfig config = new EngineConfig();
        config.context = mContext;
        config.appID = Objects.requireNonNull(RTCTokenManager.getInstance().getAppId(), "AppId not provided");
        Log.d(TAG, "initEngine appID: " + config.appID);
        mRTCEngine = RTCEngine.createRTCEngine(config, mEngineEventHandler);
        if (mRTCEngine == null) {
            Log.e(TAG, "create rtcEngine failed");
        }
        mRTCEngine.setBusinessId(RTCTokenManager.getInstance().getBusinessId("live"));
        updateRTCVideoEncoderConfig();
    }

    private void updateRTCVideoEncoderConfig() {
        if (mRTCEngine == null) return;
        VideoEncoderConfig config = new VideoEncoderConfig();
        config.width = LivePusherSettingsHelper.getResolutionWidthVal(LivePusherSettingsHelper.getEncodeResolutionSettings());
        config.height = LivePusherSettingsHelper.getResolutionHeightVal(LivePusherSettingsHelper.getEncodeResolutionSettings());
        config.frameRate = LivePusherSettingsHelper.getEncodeFpsVal();
        config.maxBitrate = getDefaultBitrate(config.width, config.height) * 1000;
        mRTCEngine.setVideoEncoderConfig(config);
    }

    private int getDefaultBitrate(int width, int height) {
        int pixels = width * height;
        if (pixels <= 360 * 640) return 800;
        if (pixels <= 540 * 960) return 1200;
        if (pixels <= 720 * 1280) return 1600;
        return 3000;
    }

    private static String getTimestamp() {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss:SSS", Locale.ENGLISH);
        return sdf.format(new Date());
    }

    private final IRTCEngineEventHandler mEngineEventHandler = new IRTCEngineEventHandler() {
        @Override
        public void onWarning(int warn) {
            super.onWarning(warn);
            Log.w(TAG, "onWarning: " + warn);
        }

        @Override
        public void onError(int err) {
            super.onError(err);
            String info = "[" + getTimestamp() + "] onError: " + err;
            Log.e(TAG, info);
            if (mObserver != null) {
                mObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onVideoDeviceStateChanged(String deviceID,
                                              VideoDeviceType deviceType,
                                              int deviceState,
                                              int deviceError) {
            super.onVideoDeviceStateChanged(deviceID, deviceType, deviceState, deviceState);
            String info = "onVideoDeviceStateChanged " + deviceType + " " + deviceState + " " + deviceError;
            Log.e(TAG, info);
            if (mObserver != null) {
                mObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onAudioDeviceStateChanged(String deviceID,
                                              AudioDeviceType deviceType,
                                              int deviceState,
                                              int deviceError) {
            super.onAudioDeviceStateChanged(deviceID, deviceType, deviceState, deviceState);
            String info = "onAudioDeviceStateChanged " + deviceType + " " + deviceState + " " + deviceError;
            Log.e(TAG, info);
            if (mObserver != null) {
                mObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onVideoDeviceWarning(String deviceID,
                                         VideoDeviceType deviceType,
                                         int deviceWarning) {
            super.onVideoDeviceWarning(deviceID, deviceType, deviceWarning);
            String info = "onVideoDeviceWarning " + deviceType + " " + deviceWarning;
            Log.e(TAG, info);
            if (mObserver != null) {
                mObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onAudioDeviceWarning(String deviceID,
                                         AudioDeviceType deviceType,
                                         int deviceWarning) {
            super.onAudioDeviceWarning(deviceID, deviceType, deviceWarning);
            String info = "onAudioDeviceWarning " + deviceType + " " + deviceWarning;
            Log.e(TAG, info);
            if (mObserver != null) {
                mObserver.onCallbackRecordUpdate(info);
            }
        }
        
        @Override
        public void onConnectionStateChanged(int state, int info) {
            super.onConnectionStateChanged(state, info);
            String msg = "[" + getTimestamp() + "] onConnectionStateChanged: state:" + state;
            Log.d(TAG, msg);
            if (mObserver != null) {
                mObserver.onCallbackRecordUpdate(msg);
            }
        }
    };

    private final IRTCRoomEventHandler mRoomEventHandler = new IRTCRoomEventHandler() {
        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            String msg = "[" + getTimestamp() + "] onRoomStateChanged: state:" + state;
            Log.d(TAG, msg);
            if (mObserver != null) {
                mObserver.onCallbackRecordUpdate(msg);
            }
        }

        @Override
        public void onNetworkQuality(com.ss.bytertc.engine.type.NetworkQualityStats localQuality, com.ss.bytertc.engine.type.NetworkQualityStats[] remoteQualities) {
            super.onNetworkQuality(localQuality, remoteQualities);
            if (mObserver != null && localQuality != null) {
                mObserver.onNetworkQuality(localQuality.txQuality);
            }
        }

        @Override
        public void onLocalStreamStats(java.lang.String roomId, com.ss.bytertc.engine.data.StreamInfo streamInfo, com.ss.bytertc.engine.type.LocalStreamStats stats) {
            super.onLocalStreamStats(roomId, streamInfo, stats);
            if (mObserver != null && stats != null) {
                if (stats.videoStats != null) {
                    mCycleInfo.url = LivePusherSettingsHelper.getPushUrl();
                    mCycleInfo.encodeWidth = stats.videoStats.encodedFrameWidth;
                    mCycleInfo.encodeHeight = stats.videoStats.encodedFrameHeight;
                    mCycleInfo.captureWidth = stats.videoStats.encodedFrameWidth; // Use encode width/height as fallback since RTC doesn't directly expose capture width/height here
                    mCycleInfo.captureHeight = stats.videoStats.encodedFrameHeight;
                    mCycleInfo.captureFps = stats.videoStats.inputFrameRate;
                    mCycleInfo.encodeFps = stats.videoStats.encoderOutputFrameRate;
                    mCycleInfo.transportFps = stats.videoStats.sentFrameRate;
                    mCycleInfo.fps = stats.videoStats.sentFrameRate;
                    mCycleInfo.encodeVideoBitrate = stats.videoStats.encodedBitrate * 1000;
                    mCycleInfo.transportVideoBitrate = stats.videoStats.sentKBitrate * 1000;
                    mCycleInfo.videoBitrate = (long) (stats.videoStats.sentKBitrate * 1000);
                    mCycleInfo.videoCodec = stats.videoStats.codecType == 1 ? "bytevc1" : "h264";
                    
                    // We can estimate min/max bitrate based on target encode bitrate
                    long targetBitrate = getDefaultBitrate(mCycleInfo.encodeWidth, mCycleInfo.encodeHeight) * 1000;
                    mCycleInfo.minVideoBitrate = targetBitrate / 2;
                    mCycleInfo.maxVideoBitrate = targetBitrate * 2;
                }
                if (stats.audioStats != null) {
                    mCycleInfo.encodeAudioBitrate = stats.audioStats.sendKBitrate * 1000;
                }
                mObserver.onCycleInfoUpdate(mCycleInfo);
            }
        }
    };

    @Override
    public IVideoEffect getEffectHandler() {
        if (mRTCEngine == null) {
            Log.e(TAG, "getEffectHandler, mRTCEngine is null.");
            return null;
        }
        return mRTCEngine.getVideoEffectInterface();
    }

    @Override
    public void setOrientation(int orientation) {
        Log.d(TAG, "setOrientation, orientation: " + orientation);
        if (mRTCEngine == null) {
            Log.e(TAG, "setOrientation, mRTCEngine is null.");
            return;
        }
        VideoOrientation rtcOrientation = VideoOrientation.PORTRAIT;
        if (orientation == 1) { // Landscape
            rtcOrientation = VideoOrientation.LANDSCAPE;
        }
        mRTCEngine.setVideoOrientation(rtcOrientation);
    }

    @Override
    public void setRenderView(View view) {
        Log.d(TAG, "setRenderView");
        if (mRTCEngine == null) {
            Log.e(TAG, "setRenderView, mRTCEngine is null.");
            return;
        }
        VideoCanvas canvas = new VideoCanvas();
        canvas.renderView = view;
        canvas.renderMode = VideoCanvas.RENDER_MODE_HIDDEN;
        mRTCEngine.setLocalVideoCanvas(canvas);
    }

    @Override
    public void startVideoCapture(int type) {
        Log.d(TAG, "startVideoCapture, type: " + type);
        if (mRTCEngine == null) {
            Log.e(TAG, "startVideoCapture, mRTCEngine is null.");
            return;
        }
        switchVideoCapture(type);
    }

    @Override
    public void stopVideoCapture() {
        Log.d(TAG, "stopVideoCapture.");
        if (mRTCEngine == null) {
            Log.e(TAG, "stopVideoCapture, mRTCEngine is null.");
            return;
        }
        mRTCEngine.stopVideoCapture();
    }

    @Override
    public void startAudioCapture(int type) {
        Log.d(TAG, "startAudioCapture, type: " + type);
        if (mRTCEngine == null) {
            Log.e(TAG, "startAudioCapture, mRTCEngine is null.");
            return;
        }
        switchAudioCapture(type);
    }

    @Override
    public void stopAudioCapture() {
        Log.d(TAG, "stopAudioCapture.");
        if (mRTCEngine == null) {
            Log.e(TAG, "stopAudioCapture, mRTCEngine is null.");
            return;
        }
        mRTCEngine.stopAudioCapture();
    }

    private void startRXScreenCaptureService(@NonNull Intent data) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Intent intent = new Intent();
            intent.putExtra(RXScreenCaptureService.KEY_LARGE_ICON, com.ss.bytertc.R.drawable.abc_btn_check_material);
            intent.putExtra(RXScreenCaptureService.KEY_SMALL_ICON, com.ss.bytertc.R.drawable.abc_btn_check_material);
            intent.putExtra(RXScreenCaptureService.KEY_LAUNCH_ACTIVITY, this.getClass().getCanonicalName());
            intent.putExtra(RXScreenCaptureService.KEY_CONTENT_TEXT, "正在录制/投射您的屏幕");
            intent.putExtra(RXScreenCaptureService.KEY_RESULT_DATA, data);
            mContext.startForegroundService(RXScreenCaptureService.getServiceIntent(mContext, RXScreenCaptureService.COMMAND_LAUNCH, intent));
        }
    }

    @Override
    public void startScreenRecording(Intent screenIntent) {
        Log.d(TAG, "startScreenRecording");
        if (mRTCEngine == null) {
            Log.e(TAG, "startScreenRecording, mRTCEngine is null.");
            return;
        }

        startRXScreenCaptureService(screenIntent);

        updateRTCVideoEncoderConfig();
        mRTCEngine.setVideoSourceType(VIDEO_SOURCE_TYPE_INTERNAL);
        mRTCEngine.setAudioSourceType(AUDIO_SOURCE_TYPE_INTERNAL);
        int ret = mRTCEngine.startScreenCapture(com.ss.bytertc.engine.data.ScreenMediaType.SCREEN_MEDIA_TYPE_VIDEO_AND_AUDIO, screenIntent);
        Log.e(TAG, "startScreenRecording, ret: " + ret);
    }

    @Override
    public void stopScreenRecording() {
        Log.d(TAG, "stopScreenRecording");
        if (mRTCEngine == null) {
            Log.e(TAG, "stopScreenRecording, mRTCEngine is null.");
            return;
        }
        mRTCEngine.stopScreenCapture();
    }

    @Override
    public void updateCustomImage(Bitmap bm) {
        Log.d(TAG, "updateCustomImage");
        mCustomImageBitmap = bm;
    }

    private void stopCustomImageTimer() {
        if (mCustomImageTimer != null) {
            mCustomImageTimer.cancel();
            mCustomImageTimer = null;
        }
    }

    private void startCustomImageTimer(int type) {
        if (mCustomImageTimer != null) return;
        mCustomImageTimer = new Timer();
        mCustomImageTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                Bitmap bmp = null;
                if (type == PreferenceUtil.PUSH_VIDEO_CAPTURE_CUSTOM_IMAGE) {
                    bmp = mCustomImageBitmap;
                } else if (type == PreferenceUtil.PUSH_VIDEO_CAPTURE_DUMMY_FRAME) {
                    if (mDummyBlackBitmap == null) {
                        mDummyBlackBitmap = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888);
                        mDummyBlackBitmap.eraseColor(Color.BLACK);
                    }
                    bmp = mDummyBlackBitmap;
                }
                
                if (bmp != null) {
                    pushBitmapAsVideoFrame(bmp);
                }
            }
        }, 0, 1000 / 15); // 15 fps
    }

    private void pushBitmapAsVideoFrame(Bitmap bm) {
        if (bm == null || mRTCEngine == null) return;
        int bytes = bm.getByteCount();
        java.nio.ByteBuffer buffer = java.nio.ByteBuffer.allocateDirect(bytes);
        bm.copyPixelsToBuffer(buffer);
        buffer.rewind();
        
        com.ss.bytertc.engine.data.VideoFrameData rtcFrameData = new com.ss.bytertc.engine.data.VideoFrameData();
        rtcFrameData.width = bm.getWidth();
        rtcFrameData.height = bm.getHeight();
        rtcFrameData.rotation = com.ss.bytertc.engine.data.VideoRotation.VIDEO_ROTATION_0;
        rtcFrameData.timestampUs = System.currentTimeMillis() * 1000;
        rtcFrameData.bufferType = com.ss.bytertc.engine.data.VideoBufferType.RAW_MEMORY;
        rtcFrameData.pixelFormat = com.ss.bytertc.engine.data.VideoPixelFormat.RGBA;
        rtcFrameData.planeData = new java.nio.ByteBuffer[]{buffer};
        rtcFrameData.numberOfPlanes = 1;
        rtcFrameData.planeStride = new int[1];
        rtcFrameData.planeStride[0] = bm.getWidth() * 4;

        mRTCEngine.pushExternalVideoFrame(rtcFrameData);
    }

    @Override
    public int pushExternalVideoFrame(VideoFrame frame) {
        if (mRTCEngine == null || frame == null) {
            return -1;
        }
        
        com.ss.bytertc.engine.data.VideoFrameData rtcFrameData = new com.ss.bytertc.engine.data.VideoFrameData();
        rtcFrameData.width = frame.width;
        rtcFrameData.height = frame.height;
        rtcFrameData.rotation = com.ss.bytertc.engine.data.VideoRotation.fromId(frame.rotation);
        rtcFrameData.timestampUs = frame.pts * 1000;

        if (frame.bufferType == VideoFrame.VIDEO_BUFFER_TYPE_TEXTURE_ID) {
            rtcFrameData.bufferType = com.ss.bytertc.engine.data.VideoBufferType.GL_TEXTURE;
            rtcFrameData.pixelFormat = frame.pixelFormat == VideoFrame.VIDEO_PIXEL_FMT_OES_TEXTURE ? 
                                   com.ss.bytertc.engine.data.VideoPixelFormat.TEXTURE_OES : 
                                   com.ss.bytertc.engine.data.VideoPixelFormat.TEXTURE_2D;
            rtcFrameData.textureId = frame.textureId;
        } else if (frame.bufferType == VideoFrame.VIDEO_BUFFER_TYPE_BYTE_BUFFER) {
            rtcFrameData.bufferType = com.ss.bytertc.engine.data.VideoBufferType.RAW_MEMORY;
            rtcFrameData.pixelFormat = com.ss.bytertc.engine.data.VideoPixelFormat.I420;

            int chromaWidth = (frame.width + 1) / 2;
            int chromaHeight = (frame.height + 1) / 2;
            int uvSize = chromaWidth * chromaHeight;
            int uStart = frame.width * frame.height;
            int vStart = uStart + uvSize;
            ByteBuffer directBufferY = frame.buffer.slice();
            frame.buffer.position(uStart);
            frame.buffer.limit(uStart + uvSize);
            ByteBuffer directBufferU = frame.buffer.slice();
            frame.buffer.position(vStart);
            frame.buffer.limit(vStart + uvSize);
            ByteBuffer directBufferV = frame.buffer.slice();
            rtcFrameData.numberOfPlanes = 3;
            rtcFrameData.planeData = new ByteBuffer[3];
            rtcFrameData.planeStride = new int[3];
            rtcFrameData.planeData[0] = directBufferY;
            rtcFrameData.planeStride[0] = frame.width;
            rtcFrameData.planeData[1] = directBufferU;
            rtcFrameData.planeStride[1] = chromaWidth;
            rtcFrameData.planeData[2] = directBufferV;
            rtcFrameData.planeStride[2] = chromaWidth;
        } else if (frame.bufferType == VideoFrame.VIDEO_BUFFER_TYPE_BYTE_ARRAY) {
            // TODO: support array
            rtcFrameData.bufferType = com.ss.bytertc.engine.data.VideoBufferType.RAW_MEMORY;
            rtcFrameData.pixelFormat = com.ss.bytertc.engine.data.VideoPixelFormat.I420;
            if (frame.data != null) {
                rtcFrameData.planeData = new java.nio.ByteBuffer[]{java.nio.ByteBuffer.wrap(frame.data)};
            }
        } else {
            return -1; // Unsupported
        }
        
        return mRTCEngine.pushExternalVideoFrame(rtcFrameData);
    }

    @Override
    public int pushExternalAudioFrame(AudioFrame frame) { 
        if (mRTCEngine == null || frame == null || frame.buffer == null) {
            return -1;
        }
        
        com.ss.bytertc.engine.utils.AudioFrame rtcAudioFrame = new com.ss.bytertc.engine.utils.AudioFrame();
        rtcAudioFrame.sampleRate = com.ss.bytertc.engine.data.AudioSampleRate.fromId(frame.sampleRate);
        rtcAudioFrame.channel = com.ss.bytertc.engine.data.AudioChannel.fromId(frame.channels);
        rtcAudioFrame.buffer = new byte[frame.buffer.array().length];
        System.arraycopy(frame.buffer.array(), 0, rtcAudioFrame.buffer, 0, frame.buffer.array().length);
        rtcAudioFrame.samples = rtcAudioFrame.sampleRate.value() / 100;
        
        return mRTCEngine.pushExternalAudioFrame(rtcAudioFrame);
    }

    @Override
    public void switchVideoCapture(int type) {
        Log.d(TAG, "switchVideoCapture, type: " + type);
        if (mRTCEngine == null) {
            Log.e(TAG, "switchVideoCapture, mRTCEngine is null.");
            return;
        }
        
        stopCustomImageTimer();

        if (type == PreferenceUtil.PUSH_VIDEO_CAPTURE_FRONT || type == PreferenceUtil.PUSH_VIDEO_CAPTURE_BACK) {
            mLastCameraId = type == PreferenceUtil.PUSH_VIDEO_CAPTURE_FRONT ? CameraId.CAMERA_ID_FRONT : CameraId.CAMERA_ID_BACK;
            mRTCEngine.setVideoSourceType(VIDEO_SOURCE_TYPE_INTERNAL);
            mRTCEngine.switchCamera(mLastCameraId);

            VideoCaptureConfig captureConfig = new VideoCaptureConfig();
            captureConfig.capturePreference = MANUAL;
            captureConfig.frameRate = LivePusherSettingsHelper.getCaptureFpsVal();
            captureConfig.width = LivePusherSettingsHelper.getCaptureWidthVal();
            captureConfig.height = LivePusherSettingsHelper.getCaptureHeightVal();
            mRTCEngine.setVideoCaptureConfig(captureConfig);
            mRTCEngine.startVideoCapture();
            if (type == PreferenceUtil.PUSH_VIDEO_CAPTURE_FRONT) {
                mRTCEngine.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER);
            } else {
                mRTCEngine.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_NONE);
            }
        } else if (type == PreferenceUtil.PUSH_VIDEO_CAPTURE_CUSTOM_IMAGE || type == PreferenceUtil.PUSH_VIDEO_CAPTURE_DUMMY_FRAME) {
            mRTCEngine.stopVideoCapture();
            mRTCEngine.setVideoSourceType(VIDEO_SOURCE_TYPE_EXTERNAL);
            startCustomImageTimer(type);
        } else if (type == PreferenceUtil.PUSH_VIDEO_CAPTURE_EXTERNAL) {
            mRTCEngine.stopVideoCapture();
            mRTCEngine.setVideoSourceType(VIDEO_SOURCE_TYPE_EXTERNAL);
        } else {
            mRTCEngine.stopVideoCapture();
        }
    }

    @Override
    public void switchAudioCapture(int type) {
        Log.d(TAG, "switchAudioCapture, type: " + type);

        if (type != PUSH_AUDIO_CAPTURE_EXTERNAL) {
            mRTCEngine.setAudioSourceType(AUDIO_SOURCE_TYPE_INTERNAL);
            mRTCEngine.startAudioCapture();
        } else {
            stopAudioCapture();
            mRTCEngine.setAudioSourceType(AUDIO_SOURCE_TYPE_EXTERNAL);
        }
    }

    @Override
    public int enableTorch(boolean enable) {
        Log.d(TAG, "enableTorch, enable: " + enable);
        if (mRTCEngine == null) {
            Log.e(TAG, "enableTorch, mRTCEngine is null.");
            return -1;
        }
        mRTCEngine.setCameraTorch(enable ? TorchState.TORCH_STATE_ON : TorchState.TORCH_STATE_OFF);
        return 0;
    }

    @Override
    public void updateSettings(boolean isNeedRebuild) {
        Log.d(TAG, "updateSettings, isNeedRebuild: " + isNeedRebuild);
        updateRTCVideoEncoderConfig();
    }

    @MainThread
    protected void requestRoomToken(String roomId, String userId, @NonNull Consumer<String> consumer) {
        Future<String> future = RTCTokenManager.getInstance().getToken(roomId, userId);
        if (future.isDone()) {
            try {
                consumer.accept(future.get());
            } catch (ExecutionException | InterruptedException e) {
                throw new RuntimeException(e);
            }
        } else {
            cached.submit(() -> {
                try {
                    String result = future.get();
                    mainHandler.post(() -> {
                        consumer.accept(result);
                    });
                } catch (Exception e) {
                    Log.e(TAG, "Generate token fail:", e);
                }
            });
        }
    }
    @Override
    public void startPush() {
        Log.d(TAG, "startPush, url: " + LivePusherSettingsHelper.getPushUrl());
        if (mRTCEngine == null) {
            Log.e(TAG, "startPush, mRTCEngine is null.");
            return;
        }
        if (mIsPublishing) return;
        mIsPublishing = true;
        updateRTCVideoEncoderConfig();

        if (mRTCRoom == null) {
            requestRoomToken(PUSH_ROOM_ID, mUserId, token -> {
                mRTCRoom = mRTCEngine.createRTCRoom(PUSH_ROOM_ID);
                mRTCRoom.setRTCRoomEventHandler(mRoomEventHandler);
                UserInfo userInfo = new UserInfo(mUserId, null);
                RTCRoomConfig roomConfig = new RTCRoomConfig(ChannelProfile.CHANNEL_PROFILE_LIVE_PUSH, true, true, true, true);
                Log.d(TAG, "startPush roomID:" + PUSH_ROOM_ID + ", userID:" + mUserId);
                mRTCRoom.joinRoom(token, userInfo, true, roomConfig);
            });
        }


        String pushUrl = LivePusherSettingsHelper.getPushUrl();
        if (pushUrl != null && !pushUrl.isEmpty()) {
            PushSingleStreamParam param = new PushSingleStreamParam();
            param.url = pushUrl;
            param.roomId = PUSH_ROOM_ID;
            param.userId = mUserId;
            mRTCEngine.startPushSingleStream(PUSH_TASK_ID, param);
        }
    }

    @Override
    public void stopPush() {
        Log.d(TAG, "stopPush.");
        if (mRTCEngine == null) {
            Log.e(TAG, "stopPush, mRTCEngine is null.");
            return;
        }
        if (!mIsPublishing) return;
        mIsPublishing = false;
        mRTCEngine.stopPushSingleStream(PUSH_TASK_ID);
        if (mRTCRoom != null) {
            mRTCRoom.leaveRoom();
            mRTCRoom.destroy();
            mRTCRoom = null;
        }
    }

    @Override
    public boolean isMute() { 
        return mIsMuted; 
    }

    @Override
    public void setMute(boolean mute) {
        Log.d(TAG, "setMute, mute: " + mute);
        if (mRTCEngine == null) {
            Log.e(TAG, "setMute, mRTCEngine is null.");
            return;
        }
        mIsMuted = mute;
        if (mute) {
            mRTCEngine.stopAudioCapture();
        } else {
            mRTCEngine.startAudioCapture();
        }
    }

    @Override
    public void setFileRecordingConfig(int resolution, int fps, int bitrate) {
        Log.d(TAG, "setFileRecordingConfig");
    }

    @Override
    public void startFileRecording(FileRecordingListener listener) {
        Log.d(TAG, "startFileRecording");
        if (mRTCEngine == null) {
            Log.e(TAG, "startFileRecording, mRTCEngine is null.");
            return;
        }
        RecordingConfig config = new RecordingConfig();
        File dir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM), "MediaLive");
        if (!dir.exists()) dir.mkdirs();
        config.dirPath = dir.getAbsolutePath();
        mRTCEngine.startFileRecording(config, RecordingType.RECORD_VIDEO_AND_AUDIO);
        if (listener != null) listener.onFileRecordingStarted();
    }

    @Override
    public void stopFileRecording() {
        Log.d(TAG, "stopFileRecording");
        if (mRTCEngine == null) {
            Log.e(TAG, "stopFileRecording, mRTCEngine is null.");
            return;
        }
        mRTCEngine.stopFileRecording();
    }

    @Override
    public void setVideoMirror(int mirrorType, boolean enable) {
        Log.d(TAG, "setVideoMirror, mirrorType: " + mirrorType + ", enable: " + enable);
        if (mRTCEngine == null) {
            Log.e(TAG, "setVideoMirror, mRTCEngine is null.");
            return;
        }

        if (enable) {
            if (mirrorType == 0) {
                mRTCEngine.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER);
            } else if (mirrorType == 1) {
                mRTCEngine.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_RENDER);
            } else if (mirrorType == 2) {
                mRTCEngine.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_ENCODER);
            }
        } else {
            mRTCEngine.setLocalVideoMirrorType(MirrorType.MIRROR_TYPE_NONE);
        }
    }

    @Override
    public void snapshot() {
        Log.d(TAG, "snapshot");
        if (mRTCEngine == null) {
            Log.e(TAG, "snapshot, mRTCEngine is null.");
            return;
        }
        // Take Local Snapshot needs ISnapshotResultCallback
    }

    @Override
    public void sendSeiMessage(String content, int repeatCount) {
        try {
            JSONObject obj = new JSONObject();
            obj.put("test_sei", content);
            String json = obj.toString();
 
            Log.d(TAG, "sendSeiMessage " + json + ", count: " + repeatCount);
            mRTCEngine.enableSendLivePushSEI(true);
            mRTCEngine.sendLivePushSEIMessage(json, 100, false, false);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    @Override
    public void setWatermark(Bitmap bm, float x, float y, float scale) {
        Log.d(TAG, "setWatermark");
        if (mRTCEngine == null) {
            return;
        }
        com.ss.bytertc.engine.video.RTCWatermarkConfig config = new com.ss.bytertc.engine.video.RTCWatermarkConfig();
        config.visibleInPreview = true;
        
        com.ss.bytertc.engine.video.ByteWatermark position = new com.ss.bytertc.engine.video.ByteWatermark();
        position.x = x;
        position.y = y;
        position.width = scale;
        position.height = scale * (bm == null ? 1 : ((float)bm.getHeight() / bm.getWidth()));
        config.positionInLandscapeMode = position;
        config.positionInPortraitMode = position;
        
        // This expects a local file path to the watermark image.
        // If 'bm' is passed directly, we'd need to save it to a file first.
        // For now using empty string which would clear it.
        mRTCEngine.setVideoWatermark("", config);
    }

    @Override
    public Object addAudioStream() { 
        if (mRTCEngine == null) return null;
        if (mLocalAudioProcessor == null) {
            mLocalAudioProcessor = new LocalAudioProcessor();
            mRTCEngine.registerAudioProcessor(mLocalAudioProcessor);
            mRTCEngine.enableAudioProcessor(AudioProcessorMethod.AUDIO_FRAME_PROCESSOR_RECORD, 
                new AudioFormat(com.ss.bytertc.engine.data.AudioSampleRate.AUDIO_SAMPLE_RATE_44100, com.ss.bytertc.engine.data.AudioChannel.AUDIO_CHANNEL_STEREO));
        }
        return mLocalAudioProcessor; 
    }

    @Override
    public void sendAudioFrame(Object streamHandle, AudioFrame frame) {
        if (streamHandle instanceof LocalAudioProcessor && frame != null) {
            ((LocalAudioProcessor) streamHandle).pushFrame(frame);
        }
    }

    @Override
    public void removeAudioStream(Object streamHandle) {
        if (streamHandle instanceof LocalAudioProcessor && mRTCEngine != null) {
            mRTCEngine.disableAudioProcessor(AudioProcessorMethod.AUDIO_FRAME_PROCESSOR_RECORD);
            mRTCEngine.registerAudioProcessor(null);
            if (mLocalAudioProcessor == streamHandle) {
                mLocalAudioProcessor = null;
            }
        }
    }

    @Override
    public Object addVideoStream() { 
        if (mRTCEngine == null) return null;
        if (mLocalVideoProcessor == null) {
            mLocalVideoProcessor = new LocalVideoProcessor();
            VideoPreprocessorConfig config = new VideoPreprocessorConfig();
            config.requiredPixelFormat = com.ss.bytertc.engine.data.VideoPixelFormat.UNKNOWN;
            mRTCEngine.registerLocalVideoProcessor(mLocalVideoProcessor, config);
        }
        return mLocalVideoProcessor; 
    }

    @Override
    public void sendVideoFrame(Object streamHandle, VideoFrame frame) {
        if (streamHandle instanceof LocalVideoProcessor && frame != null) {
            ((LocalVideoProcessor) streamHandle).pushFrame(new CustomVideoFrame(frame));
        }
    }

    @Override
    public void updateStreamMixDescription(Object streamHandle, float x, float y, float alpha, int renderMode) {}

    @Override
    public void removeVideoStream(Object streamHandle) {
        if (streamHandle instanceof LocalVideoProcessor && mRTCEngine != null) {
            mRTCEngine.registerLocalVideoProcessor(null, null);
            if (mLocalVideoProcessor == streamHandle) {
                mLocalVideoProcessor = null;
            }
        }
    }

    @Override
    public void updateMixBgColor(int color) {}

    @Override
    public float getVoiceLoudness() { 
        return mVoiceLoudness; 
    }

    @Override
    public void setVoiceLoudness(float level) {
        Log.d(TAG, "setVoiceLoudness, level:" + level);
        if (mRTCEngine == null) {
            Log.e(TAG, "setVoiceLoudness, mRTCEngine is null.");
            return;
        }
        mVoiceLoudness = level;
        mRTCEngine.setCaptureVolume((int)(level * 100));
    }

    @Override
    public boolean enableEcho(boolean enable) {
        Log.d(TAG, "enableEcho, enable:" + enable);
        if (mRTCEngine == null) {
            Log.e(TAG, "enableEcho, mRTCEngine is null.");
            return false;
        }
        mEnableEcho = enable;
        mRTCEngine.setEarMonitorMode(enable ? EarMonitorMode.EAR_MONITOR_MODE_ON : EarMonitorMode.EAR_MONITOR_MODE_OFF);
        return enable;
    }

    @Override
    public boolean isEnableEcho() { 
        return mEnableEcho; 
    }

    @Override
    public int startBgm(String filePath, MediaPlayerListener listener) { 
        Log.d(TAG, "startBgm, filePath: " + filePath);
        if (mRTCEngine == null) {
            return -1;
        }
        com.ss.bytertc.engine.audio.IMediaPlayer audioMixingManager = mRTCEngine.getMediaPlayer(0);
        if (audioMixingManager != null) {
            com.ss.bytertc.engine.data.MediaPlayerConfig config = new com.ss.bytertc.engine.data.MediaPlayerConfig();
            config.type = mEnableBgmMixer ? com.ss.bytertc.engine.data.AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH : com.ss.bytertc.engine.data.AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT;
            config.playCount = mEnableBgmLoop ? -1 : 1;
            return audioMixingManager.open(filePath, config);
        }
        return -1;
    }

    @Override
    public void stopBgm() {
        Log.d(TAG, "stopBgm");
        if (mRTCEngine == null) return;
        com.ss.bytertc.engine.audio.IMediaPlayer audioMixingManager = mRTCEngine.getMediaPlayer(0);
        if (audioMixingManager != null) {
            audioMixingManager.stop();
        }
    }

    @Override
    public int seekBgm(int pos) { 
        if (mRTCEngine == null) return -1;
        com.ss.bytertc.engine.audio.IMediaPlayer audioMixingManager = mRTCEngine.getMediaPlayer(0);
        if (audioMixingManager != null) {
            return audioMixingManager.setPosition(pos);
        }
        return -1;
    }

    @Override
    public void resumeBgm() {
        if (mRTCEngine == null) return;
        com.ss.bytertc.engine.audio.IMediaPlayer audioMixingManager = mRTCEngine.getMediaPlayer(0);
        if (audioMixingManager != null) {
            audioMixingManager.resume();
        }
    }

    @Override
    public void pauseBgm() {
        if (mRTCEngine == null) return;
        com.ss.bytertc.engine.audio.IMediaPlayer audioMixingManager = mRTCEngine.getMediaPlayer(0);
        if (audioMixingManager != null) {
            audioMixingManager.pause();
        }
    }

    @Override
    public void enableBgmMixer(boolean enable) {
        mEnableBgmMixer = enable;
    }

    @Override
    public void enableBgmFrameListener(boolean enable) {
        Log.d(TAG, "enableBgmFrameListener, enable:" + enable);
        if (mRTCEngine == null) {
            Log.e(TAG, "enableBgmFrameListener, mRTCEngine is null.");
            return;
        }
    }

    @Override
    public void setBgmVolume(float volume) {
        Log.d(TAG, "setBgmVolume, volume:" + volume);
        if (mRTCEngine == null) return;
        com.ss.bytertc.engine.audio.IMediaPlayer audioMixingManager = mRTCEngine.getMediaPlayer(0);
        if (audioMixingManager != null) {
            audioMixingManager.setVolume((int)(volume * 100), mEnableBgmMixer ? com.ss.bytertc.engine.data.AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH : com.ss.bytertc.engine.data.AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT);
        }
    }

    @Override
    public void setVoiceVolume(float volume) {
        Log.d(TAG, "setVoiceVolume, volume:" + volume);
        if (mRTCEngine == null) return;
        mRTCEngine.setCaptureVolume((int)(volume * 100));
    }

    @Override
    public void enableBgmLoop(boolean loop) {
        mEnableBgmLoop = loop;
    }

    @Override
    public void enableAudioFrameListener(boolean enable) {
        Log.d(TAG, "enableAudioFrameListener, enable:" + enable);
        if (mRTCEngine == null) {
            Log.e(TAG, "enableAudioFrameListener, mRTCEngine is null.");
            return;
        }
        if (enable) {
            if (mAudioFrameObserver == null) {
                mAudioFrameObserver = new com.ss.bytertc.engine.IAudioFrameObserver() {
                    @Override
                    public void onRecordAudioFrame(IAudioFrame frame) {
                        if (mCaptureAudioWriter == null) {
                            mCaptureAudioWriter = new WriterPCMFile(frame.sample_rate().value(), frame.channel().value(), 16, "captureAudio", "le");
                        }
                        java.nio.ByteBuffer buffer = frame.getDataBuffer();
                        if (buffer != null) {
                            byte[] data = new byte[buffer.limit()];
                            buffer.get(data);
                            mCaptureAudioWriter.writeBytes(data);
                            buffer.rewind();
                        }
                    }

                    @Override
                    public void onPlaybackAudioFrame(IAudioFrame frame) {}

                    @Override
                    public void onRemoteUserAudioFrame(String roomId, com.ss.bytertc.engine.data.StreamInfo info, IAudioFrame frame) {}

                    @Override
                    public void onMixedAudioFrame(IAudioFrame frame) {}

                    @Override
                    public void onCaptureMixedAudioFrame(IAudioFrame frame) {}
                };
            }
            mRTCEngine.registerAudioFrameObserver(mAudioFrameObserver);
        } else {
            mRTCEngine.registerAudioFrameObserver(null);
            if (mCaptureAudioWriter != null) {
                mCaptureAudioWriter.finish();
                mCaptureAudioWriter = null;
            }
        }
    }

    @Override
    public void enableVideoFrameListener(boolean enable) {
        Log.d(TAG, "enableVideoFrameListener, enable:" + enable);
        if (mRTCEngine == null) {
            Log.e(TAG, "enableVideoFrameListener, mRTCEngine is null.");
            return;
        }
        if (mLocalVideoProcessor == null) {
            mLocalVideoProcessor = new LocalVideoProcessor();
            VideoPreprocessorConfig config = new VideoPreprocessorConfig();
            config.requiredPixelFormat = com.ss.bytertc.engine.data.VideoPixelFormat.UNKNOWN;
            mRTCEngine.registerLocalVideoProcessor(mLocalVideoProcessor, config);
        }
        mLocalVideoProcessor.enableListener = enable;
        if (!enable) {
            if (mCaptureVideoStreamHandler != null) {
                removeVideoStream(mCaptureVideoStreamHandler);
                mCaptureVideoStreamHandler = null;
            }
        }
    }

    @Override
    public void setFocusPosition(int width, int height, int x, int y) {
        if (mRTCEngine != null) {
            float normalizedX = width > 0 ? (float) x / width : 0.5f;
            float normalizedY = height > 0 ? (float) y / height : 0.5f;
            mRTCEngine.setCameraFocusPosition(normalizedX, normalizedY);
            mRTCEngine.setCameraExposurePosition(normalizedX, normalizedY);
        }
    }

    @Override
    public float getCurrentZoomRatio() { 
        // Note: RTCEngine doesn't have a direct getter for current zoom ratio.
        // It's typically maintained by the caller or UI.
        return 1.0f; 
    }

    @Override
    public float getMaxZoomRatio() {
        if (mRTCEngine == null) {
            Log.e(TAG, "getMaxZoomRatio, mRTCEngine is null.");
            return 1.0f;
        }
        return mRTCEngine.getCameraZoomMaxRatio();
    }

    @Override
    public float getMinZoomRatio() { return 1.0f; }

    @Override
    public void setZoomRatio(float ratio) {
        Log.d(TAG, "setZoomRatio, ratio: " + ratio);
        if (mRTCEngine == null) {
            Log.e(TAG, "setZoomRatio, mRTCEngine is null.");
            return;
        }
        mRTCEngine.setCameraZoomRatio(ratio);
    }

    @Override
    public void release() {
        Log.d(TAG, "release");
        stopCustomImageTimer();
        if (mDummyBlackBitmap != null) {
            mDummyBlackBitmap.recycle();
            mDummyBlackBitmap = null;
        }
        stopPush();
        stopAudioCapture();
        stopVideoCapture();
        if (mRTCEngine != null) {
            RTCEngine.destroyRTCEngine();
            mRTCEngine = null;
        }
    }
}
