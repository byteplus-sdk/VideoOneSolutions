// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_EXTERNAL;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_MICROPHONE;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_MUTE_FRAME;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_VOICE_COMMUNICATION;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_VOICE_RECOGNITION;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_SAMPLE_RATE_16K;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_SAMPLE_RATE_32K;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_SAMPLE_RATE_44_1K;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_SAMPLE_RATE_48K;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_SAMPLE_RATE_8K;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_BACK;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_CUSTOM_IMAGE;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_DUAL;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_DUMMY_FRAME;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_EXTERNAL;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_FRONT;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_LAST_FRAME;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_MIRROR;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_SCREEN;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_PREVIEW_MIRROR;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_PUSH_MIRROR;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_RENDER_MODE_FILL;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_RENDER_MODE_FIT;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_RENDER_MODE_HIDDEN;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_1080P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_360P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_480P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_540P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_720P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureExternal;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureMicrophone;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureMuteFrame;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureVoiceCommunication;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureVoiceRecognition;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioChannel.VeLiveAudioChannelStereo;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioFrameSource.VeLiveAudioFrameSourceCapture;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioFrameSource.VeLiveAudioFrameSourcePreEncode;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate16000;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate32000;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate44100;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate48000;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioSampleRate.VeLiveAudioSampleRate8000;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveNetworkQuality.VeLiveNetworkQualityBad;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveNetworkQuality.VeLiveNetworkQualityGood;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveNetworkQuality.VeLiveNetworkQualityPoor;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveNetworkQuality.VeLiveNetworkQualityUnknown;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveOrientation.VeLiveOrientationLandscape;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveOrientation.VeLiveOrientationPortrait;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePixelFormat.VeLivePixelFormatI420;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePixelFormat.VeLivePixelFormatNV12;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePixelFormat.VeLivePixelFormatNV21;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePusherRenderMode.VeLivePusherRenderModeFill;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePusherRenderMode.VeLivePusherRenderModeFit;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePusherRenderMode.VeLivePusherRenderModeHidden;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureBackCamera;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureCustomImage;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureDualCamera;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureExternal;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureLastFrame;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureScreen;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoFrameSource.VeLiveVideoFrameSourceCapture;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoFrameSource.VeLiveVideoFrameSourcePreEncode;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoMirrorType.VeLiveVideoMirrorCapture;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoMirrorType.VeLiveVideoMirrorPreview;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoMirrorType.VeLiveVideoMirrorPushStream;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution1080P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution360P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution480P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution540P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution720P;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoRotation.VeLiveVideoRotation0;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoRotation.VeLiveVideoRotation180;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoRotation.VeLiveVideoRotation270;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoRotation.VeLiveVideoRotation90;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.byteplus.live.common.FileUtils;
import com.byteplus.live.common.WriterPCMFile;
import com.byteplus.live.settings.PreferenceUtil;
import com.ss.avframework.live.VeLiveAudioDevice;
import com.ss.avframework.live.VeLiveAudioFrame;
import com.ss.avframework.live.VeLiveCameraDevice;
import com.ss.avframework.live.VeLiveMediaPlayer;
import com.ss.avframework.live.VeLiveMixerManager;
import com.ss.avframework.live.VeLivePusher;
import com.ss.avframework.live.VeLivePusherConfiguration;
import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.live.VeLivePusherObserver;
import com.ss.avframework.live.VeLiveVideoEffectManager;
import com.ss.avframework.live.VeLiveVideoFrame;

import org.json.JSONObject;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Objects;

