// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher.ui.activities;

import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_EXTERNAL;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_MICROPHONE;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_CAPTURE_VOICE_COMMUNICATION;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_ORIENTATION_LANDSCAPE;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_ORIENTATION_PORTRAIT;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_BACK;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_CUSTOM_IMAGE;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_DUMMY_FRAME;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_EXTERNAL;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_FRONT;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_SCREEN;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.projection.MediaProjectionManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.activity.OnBackPressedCallback;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.constraintlayout.widget.Guideline;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;

import com.byteplus.live.common.DensityUtils;
import com.byteplus.live.common.KeepLiveService;
import com.byteplus.live.common.panel.MultiInfoPanel;
import com.byteplus.live.common.panel.SingleInfoPanel;
import com.byteplus.live.pusher.EaseBounceOutInterpolator;
import com.byteplus.live.pusher.LivePusher;
import com.byteplus.live.pusher.LivePusherCycleInfo;
import com.byteplus.live.pusher.LivePusherImpl;
import com.byteplus.live.pusher.LivePusherSettingsHelper;
import com.byteplus.live.pusher.MediaFileReader;
import com.byteplus.live.pusher.MediaResourceMgr;
import com.byteplus.live.pusher.R;
import com.byteplus.live.pusher.TextureMgr;
import com.byteplus.live.pusher.YuvHelper;
import com.byteplus.live.pusher.ui.widget.LiveSettingDialog;
import com.byteplus.live.pusher.ui.widget.PreviewSettingsDialog;
import com.byteplus.live.pusher.ui.widget.PusherInfoDialog;
import com.byteplus.live.pusher.utils.RawFile;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class LivePushActivity extends AppCompatActivity
        implements ILivePusherActivity {

    public static final String EXTRA_CAPTURE_TYPE = "extra_live_capture_type";

    private static final String TAG = LivePushActivity.class.getSimpleName();
    private boolean mIsLive = false;
    private boolean mIsClosing = false;
    private LivePusher mLivePusher;
    private Intent mScreenIntent = null;

    Bitmap mPushPic;

    public static final int REQUEST_CODE_SCAN_SEI = 115;
    public static final int REQUEST_CODE_SCAN_URL = 116;

    private PreviewSettingsDialog mPreviewSettingsDialog = null;
    private LiveSettingDialog mLiveSettingDialog = null;
    private PusherInfoDialog mPusherInfoDialog = null;
    private int mCaptureMode;
    private boolean mIsCapturing = false;
    private static boolean mIsFrontCamera = true;
    private boolean mIsTorchEnable = false;

    private LivePusherCycleInfo mCycleInfo;
    private SingleInfoPanel mCycleInfoPanel;
    private MultiInfoPanel mCallbackInfoPanel;

    private static final int[] CaptureModeTitles = {
            R.string.medialive_camera,
            R.string.medialive_voice_darkframe,
            R.string.medialive_screen_capture,
            R.string.medialive_video_file,
    };
    private SurfaceView mPreviewView;
    private FrameLayout mViewContainer;
    View mPreviewFlip, mPreviewTorch, mPreviewEffect, mPreviewDirection, mPreviewSetting, mStartLive, mPicAction;
    View mPushingMic, mPushingCamera, mPushingTorch, mPushingEffect, mPushingSetting, mPushingInfo;
    private ImageView mNetworkStateImage;
    private final Map<View, boolean[]> mSettingsVisibilityMap = new HashMap<>();
    private ExternalCaptureSource mExternalCaptureSource;

    private ChoosePicListener mChoosePicListener;

    int audioCaptureType = PUSH_AUDIO_CAPTURE_MICROPHONE;
    int videoCaptureType = PUSH_VIDEO_CAPTURE_FRONT;
    private CameraFocusRunnable mCameraFocusRunnable;
    private float mCurScale = 1.F;

    private boolean mKeepLiveServiceConnectionIsConnected;
    private final ServiceConnection mKeepLiveServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            mKeepLiveServiceConnectionIsConnected = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            mKeepLiveServiceConnectionIsConnected = false;
        }
    };

    LivePusher.LivePusherObserver mObserver = new LivePusher.LivePusherObserver() {
        @Override
        public void onCycleInfoUpdate(LivePusherCycleInfo info) {
            mCycleInfo = info;
            Log.d(TAG, info.toString());
            SingleInfoPanel panel = mCycleInfoPanel;
            if (panel != null) {
                runOnUiThread(() -> panel.updateContent(info.toString()));
            }
        }

        @Override
        public void onCallbackRecordUpdate(String content) {
            if (content == null) {
                return;
            }
            Log.d(TAG, content);
            MultiInfoPanel panel = mCallbackInfoPanel;
            if (panel != null) {
                runOnUiThread(() -> panel.appendContent(content));
            }
        }

        @Override
        public void onNetworkQuality(int quality) {
            runOnUiThread(() -> mNetworkStateImage.setImageLevel(quality));
        }

        @Override
        public void onRebuildLivePusher() {
            mScreenIntent = null;
            destroyPreview();
            initEffect();
            preparePreview();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        if (LivePusherSettingsHelper.isLandscape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
        Intent intent = getIntent();
        mCaptureMode = intent.getIntExtra(EXTRA_CAPTURE_TYPE, LiveCaptureType.CAMERA);
        setContentView(R.layout.activity_live_push);
        initUI();

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        mLivePusher = LivePusherImpl.createLivePusher(this, mObserver);
        initEffect();
        preparePreview();

        getOnBackPressedDispatcher().addCallback(new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                // Intentional do nothing
            }
        });
    }


    private void initEffect() {
    }

    private void destroyPreview() {
        if (mPreviewView != null) {
            mIsCapturing = false;
            mSettingsVisibilityMap.remove(mPreviewView);
            mViewContainer.removeView(mPreviewView);
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void preparePreview() {
        mCameraFocusRunnable = new CameraFocusRunnable();
        stopKeepLive();
        mSettingsVisibilityMap.put(mPreviewView = new SurfaceView(this), new boolean[]{true, true, false, true});
        ScaleGestureDetector scaleDetector = new ScaleGestureDetector(this, new ScaleGestureDetector.OnScaleGestureListener() {
            @Override
            public boolean onScale(@NonNull ScaleGestureDetector detector) {
                float scale = detector.getScaleFactor();
                mCurScale *= scale;
                if (mCurScale < mLivePusher.getMinZoomRatio()) {
                    mCurScale = mLivePusher.getMinZoomRatio();
                } else if (mCurScale > mLivePusher.getMaxZoomRatio()) {
                    mCurScale = mLivePusher.getMaxZoomRatio();
                }
                mLivePusher.setZoomRatio(mCurScale);
                return true;
            }

            @Override
            public boolean onScaleBegin(@NonNull ScaleGestureDetector detector) {
                return true;
            }

            @Override
            public void onScaleEnd(@NonNull ScaleGestureDetector detector) {
            }
        });
        GestureDetector gestureDetector = new GestureDetector(this, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(@NonNull MotionEvent event) {
                mPreviewView.removeCallbacks(mCameraFocusRunnable);
                mCameraFocusRunnable.setPoint(event.getX(), event.getY());
                mPreviewView.postDelayed(mCameraFocusRunnable, 200);
                return true;
            }
        });
        mPreviewView.setOnTouchListener((view, event) -> {
            if (mCaptureMode != LiveCaptureType.CAMERA) {
                return false;
            }
            boolean handled = scaleDetector.onTouchEvent(event);
            handled = gestureDetector.onTouchEvent(event) || handled;
            return handled;
        });
        mViewContainer.addView(mPreviewView);
        mPreviewView.setZOrderMediaOverlay(true);
        mLivePusher.setRenderView(mPreviewView);
        for (Map.Entry<View, boolean[]> entry : mSettingsVisibilityMap.entrySet()) {
            entry.getKey().setVisibility(entry.getValue()[mCaptureMode] ? View.VISIBLE : View.GONE);
        }
        if (mCaptureMode == LiveCaptureType.FILE) {
            checkCaptureTypeFileResources();
        } else {
            startCaptureMode(mCaptureMode);
        }
    }

    private void startKeepLive() {
        Intent intent = new Intent(this, KeepLiveService.class);
        bindService(intent, mKeepLiveServiceConnection, BIND_AUTO_CREATE);
    }

    private void stopKeepLive() {
        stopService(new Intent(this, KeepLiveService.class));
    }

    private void startCaptureMode(int captureMode) {
        if (mIsCapturing) {
            if (mCaptureMode == LiveCaptureType.FILE) {
                if (mExternalCaptureSource != null) {
                    mExternalCaptureSource.stop();
                }
            } else if (mCaptureMode == LiveCaptureType.SCREEN) {
                mLivePusher.stopScreenRecording();
                stopKeepLive();
            }
        }
        if (captureMode == LiveCaptureType.CAMERA) {
            audioCaptureType = PUSH_AUDIO_CAPTURE_MICROPHONE;
            videoCaptureType = mIsFrontCamera ? PUSH_VIDEO_CAPTURE_FRONT : PUSH_VIDEO_CAPTURE_BACK;
        } else if (captureMode == LiveCaptureType.AUDIO) {
            audioCaptureType = PUSH_AUDIO_CAPTURE_MICROPHONE;
            videoCaptureType = PUSH_VIDEO_CAPTURE_DUMMY_FRAME;
        } else if (captureMode == LiveCaptureType.SCREEN) {
            if (!checkPermission()) {
                return;
            }
            mLivePusher.startScreenRecording(mScreenIntent);
            audioCaptureType = PUSH_AUDIO_CAPTURE_VOICE_COMMUNICATION;
            videoCaptureType = PUSH_VIDEO_CAPTURE_SCREEN;
        } else if (captureMode == LiveCaptureType.FILE) {
            if (mExternalCaptureSource == null) {
                mExternalCaptureSource = new ExternalCaptureSource();
            }
            mExternalCaptureSource.start();
            audioCaptureType = PUSH_AUDIO_CAPTURE_EXTERNAL;
            videoCaptureType = PUSH_VIDEO_CAPTURE_EXTERNAL;
        }
        mCaptureMode = captureMode;
        if (captureMode != LiveCaptureType.SCREEN) {
            if (!mIsCapturing) {
                mLivePusher.startVideoCapture(videoCaptureType);
                mLivePusher.startAudioCapture(audioCaptureType);
            } else {
                mLivePusher.switchAudioCapture(audioCaptureType);
                mLivePusher.switchVideoCapture(videoCaptureType);
            }
            mIsCapturing = true;
        }
    }

    private void stopCaptureMode() {
        if (!mIsCapturing) {
            return;
        }
        if (mCaptureMode == LiveCaptureType.FILE) {
            if (mExternalCaptureSource != null) {
                mExternalCaptureSource.stop();
            }
        } else if (mCaptureMode == LiveCaptureType.SCREEN) {
            mLivePusher.stopScreenRecording();
            stopKeepLive();
        }
        mLivePusher.stopVideoCapture();
        mLivePusher.stopAudioCapture();
        mIsCapturing = false;
    }

    private void initUI() {
        Guideline guidelineTop = findViewById(R.id.guideline_top);
        Guideline guidelineStart = findViewById(R.id.guideline_start);
        Guideline guidelineEnd = findViewById(R.id.guideline_end);
        ViewCompat.setOnApplyWindowInsetsListener(guidelineTop, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            guidelineStart.setGuidelineBegin(insets.left);
            guidelineTop.setGuidelineBegin(insets.top);
            guidelineEnd.setGuidelineEnd(insets.right);
            return windowInsets;
        });

        mViewContainer = findViewById(R.id.view_container);

        mViewContainer.post(this::updateLayoutByOrientation);
        mSettingsVisibilityMap.put(mPicAction = findViewById(R.id.pic_action), new boolean[]{false, true, false, false});
        mSettingsVisibilityMap.put(mPreviewFlip = findViewById(R.id.preview_flip), new boolean[]{true, false, false, false});
        mSettingsVisibilityMap.put(mPreviewTorch = findViewById(R.id.preview_torch), new boolean[]{true, false, false, false});
        mSettingsVisibilityMap.put(mPreviewEffect = findViewById(R.id.preview_effect), new boolean[]{true, false, false, false});
        mSettingsVisibilityMap.put(mPreviewDirection = findViewById(R.id.preview_direction), new boolean[]{true, true, true, true});

        mSettingsVisibilityMap.put(mPushingMic = findViewById(R.id.pushing_mic), new boolean[]{true, true, true, true});
        mSettingsVisibilityMap.put(mPushingCamera = findViewById(R.id.pushing_camera), new boolean[]{true, false, false, false});
        mSettingsVisibilityMap.put(mPushingTorch = findViewById(R.id.pushing_torch), new boolean[]{true, false, false, false});
        mSettingsVisibilityMap.put(mPushingEffect = findViewById(R.id.pushing_effect), new boolean[]{true, false, false, false});

        mPreviewSetting = findViewById(R.id.preview_setting);
        mStartLive = findViewById(R.id.start_Live);

        mPushingSetting = findViewById(R.id.pushing_setting);
        mPushingInfo = findViewById(R.id.pushing_info);

        mNetworkStateImage = findViewById(R.id.net_state);

        mCycleInfoPanel = new SingleInfoPanel(R.string.medialive_cycle_info, findViewById(R.id.medialive_cycle_info));
        mCallbackInfoPanel = new MultiInfoPanel(R.string.medialive_callback_info, findViewById(R.id.medialive_callback_info));
        mInfoListener.onEnableCycleInfo(false);
        mInfoListener.onEnableCallbackRecord(false);

        registerClickListener();
    }

    private void registerClickListener() {
        mPreviewFlip.setOnClickListener(v -> switchCamera());
        mPushingCamera.setOnClickListener(v -> switchCamera());

        mPreviewTorch.setOnClickListener(v -> switchTorch());
        mPushingTorch.setOnClickListener(v -> switchTorch());

        mPreviewEffect.setOnClickListener(v -> showEffectDialog());
        mPushingEffect.setOnClickListener(v -> showEffectDialog());

        mPreviewDirection.setOnClickListener(v -> switchOrientation());

        mPreviewSetting.setOnClickListener(v -> showPreviewSettingsDialog());

        mStartLive.setOnClickListener(v -> startPublish());

        mPushingMic.setOnClickListener(this::switchMic);
        mPushingMic.setSelected(true); // Default to Microphone ON

        mPushingSetting.setOnClickListener(v -> showLiveSettingsDialog());

        mPushingInfo.setOnClickListener(v -> showPusherInfoDialog());

        findViewById(R.id.close).setOnClickListener(v -> close());

        mPicAction.setOnClickListener(v -> onPicActionClicked());
    }

    private void showEffectDialog() {
    }

    private void switchOrientation() {
        if (LivePusherSettingsHelper.isLandscape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            mLivePusher.setOrientation(PUSH_ORIENTATION_PORTRAIT);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            mLivePusher.setOrientation(PUSH_ORIENTATION_LANDSCAPE);
        }

        mViewContainer.post(this::updateLayoutByOrientation);

        if (mPreviewSettingsDialog != null) {
            mPreviewSettingsDialog.dismiss();
            mPreviewSettingsDialog = null;
        }
    }

    private void showPreviewSettingsDialog() {
        if (mPreviewSettingsDialog == null) {
            mPreviewSettingsDialog = new PreviewSettingsDialog(LivePushActivity.this, mInfoListener, mCaptureMode, mLivePusher);
        }
        mPreviewSettingsDialog.show();
    }

    private void showLiveSettingsDialog() {
        if (mLiveSettingDialog == null) {
            mLiveSettingDialog = new LiveSettingDialog(LivePushActivity.this, mLivePusher, mCaptureMode);
        }
        mLiveSettingDialog.show();
    }

    private void showPusherInfoDialog() {
        if (mPusherInfoDialog == null) {
            mPusherInfoDialog = new PusherInfoDialog(LivePushActivity.this, mInfoListener);
        }
        mPusherInfoDialog.show();
    }

    private void close() {
        mIsClosing = true;
        finish();
    }

    void onPicActionClicked() {
        if (mPushPic == null) {
            choosePic(mVoiceCaptureImageListener);
        } else {
            new AlertDialog.Builder(this)
                    .setTitle(R.string.medialive_choose_pic)
                    .setItems(R.array.pic_actions, (dialog, which) -> {
                        if (which == 0) {
                            choosePic(mVoiceCaptureImageListener);
                        } else {
                            removePic();
                        }
                    })
                    .show();
        }
    }

    private void removePic() {
        if (mPushPic != null) {
            mPushPic = null;
            mLivePusher.switchVideoCapture(PUSH_VIDEO_CAPTURE_DUMMY_FRAME);
        }
    }

    private final LivePusher.InfoListener mInfoListener = new LivePusher.InfoListener() {
        @Override
        public void updateSettings(boolean isNeedRebuild) {
            Log.d(TAG, "updateSettings, isNeedRebuild: " + isNeedRebuild);
            mLivePusher.updateSettings(isNeedRebuild);
            if (mExternalCaptureSource != null) {
                mExternalCaptureSource.updateVideoFrameType();
            }
        }

        @Override
        public void onEnableCycleInfo(boolean enable) {
            SingleInfoPanel panel = mCycleInfoPanel;
            if (panel != null) {
                runOnUiThread(() -> {
                    panel.setEnabled(enable);
                    LivePusherCycleInfo info = mCycleInfo;
                    if (enable && info != null) {
                        panel.updateContent(info.toString());
                    }
                });
            }
        }

        @Override
        public void onEnableCallbackRecord(boolean enable) {
            MultiInfoPanel panel = mCallbackInfoPanel;
            if (panel != null) {
                runOnUiThread(() -> panel.setEnabled(enable));
            }
        }
    };

    private boolean checkPermission() {
        if (mScreenIntent == null) {
            if (android.os.Build.VERSION.SDK_INT > android.os.Build.VERSION_CODES.LOLLIPOP) {
                MediaProjectionManager mgr = (MediaProjectionManager) getSystemService(Context.MEDIA_PROJECTION_SERVICE);
                Intent intent = mgr.createScreenCaptureIntent();
                mediaProjectionLauncher.launch(intent);
            }
            return false;
        }


        return true;
    }

    final ActivityResultLauncher<Intent> mediaProjectionLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() == RESULT_OK) {
                    mScreenIntent = result.getData();
                    startKeepLive();
                    startCaptureMode(LiveCaptureType.SCREEN);
                }
            });

    private void checkCaptureTypeFileResources() {
        Context context = LivePushActivity.this;
        Toast.makeText(context, R.string.medialive_preparing, Toast.LENGTH_SHORT).show();
        List<RawFile> fileNameList = new ArrayList<>();
        if (!MediaResourceMgr.isLocalFileReady(context, MediaResourceMgr.RawAudio.PCM_1)) {
            fileNameList.add(MediaResourceMgr.RawAudio.PCM_1);
        }
        if (!MediaResourceMgr.isLocalFileReady(context, MediaResourceMgr.RawVideo.NV21)) {
            fileNameList.add(MediaResourceMgr.RawVideo.NV21);
        }
        if (fileNameList.isEmpty()) {
            Toast.makeText(context, R.string.medialive_load_completed, Toast.LENGTH_SHORT).show();
            // All file downloaded
            startCaptureMode(LiveCaptureType.FILE);
            return;
        }
        MediaResourceMgr.downloadOnlineResource(context, fileNameList, new MediaResourceMgr.DownloadListener() {
            @Override
            public void onSuccess() {
                // All file downloaded
                if (!isFinishing()) {
                    Toast.makeText(context, R.string.medialive_load_completed, Toast.LENGTH_SHORT).show();
                    startCaptureMode(LiveCaptureType.FILE);
                }
            }

            public void onFail() {
                if (!isFinishing()) {
                    finish();
                }
            }
        });
    }

    private void switchCamera() {
        if (mCaptureMode != LiveCaptureType.CAMERA) {
            Toast.makeText(this, R.string.medialive_camera_flip_unsupported, Toast.LENGTH_SHORT).show();
            return;
        }
        mIsFrontCamera = !mIsFrontCamera;
        if (mIsFrontCamera) {
            mIsTorchEnable = false;
            mPushingTorch.setSelected(false);
            mPreviewTorch.setSelected(false);
        }
        mLivePusher.switchVideoCapture(mIsFrontCamera ? PUSH_VIDEO_CAPTURE_FRONT : PUSH_VIDEO_CAPTURE_BACK);
    }

    private void switchTorch() {
        if (mCaptureMode != LiveCaptureType.CAMERA || mIsFrontCamera) {
            Toast.makeText(this, R.string.medialive_not_support_flashlight, Toast.LENGTH_SHORT).show();
            return;
        }
        mIsTorchEnable = !mIsTorchEnable;
        int ret = mLivePusher.enableTorch(mIsTorchEnable);
        if (ret == 0) {
            mPushingTorch.setSelected(mIsTorchEnable);
            mPreviewTorch.setSelected(mIsTorchEnable);
        }
    }

    private void startPublish() {
        if (mIsLive) {
            return;
        }
        if (mCaptureMode == LiveCaptureType.SCREEN) {
            if (!mKeepLiveServiceConnectionIsConnected) {
                Toast.makeText(this, R.string.medialive_starting_foreground_service, Toast.LENGTH_SHORT).show();
                return;
            }
            if (!mIsCapturing) {
                mLivePusher.startVideoCapture(videoCaptureType);
                mLivePusher.startAudioCapture(audioCaptureType);
            } else {
                mLivePusher.switchAudioCapture(audioCaptureType);
                mLivePusher.switchVideoCapture(videoCaptureType);
            }
            mIsCapturing = true;
        }
        mIsLive = true;
        findViewById(R.id.group_preview).setVisibility(View.GONE);
        findViewById(R.id.group_pushing).setVisibility(View.VISIBLE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
                    || ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO}, 101);
                return;
            }
        }
        mLivePusher.startPush();
    }

    private void switchMic(View view) {
        if (mLivePusher.isMute()) {
            mLivePusher.setMute(false);
            view.setSelected(false);
        } else {
            mLivePusher.setMute(true);
            view.setSelected(true);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mKeepLiveServiceConnectionIsConnected) {
            unbindService(mKeepLiveServiceConnection);
        }
        if (mLiveSettingDialog != null) {
            mLiveSettingDialog.release();
        }
        if (mExternalCaptureSource != null) {
            mExternalCaptureSource.stop();
        }
        mLivePusher.release();
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_SCAN_SEI
                || requestCode == REQUEST_CODE_SCAN_URL) {
            IntentResult result = IntentIntegrator.parseActivityResult(resultCode, data);
            String content = result.getContents();
            if (content != null) {
                if (requestCode == REQUEST_CODE_SCAN_URL) {
                    if (mPreviewSettingsDialog != null) {
                        mPreviewSettingsDialog.setScanUrl(content);
                        mPreviewSettingsDialog.show();
                    }
                } else if (requestCode == REQUEST_CODE_SCAN_SEI) {
                    if (mLiveSettingDialog != null) {
                        mLiveSettingDialog.setScanSei(content);
                        mLiveSettingDialog.show();
                    }
                }
            }
            SystemClock.sleep(500);
            mLivePusher.startVideoCapture(videoCaptureType);
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mCaptureMode == LiveCaptureType.CAMERA && mIsLive && !mIsClosing) {
            mLivePusher.stopPush();
            stopCaptureMode();
            destroyPreview();
        }
        if (mCaptureMode != LiveCaptureType.SCREEN) {
            startKeepLive();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mCaptureMode != LiveCaptureType.SCREEN) {
            stopKeepLive();
        }
        if (mCaptureMode == LiveCaptureType.CAMERA && mIsLive && mLivePusher != null) {
            preparePreview();
            mLivePusher.startPush();
        }
    }

    @Override
    public void choosePic(ChoosePicListener listener) {
        mChoosePicListener = listener;
        Intent intent = new Intent(Intent.ACTION_PICK, null);
        intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
        imageLauncher.launch(intent);
    }

    final ActivityResultLauncher<Intent> imageLauncher = registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), new ActivityResultCallback<ActivityResult>() {
        @Override
        public void onActivityResult(ActivityResult result) {
            if (result.getResultCode() == Activity.RESULT_OK) {
                Intent intent = Objects.requireNonNull(result.getData());
                Uri uri = Objects.requireNonNull(intent.getData());
                try (InputStream in = getContentResolver().openInputStream(uri)) {
                    BitmapFactory.Options options = new BitmapFactory.Options();
                    options.inPreferredConfig = Bitmap.Config.RGB_565;
                    Bitmap bitmap = BitmapFactory.decodeStream(in, null, options);
                    if (mChoosePicListener != null) {
                        mChoosePicListener.onChoosePic(bitmap);
                    }
                } catch (IOException e) {
                    Log.d(TAG, "load image failed", e);
                }
            }
        }
    });

    private final ChoosePicListener mVoiceCaptureImageListener = new ChoosePicListener() {
        @Override
        public void onChoosePic(Bitmap bm) {
            mPushPic = bm;
            if (mPushPic != null) {
                mLivePusher.updateCustomImage(mPushPic);
                mLivePusher.switchVideoCapture(PUSH_VIDEO_CAPTURE_CUSTOM_IMAGE);
            }
        }
    };

    class ExternalCaptureSource {
        private int mPixelFmt = LivePusherSettingsHelper.getExternalVideoFrameFmtType();
        private int mBufferType = LivePusherSettingsHelper.getExternalVideoFrameBufferType();
        private MediaFileReader mAudioReader;
        private MediaFileReader mVideoReader;
        private TextureMgr mTextureMgr;
        private ByteBuffer mByteBuffer = ByteBuffer.allocateDirect(1920 * 1080 * 3 / 2); // 1080P 4:2:0 One Frame Size

        void updateVideoFrameType() {
            int fmt = LivePusherSettingsHelper.getExternalVideoFrameFmtType();
            int bufferType = LivePusherSettingsHelper.getExternalVideoFrameBufferType();
            if (mPixelFmt != fmt || mBufferType != bufferType) {
                mPixelFmt = fmt;
                mBufferType = bufferType;
                if (mVideoReader != null) {
                    mVideoReader.stop();
                    startVideoReader(mPixelFmt, mBufferType);
                }
            }
        }

        void start() {
            mAudioReader = new MediaFileReader();
            String audioFilePath = MediaResourceMgr.RawAudio.PCM_1.getLocalPath(LivePushActivity.this);
            mAudioReader.start(audioFilePath, 441 * 2 * 2, 10, new MediaFileReader.Callback() {
                @Override
                public void onByteBuffer(ByteBuffer byteBuffer, long pts) {
                    mLivePusher.pushExternalAudioFrame(new LivePusher.AudioFrame(0, 0, 0, pts, byteBuffer));
                }
            });
            startVideoReader(mPixelFmt, mBufferType);
        }

        void stop() {
            mAudioReader.stop();
            mVideoReader.stop();
        }

        private void startVideoReader(int pixelFmt, int bufferType) {
            mVideoReader = new MediaFileReader();
            String videoFilePath = MediaResourceMgr.RawVideo.NV21.getLocalPath(LivePushActivity.this);
            int width = MediaResourceMgr.RawVideo.NV21.width;
            int height = MediaResourceMgr.RawVideo.NV21.height;
            int frameSize = width * height * 3 / 2;
            int interval = 1000 / MediaResourceMgr.RawVideo.NV21.frameRate;
            startVideoReaderInner(videoFilePath, pixelFmt, bufferType, width, height, interval, frameSize);
        }

        private void startVideoReaderInner(String videoFilePath, int fmt, int bufferType, int width, int height, int interval, int frameSize) {
            if (fmt == LivePusher.VideoFrame.VIDEO_PIXEL_FMT_2D_TEXTURE) {
                if (mTextureMgr == null) {
                    mTextureMgr = new TextureMgr(width, height);
                }
                mVideoReader.start(videoFilePath, frameSize, interval, new MediaFileReader.Callback() {
                    @Override
                    public void onByteBuffer(ByteBuffer byteBuffer, long pts) {
                        mTextureMgr.dealWithTexture(byteBuffer, new TextureMgr.RenderListener() {
                            @Override
                            public void doBusiness(int texture) {
                                mLivePusher.pushExternalVideoFrame(new LivePusher.VideoFrame(fmt, LivePusher.VideoFrame.VIDEO_ROTATION_0, width, height, pts, texture));
                            }
                        });
                    }
                });
            } else {
                mVideoReader.start(videoFilePath, frameSize, interval, new MediaFileReader.Callback() {
                    @Override
                    public void onByteBuffer(ByteBuffer byteBuffer, long pts) {
                        mByteBuffer.position(0);
                        if (fmt == LivePusher.VideoFrame.VIDEO_PIXEL_FMT_I420) {
                            YuvHelper.NV21toI420(byteBuffer, mByteBuffer, width, height);
                        } else if (fmt == LivePusher.VideoFrame.VIDEO_PIXEL_FMT_NV12) {
                            YuvHelper.NV21toNV12(byteBuffer, mByteBuffer, width, height);
                        } else {
                            System.arraycopy(byteBuffer.array(), 0, mByteBuffer.array(), 0, byteBuffer.remaining());
                        }
                        if (bufferType == LivePusher.VideoFrame.VIDEO_BUFFER_TYPE_BYTE_ARRAY) {
                            byte[] arr = new byte[mByteBuffer.remaining()];
                            mByteBuffer.get(arr, 0, arr.length);
                            mLivePusher.pushExternalVideoFrame(new LivePusher.VideoFrame(fmt, LivePusher.VideoFrame.VIDEO_ROTATION_0, width, height, pts, arr));
                        } else if (bufferType == LivePusher.VideoFrame.VIDEO_BUFFER_TYPE_BYTE_BUFFER) {
                            mLivePusher.pushExternalVideoFrame(new LivePusher.VideoFrame(fmt, LivePusher.VideoFrame.VIDEO_ROTATION_0, width, height, pts, mByteBuffer));
                        } else {
                            // invalid bufferType
                        }
                    }
                });
            }
        }
    }

    private class CameraFocusRunnable implements Runnable {

        float x, y;

        final Context mContext;

        final int screenWidth;
        final int screenHeight;

        CameraFocusRunnable() {
            mContext = LivePushActivity.this;
            screenWidth = DensityUtils.getScreenWidth(LivePushActivity.this);
            screenHeight = DensityUtils.getScreenHeight(LivePushActivity.this);
        }

        void setPoint(float x, float y) {
            this.x = x;
            this.y = y;
        }

        @Override
        public void run() {
            final ImageView imageView = new ImageView(mContext);
            imageView.setImageResource(R.drawable.live_ic_focusing);
            imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
            int size = DensityUtils.dip2px(mContext, 65);
            ViewGroup.MarginLayoutParams params = new ViewGroup.MarginLayoutParams(size, size);
            params.leftMargin = (int) x - DensityUtils.dip2px(mContext, 60) / 2;
            params.topMargin = (int) y - DensityUtils.dip2px(mContext, 60) / 2;
            if (params.leftMargin > screenWidth - size) {
                params.leftMargin = screenWidth - size;
            } else if (params.leftMargin < 0) {
                params.leftMargin = 0;
            }
            if (params.topMargin > screenHeight - size) {
                params.topMargin = screenHeight - size;
            } else if (params.topMargin < 0) {
                params.topMargin = 0;
            }
            imageView.setLayoutParams(params);
            mViewContainer.addView(imageView);
            ValueAnimator scale = ValueAnimator.ofFloat(1, 1.1f, 0.95f);
            scale.addUpdateListener(animator -> {
                float value = (float) animator.getAnimatedValue();
                imageView.setScaleX(value);
                imageView.setScaleY(value);
            });
            scale.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    imageView.setVisibility(View.GONE);
                    if (mViewContainer != null) {
                        mViewContainer.removeView(imageView);
                    }
                }
            });
            scale.setInterpolator(new EaseBounceOutInterpolator());
            scale.setDuration(1500)
                    .start();
            mLivePusher.setFocusPosition(screenWidth, screenHeight, (int) x, (int) y);
        }
    }

    void updateLayoutByOrientation() {
        ConstraintLayout parent = findViewById(R.id.activity_root);
        boolean isLandscape = LivePusherSettingsHelper.isLandscape();
        ConstraintSet constraints = new ConstraintSet();
        constraints.clone(parent);
        if (isLandscape) {
            constraints.connect(R.id.pushing_actions, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP, 0);
            constraints.connect(R.id.pushing_actions, ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM, 0);
        } else {
            constraints.clear(R.id.pushing_actions, ConstraintSet.TOP);
            int marginBottom = getResources().getDimensionPixelSize(R.dimen.pushing_actions_bottom);
            constraints.connect(R.id.pushing_actions, ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM, marginBottom);
        }
        constraints.applyTo(parent);

        Resources resources = getResources();
        int panelWidth = resources.getDimensionPixelSize(R.dimen.pusher_info_panel_width);
        int panelHeight = resources.getDimensionPixelSize(R.dimen.pusher_info_panel_height);
        {
            View view = findViewById(R.id.medialive_cycle_info);
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) view.getLayoutParams();
            params.width = panelWidth;
            params.height = panelHeight;
        }
        {
            View view = findViewById(R.id.medialive_callback_info);
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) view.getLayoutParams();
            params.width = panelWidth;
            params.height = panelHeight;
        }
    }
}