public class LivePusherImpl implements LivePusher,
        VeLivePusherDef.VeLiveAudioFrameListener,
        VeLivePusherDef.VeLiveVideoFrameListener {
    private VeLivePusher mLivePusher;
    private VeLiveCameraDevice mLiveCameraDev;
    private VeLiveAudioDevice mLiveAudioDev;
    private VeLiveMediaPlayer mMediaPlayer;
    private MediaPlayerListener mMediaPlayerListener;
    private VeLiveMixerManager mMixerManager;
    private String mMixBgColor;
    private VeLivePusherDef.VeLiveStreamMixDescription mMixDescription;
    private Context mContext;
    private final String TAG = "LivePusherImpl";
    private LivePusherObserver mPusherObserver;
    private LivePusherCycleInfo mCycleInfo = new LivePusherCycleInfo();
    private final File mParentPath = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "VideoOne/TTSDK");
    private WriterPCMFile mCaptureAudioWriter;
    private WriterPCMFile mPreEncodeAudioWriter;
    private WriterPCMFile mBgmAudioWriter;
    private Object mCaptureVideoStreamHandler;
    private Object mPreEncodeVideoStreamHandler;
    private boolean mIsBgmPlaying;
    private String mBgmFilePath;
    private int mRecordHeight;
    private int mRecordWidth;
    private int mRecordBitrate;
    private int mRecordFps;

    public static LivePusher createLivePusher(Context context, LivePusherObserver observer) {
        return new LivePusherImpl(context, observer);
    }

    private LivePusherImpl(Context context, LivePusherObserver appObserver) {
        Log.d(TAG, "create LivePusherImpl");
        mContext = context;
        mPusherObserver = appObserver;
        initInternal();
        configLivePusher();
        updateOrientation();
    }

    private void updateOrientation() {
        if (LivePusherSettingsHelper.isLandscape()) {
            mLivePusher.setOrientation(VeLiveOrientationLandscape);
        } else {
            mLivePusher.setOrientation(VeLiveOrientationPortrait);
        }
    }

    @Override
    public VeLiveVideoEffectManager getEffectHandler() {
        return mLivePusher.getVideoEffectManager();
    }

    @Override
    public void setOrientation(int orientation) {
        PreferenceUtil.getInstance().setPushOrientation(orientation);
        updateOrientation();
    }

    @Override
    public void setRenderView(View view) {
        Log.d(TAG, "setRenderView");
        if (mLivePusher == null) {
            Log.e(TAG, "setRenderView, mLivePusher is null.");
            return;
        }
        mLivePusher.setRenderView(view);
    }

    @Override
    public void startVideoCapture(int type) {
        Log.d(TAG, "startVideoCapture, type: " + type);
        if (mLivePusher == null) {
            Log.e(TAG, "startVideoCapture, mLivePusher is null.");
            return;
        }
        if (type != -1) {
            mLivePusher.startVideoCapture(convertVideoCaptureType(type));
        }
    }

    @Override
    public void stopVideoCapture() {
        Log.d(TAG, "stopVideoCapture.");
        if (mLivePusher == null) {
            Log.e(TAG, "stopVideoCapture, mLivePusher is null.");
            return;
        }
        if (mLiveCameraDev != null) {
            mLiveCameraDev = null;
        }
        mLivePusher.stopVideoCapture();
    }

    @Override
    public void startAudioCapture(int type) {
        Log.d(TAG, "startAudioCapture, type: " + type);
        if (mLivePusher == null) {
            Log.e(TAG, "startAudioCapture, mLivePusher is null.");
            return;
        }
        mLivePusher.startAudioCapture(convertAudioCaptureType(type));
    }

    @Override
    public void stopAudioCapture() {
        Log.d(TAG, "stopAudioCapture");
        if (mLivePusher == null) {
            Log.e(TAG, "stopAudioCapture, mLivePusher is null.");
            return;
        }
        mLivePusher.stopAudioCapture();
    }

    @Override
    public void startScreenRecording(Intent screenIntent) {
        Log.d(TAG, "startScreenRecording");
        if (mLivePusher == null) {
            Log.e(TAG, "startScreenRecording, mLivePusher is null.");
            return;
        }
        // https://docs.byteplus.com/en/docs/byteplus-media-live/docs-broadcast-sdk-for-android-api#VeLivePusher-startscreenrecording
        // enableAppAudio
        // Whether to record in-app audio data. Currently, you can only set it to true, which is the default value.
        mLivePusher.startScreenRecording(true, screenIntent);
    }

    @Override
    public void stopScreenRecording() {
        Log.d(TAG, "stopScreenRecording");
        if (mLivePusher == null) {
            Log.e(TAG, "stopScreenRecording, mLivePusher is null.");
            return;
        }
        mLivePusher.stopScreenRecording();
    }

    @Override
    public void updateCustomImage(Bitmap bm) {
        Log.d(TAG, "updateCustomImage");
        if (mLivePusher == null) {
            Log.e(TAG, "updateCustomImage, mLivePusher is null.");
            return;
        }
        mLivePusher.updateCustomImage(bm);
    }

    @Override
    public int pushExternalVideoFrame(VideoFrame frame) {
        Log.d(TAG, "pushExternalVideoFrame");
        if (mLivePusher == null) {
            Log.e(TAG, "pushExternalVideoFrame, mLivePusher is null.");
            return -1;
        }
        VeLiveVideoFrame f = convertVideoFrame(frame);
        int ret = mLivePusher.pushExternalVideoFrame(f);
        f.release();
        return ret;
    }

    @Override
    public int pushExternalAudioFrame(AudioFrame frame) {
        Log.d(TAG, "pushExternalAudioFrame");
        if (mLivePusher == null) {
            Log.e(TAG, "pushExternalAudioFrame, mLivePusher is null.");
            return -1;
        }
        return mLivePusher.pushExternalAudioFrame(
                new VeLiveAudioFrame(VeLiveAudioSampleRate44100, VeLiveAudioChannelStereo, frame.pts, frame.buffer));
    }

    @Override
    public void switchVideoCapture(int type) {
        Log.d(TAG, "switchVideoCapture, type: " + type);
        if (mLivePusher == null) {
            Log.e(TAG, "switchVideoCapture, mLivePusher is null.");
            return;
        }
        mLivePusher.switchVideoCapture(convertVideoCaptureType(type));
    }

    @Override
    public void switchAudioCapture(int type) {
        Log.d(TAG, "switchAudioCapture, type: " + type);
        if (mLivePusher == null) {
            Log.e(TAG, "switchAudioCapture, mLivePusher is null.");
            return;
        }
        mLivePusher.switchAudioCapture(convertAudioCaptureType(type));
    }

    @Override
    public int enableTorch(boolean enable) {
        Log.d(TAG, "enableTorch, enable: " + enable);
        if (mLiveCameraDev == null) {
            mLiveCameraDev = mLivePusher.getCameraDevice();
            if (mLiveCameraDev == null) {
                Log.e(TAG, "enableTorch, mLiveCameraDev is null.");
                return -1;
            }
        }
        return mLiveCameraDev.enableTorch(enable);
    }

    @Override
    public void updateSettings(boolean isNeedRebuild) {
        Log.d(TAG, "updateSettings");
        if (isNeedRebuild) {
            releaseInternal();
            initInternal();
        }
        configLivePusher();
        if (isNeedRebuild) {
            updateOrientation();
            mPusherObserver.onRebuildLivePusher();
        }
    }

    @Override
    public void startPush() {
        Log.d(TAG, "startPush, url: " + LivePusherSettingsHelper.getPushUrl());
        if (mLivePusher != null) {
            mLivePusher.startPush(LivePusherSettingsHelper.getPushUrl());
        }
    }

    @Override
    public void stopPush() {
        Log.d(TAG, "stopPush");
        if (mLivePusher != null) {
            mLivePusher.stopPush();
        }
    }

    @Override
    public boolean isMute() {
        Log.d(TAG, "isMute.");
        if (mLivePusher != null) {
            return mLivePusher.isMute();
        }
        return false;
    }

    @Override
    public void setMute(boolean mute) {
        Log.d(TAG, "setMute, mute: " + mute);
        if (mLivePusher != null) {
            mLivePusher.setMute(mute);
        }
    }

    @Override
    public void setFileRecordingConfig(int resolution, int fps, int bitrate) {
        mRecordHeight = LivePusherSettingsHelper.getResolutionHeightVal(resolution);
        mRecordWidth = LivePusherSettingsHelper.getResolutionWidthVal(resolution);
        if (LivePusherSettingsHelper.isLandscape()) {
            int tmp = mRecordHeight;
            mRecordHeight = mRecordWidth;
            mRecordWidth = tmp;
        }
        mRecordFps = LivePusherSettingsHelper.getFpsVal(fps);
        mRecordBitrate = bitrate;
    }

    @Override
    public void startFileRecording(FileRecordingListener listener) {
        Log.d(TAG, "startFileRecording");
        if (mLivePusher != null) {
            VeLivePusherDef.VeLiveFileRecorderConfiguration config = new VeLivePusherDef.VeLiveFileRecorderConfiguration();
            config.setFps(mRecordFps);
            config.setHeight(mRecordHeight);
            config.setWidth(mRecordWidth);
            config.setBitrate(mRecordBitrate);
            File mp4Path = new File(mParentPath, "Record_" + System.currentTimeMillis() + ".mp4");
            File parent = Objects.requireNonNull(mp4Path.getParentFile());
            if (!parent.exists() && !parent.mkdirs()) {
                Log.d(TAG, "startFileRecording failed, can't create parent file: " + parent);
                listener.onFileRecordingError(-1, "failed to create file");
                return;
            }
            mLivePusher.startFileRecording(mp4Path.getAbsolutePath(), config,
                    new VeLivePusherDef.VeLiveFileRecordingListener() {
                        @Override
                        public void onFileRecordingStarted() {
                            if (listener != null) {
                                listener.onFileRecordingStarted();
                            }
                        }

                        @Override
                        public void onFileRecordingStopped() {
                            if (listener != null) {
                                listener.onFileRecordingStopped();
                            }
                            FileUtils.updateToAlbum(mContext, mp4Path);
                        }

                        @Override
                        public void onFileRecordingError(int errorCode, String message) {
                            if (listener != null) {
                                listener.onFileRecordingError(errorCode, message);
                            }
                        }
                    });
        }
    }

    @Override
    public void stopFileRecording() {
        Log.d(TAG, "stopFileRecording");
        if (mLivePusher != null) {
            mLivePusher.stopFileRecording();
        }
    }

    @Override
    public void setVideoMirror(int type, boolean enable) {
        Log.d(TAG, "setVideoMirror, enable: " + enable);
        if (mLivePusher != null) {
            mLivePusher.setVideoMirror(convertMirrorType(type), enable);
        }
    }

    @Override
    public void snapshot() {
        Log.d(TAG, "snapshot");
        if (mLivePusher != null) {
            mLivePusher.snapshot(new VeLivePusherDef.VeLiveSnapshotListener() {
                @Override
                public void onSnapshotComplete(Bitmap image) {
                    File file = new File(mParentPath, "Snapshot_" + System.currentTimeMillis() + ".jpg");
                    Log.d(TAG, "saveBitmap to " + file);
                    boolean retValue = FileUtils.saveBitmap(image, file);
                    if (retValue) {
                        FileUtils.updateToAlbum(mContext, file);
                    } else {
                        Log.i(TAG, "saveBitmap: save failed");
                    }
                }
            });
        }
    }

    @Override
    public void sendSeiMessage(String content, int repeatCount) {
        Log.d(TAG, "sendSeiMessage");
        if (mLivePusher != null) {
            boolean isKeyFrame = true;
            boolean allowCovered = true;
            mLivePusher.sendSeiMessage("test_sei", content, repeatCount, isKeyFrame, isKeyFrame);
        }
    }

    @Override
    public void setWatermark(Bitmap bm, float x, float y, float scale) {
        Log.d(TAG, "setWatermark, x: " + x + ", y: " + y + ", scale: " + scale);
        if (mLivePusher != null) {
            mLivePusher.setWatermark(bm, x, y, scale);
        }
    }

    @Override
    public Object addAudioStream() {
        Log.d(TAG, "addAudioStream");
        if (mLivePusher == null) {
            Log.e(TAG, "addAudioStream, livePusher is null.");
            return null;
        }
        if (mMixerManager == null) {
            mMixerManager = mLivePusher.getMixerManager();
            Log.i(TAG, "addAudioStream, create MixerManager");
        }
        return mMixerManager.addAudioStream();
    }

    @Override
    public void sendAudioFrame(Object streamHandle, AudioFrame frame) {
        if (mMixerManager == null) {
            Log.e(TAG, "sendAudioFrame, mMixerManager is null.");
            return;
        }
        Log.d(TAG, "sendAudioFrame, frame: " + frame.buffer.position());
        mMixerManager.sendCustomAudioFrame(
                new VeLiveAudioFrame(VeLiveAudioSampleRate44100, VeLiveAudioChannelStereo, frame.pts, frame.buffer),
                (int) streamHandle);
    }

    @Override
    public void removeAudioStream(Object streamHandle) {
        Log.d(TAG, "removeAudioStream, streamHandle: " + streamHandle);
        if (mMixerManager == null) {
            Log.e(TAG, "removeAudioStream, mMixerManager is null.");
            return;
        }
        mMixerManager.removeAudioStream((int) streamHandle);
    }

    @Override
    public Object addVideoStream() {
        Log.d(TAG, "addVideoStream");
        if (mLivePusher == null) {
            Log.e(TAG, "addVideoStream, livePusher is null.");
            return null;
        }
        if (mMixerManager == null) {
            mMixerManager = mLivePusher.getMixerManager();
            Log.i(TAG, "addVideoStream, create MixerManager");
        }
        return mMixerManager.addVideoStream();
    }

    @Override
    public void sendVideoFrame(Object streamHandle, VideoFrame frame) {
        if (streamHandle == null) {
            return;
        }
        Log.d(TAG, "sendVideoFrame, bufferType: " + frame.bufferType + ", streamHandle: " + (int) streamHandle);
        sendVideoFrameInner(streamHandle, convertVideoFrame(frame));
    }

    private void sendVideoFrameInner(Object streamHandle, VeLiveVideoFrame frame) {
        if (mMixerManager == null) {
            Log.e(TAG, "sendVideoFrame, mMixerManager is null.");
            return;
        }
        mMixerManager.sendCustomVideoFrame(frame, (int) streamHandle);
    }

    @Override
    public void updateStreamMixDescription(Object streamHandle, float x, float y, float alpha, int renderMode) {
        if (mMixerManager == null) {
            Log.e(TAG, "updateStreamMixDescription, mMixerManager is null.");
            return;
        }
        Log.d(TAG, "updateStreamMixDescription, streamHandle: " + (int) streamHandle + ", x: " + x + ", y: " + y);
        VeLivePusherDef.VeLiveMixVideoLayout layout = new VeLivePusherDef.VeLiveMixVideoLayout();
        layout.x = x;
        layout.y = y;
        layout.width = 0.3f;
        layout.height = 0.3f;
        layout.zOrder = 20;
        layout.alpha = alpha;
        layout.streamId = (int) streamHandle;
        layout.renderMode = convertRenderMode(renderMode);
        if (mMixDescription == null) {
            mMixDescription = new VeLivePusherDef.VeLiveStreamMixDescription();
        }
        mMixDescription.mixVideoStreams.add(layout);
        mMixDescription.backgroundColor = "#" + mMixBgColor;
        mMixerManager.updateStreamMixDescription(mMixDescription);
    }

    @Override
    public void removeVideoStream(Object streamHandle) {
        Log.d(TAG, "removeVideoStream, streamHandle: " + streamHandle);
        if (mMixerManager == null) {
            Log.e(TAG, "removeVideoStream, mMixerManager is null.");
            return;
        }
        mMixerManager.removeVideoStream((int) streamHandle);
    }

    @Override
    public void updateMixBgColor(int color) {
        mMixBgColor = Integer.toHexString(color);
        Log.d(TAG, "updateMixBgColor, color:0x" + mMixBgColor);
        if (mMixerManager == null) {
            Log.e(TAG, "updateMixBgColor, mMixerManager is null.");
            return;
        }
        if (mMixDescription == null) {
            mMixDescription = new VeLivePusherDef.VeLiveStreamMixDescription();
        }
        mMixDescription.backgroundColor = "#" + mMixBgColor;
        mMixerManager.updateStreamMixDescription(mMixDescription);
    }

    @Override
    public float getVoiceLoudness() {
        Log.d(TAG, "getVoiceLoudness");
        if (mLivePusher == null) {
            Log.e(TAG, "getVoiceLoudness, livePusher is null.");
            return 0;
        }
        if (mLiveAudioDev == null) {
            mLiveAudioDev = mLivePusher.getAudioDevice();
        }
        return mLiveAudioDev.getVoiceLoudness();
    }

    @Override
    public void setVoiceLoudness(float level) {
        Log.d(TAG, "setVoiceLoudness, level: " + level);
        if (mLivePusher == null) {
            Log.e(TAG, "setVoiceLoudness, livePusher is null.");
            return;
        }
        if (mLiveAudioDev == null) {
            mLiveAudioDev = mLivePusher.getAudioDevice();
        }
        mLiveAudioDev.setVoiceLoudness(level);
    }

    @Override
    public boolean enableEcho(boolean enable) {
        Log.d(TAG, "enableEcho, enable:" + enable);
        if (mLivePusher == null) {
            Log.e(TAG, "enableEcho, livePusher is null.");
            return false;
        }
        if (mLiveAudioDev == null) {
            mLiveAudioDev = mLivePusher.getAudioDevice();
            return false;
        }
        if (mLiveAudioDev.isSupportHardwareEcho()) {
            mLiveAudioDev.enableEcho(enable);
            return true;
        } else {
            Toast.makeText(mContext, R.string.medialive_audio_echo_not_supported, Toast.LENGTH_SHORT).show();
            return false;
        }
    }

    @Override
    public boolean isEnableEcho() {
        Log.d(TAG, "isEnableEcho");
        if (mLivePusher == null) {
            Log.e(TAG, "isEnableEcho, livePusher is null.");
            return false;
        }
        if (mLiveAudioDev == null) {
            mLiveAudioDev = mLivePusher.getAudioDevice();
            return false;
        }
        return mLiveAudioDev.isEnableEcho();
    }

    @Override
    public int startBgm(String filePath, MediaPlayerListener listener) {
        Log.d(TAG, "startBgm, filePath: " + filePath);
        if (mLivePusher == null) {
            Log.e(TAG, "startBgm, livePusher is null.");
            return -1;
        }
        if (mMediaPlayer == null) {
            mMediaPlayer = mLivePusher.createPlayer();
        }
        mMediaPlayerListener = listener;
        mMediaPlayer.setListener(new VeLivePusherDef.VeLiveMediaPlayerListener() {
            @Override
            public void onProgress(long timeMs) {
                Log.d(TAG, "[onProgress] timeMs: " + timeMs);
                if (mMediaPlayerListener != null) {
                    mMediaPlayerListener.onProgress((int) ((double) timeMs / mMediaPlayer.getDuration() * 100));
                }
            }

            @Override
            public void onError(int code, String msg) {
                String info = "[" + getTimestamp() + "] onError: " +
                        "mediaPlayer, code:" + code +
                        ", msg:" + msg;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onStop() {
                if (mMediaPlayerListener != null) {
                    mMediaPlayerListener.onProgress(0);
                }
                mIsBgmPlaying = false;
//                if (mMediaPlayer != null) {
//                    mMediaPlayer.prepare(filePath);
//                    mMediaPlayer.start();
//                }
            }
        });
        mIsBgmPlaying = true;
        mBgmFilePath = filePath;
        mMediaPlayer.prepare(filePath);
        return mMediaPlayer.start();
    }

    @Override
    public void stopBgm() {
        Log.d(TAG, "stopBgm");
        if (mLivePusher == null) {
            Log.e(TAG, "stopBgm, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        mIsBgmPlaying = false;
        mMediaPlayer.stop();
        mMediaPlayer.release();
        mMediaPlayer = null;
    }

    @Override
    public int seekBgm(int pos) {
        Log.d(TAG, "seekBgm, pos: " + pos);
        if (mLivePusher == null) {
            Log.e(TAG, "seekBgm, livePusher is null.");
            return -1;
        }
        if (mMediaPlayer == null) {
            return -1;
        }
        if (!mIsBgmPlaying && mBgmFilePath != null) {
            mMediaPlayer.prepare(mBgmFilePath);
            mMediaPlayer.start();
        }
        return mMediaPlayer.seek((long) ((double) pos / 100 * mMediaPlayer.getDuration()));
    }

    @Override
    public void resumeBgm() {
        Log.d(TAG, "resumeBgm");
        if (mLivePusher == null) {
            Log.e(TAG, "resumeBgm, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        mMediaPlayer.resume();
    }

    @Override
    public void pauseBgm() {
        Log.d(TAG, "pauseBgm");
        if (mLivePusher == null) {
            Log.e(TAG, "pauseBgm, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        mMediaPlayer.pause();
    }

    @Override
    public void enableBgmMixer(boolean enable) {
        Log.d(TAG, "enableBgmMixer, enable:" + enable);
        if (mLivePusher == null) {
            Log.e(TAG, "enableBgmMixer, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        mMediaPlayer.enableMixer(enable);
    }

    @Override
    public void enableBgmFrameListener(boolean enable) {
        Log.d(TAG, "enableBgmFrameListener, enable:" + enable);
        if (mLivePusher == null) {
            Log.e(TAG, "enableBgmFrameListener, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        if (enable) {
            mMediaPlayer.setFrameListener(new VeLivePusherDef.VeLiveMediaPlayerFrameListener() {
                @Override
                public void onAudioFrame(VeLiveAudioFrame frame) {
                    if (mBgmAudioWriter == null) {
                        mBgmAudioWriter = new WriterPCMFile(frame.getSampleRate().value(), frame.getChannels().value(), 16, "bgmAudio", "le");
                    }
                    byte[] data = new byte[frame.getBuffer().limit()];
                    frame.getBuffer().get(data);
                    mBgmAudioWriter.writeBytes(data);
                }
            });
        } else {
            mMediaPlayer.setFrameListener(null);
            if (mBgmAudioWriter != null) {
                mBgmAudioWriter.finish();
                mBgmAudioWriter = null;
            }
        }
    }

    @Override
    public void setBgmVolume(float volume) {
        Log.d(TAG, "setBgmVolume, volume:" + volume);
        if (mLivePusher == null) {
            Log.e(TAG, "setBgmVolume, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        mMediaPlayer.setBGMVolume(volume);
    }

    @Override
    public void setVoiceVolume(float volume) {
        Log.d(TAG, "setVoiceVolume, volume:" + volume);
        if (mLivePusher == null) {
            Log.e(TAG, "setVoiceVolume, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        mMediaPlayer.setVoiceVolume(volume);
    }

    @Override
    public void enableBgmLoop(boolean loop) {
        Log.d(TAG, "enableBgmLoop, loop:" + loop);
        if (mLivePusher == null) {
            Log.e(TAG, "enableBgmLoop, livePusher is null.");
            return;
        }
        if (mMediaPlayer == null) {
            return;
        }
        mMediaPlayer.enableBGMLoop(loop);
    }

    @NonNull
    @Override
    public VeLivePusherDef.VeLiveAudioFrameSource getObservedAudioFrameSource() {
        return new VeLivePusherDef.VeLiveAudioFrameSource(VeLiveAudioFrameSourceCapture | VeLiveAudioFrameSourcePreEncode);
    }

    @Override
    public void onCaptureAudioFrame(VeLiveAudioFrame frame) {
//        Log.d(TAG, "onCaptureAudioFrame, frame:" + frame.getSampleRate().value() + ", " + frame.getChannels().value());
        if (mCaptureAudioWriter == null) {
            mCaptureAudioWriter = new WriterPCMFile(frame.getSampleRate().value(), frame.getChannels().value(), 16, "captureAudio", "le");
        }
        byte[] data = new byte[frame.getBuffer().limit()];
        frame.getBuffer().get(data);
        mCaptureAudioWriter.writeBytes(data);
    }

    @Override
    public void onPreEncodeAudioFrame(VeLiveAudioFrame frame) {
//        Log.d(TAG, "onPreEncodeAudioFrame, frame:" + frame.getSampleRate().value() + ", " + frame.getChannels().value());
        if (mPreEncodeAudioWriter == null) {
            mPreEncodeAudioWriter = new WriterPCMFile(frame.getSampleRate().value(), frame.getChannels().value(), 16, "preEncodeAudio", "le");
        }
        byte[] data = new byte[frame.getBuffer().limit()];
        frame.getBuffer().get(data);
        mPreEncodeAudioWriter.writeBytes(data);
    }

    @Override
    public void enableAudioFrameListener(boolean enable) {
        Log.d(TAG, "enableAudioFrameListener, enable:" + enable);
        if (mLivePusher == null) {
            Log.e(TAG, "enableAudioFrameListener, livePusher is null.");
            return;
        }
        if (enable) {
            mLivePusher.addAudioFrameListener(this);
        } else {
            mLivePusher.removeAudioFrameListener(this);
            if (mCaptureAudioWriter != null) {
                mCaptureAudioWriter.finish();
                mCaptureAudioWriter = null;
            }
            if (mPreEncodeAudioWriter != null) {
                mPreEncodeAudioWriter.finish();
                mPreEncodeAudioWriter = null;
            }
        }
    }

    @NonNull
    @Override
    public VeLivePusherDef.VeLiveVideoFrameSource getObservedVideoFrameSource() {
        return new VeLivePusherDef.VeLiveVideoFrameSource(VeLiveVideoFrameSourceCapture | VeLiveVideoFrameSourcePreEncode);
    }

    @Override
    public void onCaptureVideoFrame(VeLiveVideoFrame frame) {
        if (mCaptureVideoStreamHandler == null) {
            mCaptureVideoStreamHandler = addVideoStream();
            updateStreamMixDescription(mCaptureVideoStreamHandler, 0, 0.3f, 1.0f, PUSH_VIDEO_RENDER_MODE_FIT);
        }
        sendVideoFrameInner(mCaptureVideoStreamHandler, frame);
    }

    @Override
    public void onPreEncodeVideoFrame(VeLiveVideoFrame frame) {
        if (mPreEncodeVideoStreamHandler == null) {
            mPreEncodeVideoStreamHandler = addVideoStream();
            updateStreamMixDescription(mPreEncodeVideoStreamHandler, 0, 0.6f, 1.0f, PUSH_VIDEO_RENDER_MODE_FIT);
        }
        sendVideoFrameInner(mPreEncodeVideoStreamHandler, frame);
    }

    @Override
    public void enableVideoFrameListener(boolean enable) {
        Log.d(TAG, "enableVideoFrameListener, enable:" + enable);
        if (mLivePusher == null) {
            Log.e(TAG, "enableVideoFrameListener, livePusher is null.");
            return;
        }
        if (enable) {
            mLivePusher.addVideoFrameListener(this);
        } else {
            mLivePusher.removeVideoFrameListener(this);
            if (mCaptureVideoStreamHandler != null) {
                removeVideoStream(mCaptureVideoStreamHandler);
                mCaptureVideoStreamHandler = null;
            }
            if (mPreEncodeVideoStreamHandler != null) {
                removeVideoStream(mPreEncodeVideoStreamHandler);
                mPreEncodeVideoStreamHandler = null;
            }
        }
    }

    @Override
    public void setFocusPosition(int width, int height, int x, int y) {
        Log.d(TAG, "setFocusPosition, x: " + x + ", y: " + y);
        if (mLiveCameraDev == null) {
            mLiveCameraDev = mLivePusher.getCameraDevice();
            if (mLiveCameraDev == null) {
                Log.e(TAG, "setFocusPosition, mLiveCameraDev is null.");
                return;
            }
        }
        mLiveCameraDev.setFocusPosition(width, height, x, y);
    }

    @Override
    public float getCurrentZoomRatio() {
        Log.d(TAG, "getCurrentZoomRatio");
        if (mLiveCameraDev == null) {
            mLiveCameraDev = mLivePusher.getCameraDevice();
            if (mLiveCameraDev == null) {
                Log.e(TAG, "getCurrentZoomRatio, mLiveCameraDev is null.");
                return 1;
            }
        }
        return mLiveCameraDev.getCurrentZoomRatio();
    }

    @Override
    public float getMaxZoomRatio() {
        Log.d(TAG, "getMaxZoomRatio");
        if (mLiveCameraDev == null) {
            mLiveCameraDev = mLivePusher.getCameraDevice();
            if (mLiveCameraDev == null) {
                Log.e(TAG, "getMaxZoomRatio, mLiveCameraDev is null.");
                return 1;
            }
        }
        return mLiveCameraDev.getMaxZoomRatio();
    }

    @Override
    public float getMinZoomRatio() {
        Log.d(TAG, "getMinZoomRatio");
        if (mLiveCameraDev == null) {
            mLiveCameraDev = mLivePusher.getCameraDevice();
            if (mLiveCameraDev == null) {
                Log.e(TAG, "getMinZoomRatio, mLiveCameraDev is null.");
                return 1;
            }
        }
        return mLiveCameraDev.getMinZoomRatio();
    }

    @Override
    public void setZoomRatio(float ratio) {
        Log.d(TAG, "setZoomRatio, ratio: " + ratio);
        if (mLiveCameraDev == null) {
            mLiveCameraDev = mLivePusher.getCameraDevice();
            if (mLiveCameraDev == null) {
                Log.e(TAG, "setZoomRatio, mLiveCameraDev is null.");
                return;
            }
        }
        mLiveCameraDev.setZoomRatio(ratio);
    }

    @Override
    public void release() {
        Log.d(TAG, "release");
        releaseInternal();
    }

    private static String getTimestamp() {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss:SSS", Locale.ENGLISH);
        return sdf.format(new Date());
    }

    private void initInternal() {
        VeLivePusherConfiguration config = new VeLivePusherConfiguration()
                .setContext(mContext)
                .setVideoCaptureConfig(new VeLivePusherDef.VeLiveVideoCaptureConfiguration()
                        .setFps(LivePusherSettingsHelper.getCaptureFpsVal())
                        .setWidth(LivePusherSettingsHelper.getCaptureWidthVal())
                        .setHeight(LivePusherSettingsHelper.getCaptureHeightVal()))
                .setAudioCaptureConfig(new VeLivePusherDef.VeLiveAudioCaptureConfiguration());
        config.getExtraParams().mPushBase.projectKey = "VeLivePusher";
        mLivePusher = config.build();
        mLivePusher.setObserver(new VeLivePusherObserver() {
            @Override
            public void onError(int code, int subCode, String msg) {
                String info = "[" + getTimestamp() + "] onError: " +
                        ", ErrCode:" + code +
                        ", SubCode:" + subCode +
                        ", ErrMsg:" + msg;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onStatusChange(VeLivePusherDef.VeLivePusherStatus status) {
                String info = "[" + getTimestamp() + "] onStatusChange: " +
                        ", status:" + status;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onFirstVideoFrame(VeLivePusherDef.VeLiveFirstFrameType type, long timestampMs) {
                String info = "[" + getTimestamp() + "] onFirstVideoFrame: " +
                        ", type:" + type +
                        ", timestampMs:" + timestampMs;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onFirstAudioFrame(VeLivePusherDef.VeLiveFirstFrameType type, long timestampMs) {
                String info = "[" + getTimestamp() + "] onFirstAudioFrame: " +
                        ", type:" + type +
                        ", timestampMs:" + timestampMs;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onCameraOpened(boolean open) {
                String info = "[" + getTimestamp() + "] onCameraOpened: " +
                        ", open:" + open;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onMicrophoneOpened(boolean open) {
                Log.d(TAG, "[onMicrophoneOpened] open: " + open);
                String info = "[" + getTimestamp() + "] onMicrophoneOpened: " +
                        ", open:" + open;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onScreenRecording(boolean open) {
                String info = "[" + getTimestamp() + "] onScreenRecording: " +
                        ", open:" + open;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }

            @Override
            public void onNetworkQuality(VeLivePusherDef.VeLiveNetworkQuality quality) {
                String info = "[" + getTimestamp() + "] onNetworkQuality: " +
                        ", quality:" + quality;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                    if (quality == VeLiveNetworkQualityUnknown) {
                        mPusherObserver.onNetworkQuality(PreferenceUtil.NETWORK_QUALITY_UNKNOWN);
                    } else if (quality == VeLiveNetworkQualityBad) {
                        mPusherObserver.onNetworkQuality(PreferenceUtil.NETWORK_QUALITY_BAD);
                    } else if (quality == VeLiveNetworkQualityPoor) {
                        mPusherObserver.onNetworkQuality(PreferenceUtil.NETWORK_QUALITY_POOR);
                    } else if (quality == VeLiveNetworkQualityGood) {
                        mPusherObserver.onNetworkQuality(PreferenceUtil.NETWORK_QUALITY_GOOD);
                    }
                }
            }

            @Override
            public void onAudioPowerQuality(VeLivePusherDef.VeLiveAudioPowerLevel level, float value) {
                String info = "[" + getTimestamp() + "] onAudioPowerQuality: " +
                        ", level:" + level +
                        ", value:" + value;
                Log.d(TAG, info);
                if (mPusherObserver != null) {
                    mPusherObserver.onCallbackRecordUpdate(info);
                }
            }
        });
        mLivePusher.setStatisticsObserver(new VeLivePusherDef.VeLivePusherStatisticsObserver() {
            @Override
            public void onStatistics(VeLivePusherDef.VeLivePusherStatistics statistics) {
                mCycleInfo.url = statistics.url;
                mCycleInfo.encodeWidth = statistics.encodeWidth;
                mCycleInfo.encodeHeight = statistics.encodeHeight;
                mCycleInfo.captureWidth = statistics.captureWidth;
                mCycleInfo.captureHeight = statistics.captureHeight;
                mCycleInfo.captureFps = statistics.captureFps;
                mCycleInfo.encodeFps = statistics.encodeFps;
                mCycleInfo.transportFps = statistics.transportFps;
                mCycleInfo.fps = statistics.fps;
                mCycleInfo.videoBitrate = statistics.videoBitrate;
                mCycleInfo.minVideoBitrate = statistics.minVideoBitrate;
                mCycleInfo.maxVideoBitrate = statistics.maxVideoBitrate;
                mCycleInfo.encodeVideoBitrate = statistics.encodeVideoBitrate;
                mCycleInfo.transportVideoBitrate = statistics.transportVideoBitrate;
                mCycleInfo.encodeAudioBitrate = statistics.encodeAudioBitrate;
                mCycleInfo.videoCodec = statistics.codec;
//                Log.d(TAG, "[onStatistics]: " + mCycleInfo);
                if (mPusherObserver != null) {
                    mPusherObserver.onCycleInfoUpdate(mCycleInfo);
                }
            }

            @Override
            public void onLogMonitor(JSONObject logInfo) {
                VeLivePusherDef.VeLivePusherStatisticsObserver.super.onLogMonitor(logInfo);
            }
        }, 5);
    }

    private void releaseInternal() {
        if (mLiveCameraDev != null) {
            mLiveCameraDev = null;
        }
        if (mMediaPlayer != null) {
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
        if (mLivePusher == null) {
            Log.e(TAG, "release, mLivePusher is null.");
            return;
        }
        mLivePusher.release();
        mLivePusher = null;
    }

    private void configLivePusher() {
        VeLivePusherDef.VeLiveVideoEncoderConfiguration videoConfig = mLivePusher.getVideoEncoderConfiguration();
        videoConfig.setFps(LivePusherSettingsHelper.getEncodeFpsVal());
        videoConfig.setResolution(convertVideoResolution(LivePusherSettingsHelper.getEncodeResolutionSettings()));
        mLivePusher.setVideoEncoderConfiguration(videoConfig);

        VeLivePusherDef.VeLiveAudioEncoderConfiguration audioConfig = new VeLivePusherDef.VeLiveAudioEncoderConfiguration();
        audioConfig.setSampleRate(convertAudioEncodeSampleRate(LivePusherSettingsHelper.getAudioEncodeSampleRate()));
        mLivePusher.setAudioEncoderConfiguration(audioConfig);
    }

    private static VeLivePusherDef.VeLiveVideoResolution convertVideoResolution(int res) {
        switch (res) {
            case RESOLUTION_360P:
                return VeLiveVideoResolution360P;
            case RESOLUTION_480P:
                return VeLiveVideoResolution480P;
            case RESOLUTION_540P:
                return VeLiveVideoResolution540P;
            case RESOLUTION_1080P:
                return VeLiveVideoResolution1080P;

            case RESOLUTION_720P:
            default:
                return VeLiveVideoResolution720P;
        }
    }

    private VeLivePusherDef.VeLiveVideoCaptureType convertVideoCaptureType(int type) {
        switch (type) {
            case PUSH_VIDEO_CAPTURE_BACK:
                return VeLiveVideoCaptureBackCamera;
            case PUSH_VIDEO_CAPTURE_DUAL:
                return VeLiveVideoCaptureDualCamera;
            case PUSH_VIDEO_CAPTURE_SCREEN:
                return VeLiveVideoCaptureScreen;
            case PUSH_VIDEO_CAPTURE_EXTERNAL:
                return VeLiveVideoCaptureExternal;
            case PUSH_VIDEO_CAPTURE_CUSTOM_IMAGE:
                return VeLiveVideoCaptureCustomImage;
            case PUSH_VIDEO_CAPTURE_LAST_FRAME:
                return VeLiveVideoCaptureLastFrame;
            case PUSH_VIDEO_CAPTURE_DUMMY_FRAME:
                return VeLiveVideoCaptureDummyFrame;

            case PUSH_VIDEO_CAPTURE_FRONT:
            default:
                return VeLiveVideoCaptureFrontCamera;
        }
    }

    private static VeLivePusherDef.VeLiveAudioCaptureType convertAudioCaptureType(int type) {
        switch (type) {
            case PUSH_AUDIO_CAPTURE_VOICE_COMMUNICATION:
                return VeLiveAudioCaptureVoiceCommunication;
            case PUSH_AUDIO_CAPTURE_VOICE_RECOGNITION:
                return VeLiveAudioCaptureVoiceRecognition;
            case PUSH_AUDIO_CAPTURE_EXTERNAL:
                return VeLiveAudioCaptureExternal;
            case PUSH_AUDIO_CAPTURE_MUTE_FRAME:
                return VeLiveAudioCaptureMuteFrame;

            case PUSH_AUDIO_CAPTURE_MICROPHONE:
            default:
                return VeLiveAudioCaptureMicrophone;
        }
    }

    private static VeLivePusherDef.VeLiveVideoMirrorType convertMirrorType(int type) {
        switch (type) {
            case PUSH_VIDEO_PREVIEW_MIRROR:
                return VeLiveVideoMirrorPreview;
            case PUSH_VIDEO_PUSH_MIRROR:
                return VeLiveVideoMirrorPushStream;

            case PUSH_VIDEO_CAPTURE_MIRROR:
            default:
                return VeLiveVideoMirrorCapture;
        }
    }

    private static VeLiveVideoFrame convertVideoFrame(VideoFrame frame) {
        if (frame.bufferType == VideoFrame.VIDEO_BUFFER_TYPE_TEXTURE_ID) {
            VeLiveVideoFrame tmp = new VeLiveVideoFrame(frame.width, frame.height, frame.pts,
                    frame.textureId,
                    (frame.pixelFormat == VideoFrame.VIDEO_PIXEL_FMT_OES_TEXTURE), null);

            tmp.setRotation(convertRotation(frame.rotation));

            return tmp;
        } else if (frame.bufferType == VideoFrame.VIDEO_BUFFER_TYPE_BYTE_BUFFER) {
            VeLiveVideoFrame tmp = new VeLiveVideoFrame(frame.width, frame.height, frame.pts, frame.buffer);
            tmp.setPixelFormat(convertPixelFmt(frame.pixelFormat));
            tmp.setRotation(convertRotation(frame.rotation));

            return tmp;
        } else if (frame.bufferType == VideoFrame.VIDEO_BUFFER_TYPE_BYTE_ARRAY) {
            VeLiveVideoFrame tmp = new VeLiveVideoFrame(frame.width, frame.height, frame.pts, frame.data);
            tmp.setPixelFormat(convertPixelFmt(frame.pixelFormat));
            tmp.setRotation(convertRotation(frame.rotation));

            return tmp;
        } else {
            return null;
        }
    }

    private static VeLivePusherDef.VeLivePixelFormat convertPixelFmt(int fmt) {
        switch (fmt) {
            case VideoFrame.VIDEO_PIXEL_FMT_NV12:
                return VeLivePixelFormatNV12;
            case VideoFrame.VIDEO_PIXEL_FMT_NV21:
                return VeLivePixelFormatNV21;

            case VideoFrame.VIDEO_PIXEL_FMT_I420:
            default:
                return VeLivePixelFormatI420;
        }
    }

    private static VeLivePusherDef.VeLiveVideoRotation convertRotation(int rotation) {
        switch (rotation) {
            case VideoFrame.VIDEO_ROTATION_1:
                return VeLiveVideoRotation90;
            case VideoFrame.VIDEO_ROTATION_2:
                return VeLiveVideoRotation180;
            case VideoFrame.VIDEO_ROTATION_3:
                return VeLiveVideoRotation270;

            case VideoFrame.VIDEO_ROTATION_0:
            default:
                return VeLiveVideoRotation0;
        }
    }

    private static VeLivePusherDef.VeLivePusherRenderMode convertRenderMode(int mode) {
        switch (mode) {
            case PUSH_VIDEO_RENDER_MODE_FILL:
                return VeLivePusherRenderModeFill;
            case PUSH_VIDEO_RENDER_MODE_HIDDEN:
                return VeLivePusherRenderModeHidden;

            case PUSH_VIDEO_RENDER_MODE_FIT:
            default:
                return VeLivePusherRenderModeFit;
        }
    }

    private static VeLivePusherDef.VeLiveAudioSampleRate convertAudioEncodeSampleRate(int index) {
        switch (index) {
            case PUSH_AUDIO_SAMPLE_RATE_8K:
                return VeLiveAudioSampleRate8000;
            case PUSH_AUDIO_SAMPLE_RATE_16K:
                return VeLiveAudioSampleRate16000;
            case PUSH_AUDIO_SAMPLE_RATE_32K:
                return VeLiveAudioSampleRate32000;
            case PUSH_AUDIO_SAMPLE_RATE_48K:
                return VeLiveAudioSampleRate48000;

            case PUSH_AUDIO_SAMPLE_RATE_44_1K:
            default:
                return VeLiveAudioSampleRate44100;
        }
    }
}
