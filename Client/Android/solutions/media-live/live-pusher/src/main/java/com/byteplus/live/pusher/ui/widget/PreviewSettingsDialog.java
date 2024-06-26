// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher.ui.widget;

import static com.byteplus.live.pusher.ui.activities.LivePushActivity.REQUEST_CODE_SCAN_URL;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.appcompat.widget.SwitchCompat;

import com.byteplus.live.pusher.LivePusher;
import com.byteplus.live.pusher.LivePusherSettingsHelper;
import com.byteplus.live.pusher.R;
import com.byteplus.live.pusher.ui.activities.LiveCaptureType;
import com.byteplus.live.settings.PreferenceUtil;
import com.google.zxing.integration.android.IntentIntegrator;
import com.pandora.ttsdk.MonitorLog;

import java.util.Arrays;
import java.util.List;

public class PreviewSettingsDialog extends Dialog {
    private EditText mPushUrlEt;
    private Spinner mVideoCaptureResolution;
    private Spinner mVideoEncodeResolution;
    private Spinner mVideoCaptureFps;
    private Spinner mVideoEncodeFps;
    private Spinner mAudioEncodeSampleRate;
    private Spinner mVideoFrameFmtType;
    private Spinner mVideoFrameBufferType;

    private SwitchCompat mEnableAppAudio;

    private LivePusher.InfoListener mObserver;
    private boolean mIsNeedRebuild;
    private Context mContext;

    enum SettingsItem {
        VIDEO_CAPTURE_RESOLUTION,
        VIDEO_ENCODE_RESOLUTION,
        VIDEO_CAPTURE_FPS,
        VIDEO_ENCODE_FPS,
        AUDIO_ENCODE_SAMPLE_RATE,
        VIDEO_FRAME_TYPE,
        VIDEO_FRAME_BUFFER_TYPE,
        ENABLE_APP_AUDIO
    }

    private static final List<SettingsItem> CAMERA_SETTING_ITEMS = Arrays.asList(
            SettingsItem.VIDEO_CAPTURE_RESOLUTION,
            SettingsItem.VIDEO_ENCODE_RESOLUTION,
            SettingsItem.VIDEO_CAPTURE_FPS,
            SettingsItem.VIDEO_ENCODE_FPS,
            SettingsItem.AUDIO_ENCODE_SAMPLE_RATE
    );

    private static final List<SettingsItem> AUDIO_SETTING_ITEMS = Arrays.asList(
            SettingsItem.AUDIO_ENCODE_SAMPLE_RATE
    );

    private static final List<SettingsItem> SCREEN_SETTING_ITEMS = Arrays.asList(
            SettingsItem.VIDEO_ENCODE_RESOLUTION,
            SettingsItem.VIDEO_ENCODE_FPS,
            SettingsItem.AUDIO_ENCODE_SAMPLE_RATE,
            SettingsItem.ENABLE_APP_AUDIO
    );

    private static final List<SettingsItem> FILE_SETTING_ITEMS = Arrays.asList(
            SettingsItem.VIDEO_ENCODE_RESOLUTION,
            SettingsItem.VIDEO_ENCODE_FPS,
            SettingsItem.AUDIO_ENCODE_SAMPLE_RATE,
            SettingsItem.VIDEO_FRAME_TYPE,
            SettingsItem.VIDEO_FRAME_BUFFER_TYPE
    );

    private final List<SettingsItem> mSettingsPanelItem;
    private final LivePusher mLivePusher;

    public PreviewSettingsDialog(@NonNull Context context, LivePusher.InfoListener observer, int captureType, LivePusher livePusher) {
        super(context);
        mContext = context;
        mObserver = observer;
        if (captureType == LiveCaptureType.CAMERA) {
            mSettingsPanelItem = CAMERA_SETTING_ITEMS;
        } else if (captureType == LiveCaptureType.AUDIO) {
            mSettingsPanelItem = AUDIO_SETTING_ITEMS;
        } else if (captureType == LiveCaptureType.SCREEN) {
            mSettingsPanelItem = SCREEN_SETTING_ITEMS;
        } else if (captureType == LiveCaptureType.FILE) {
            mSettingsPanelItem = FILE_SETTING_ITEMS;
        } else {
            throw new IllegalStateException("Unknown Capture type: " + captureType);
        }
        mLivePusher = livePusher;
    }

    public void setScanUrl(String url) {
        if (mPushUrlEt != null) {
            mPushUrlEt.setText(url);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initWindow();
        assert mSettingsPanelItem != null;
        initPushUrlUI();

        initSettingsUI(mSettingsPanelItem);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        saveSettings();
        mObserver.updateSettings(mIsNeedRebuild);
        mIsNeedRebuild = false;
    }

    private void checkExternalVideoFrameType() {
        if (mVideoFrameFmtType == null || mVideoFrameBufferType == null) {
            return;
        }
        int fmt = LivePusherSettingsHelper.getExternalVideoFrameFmtType();
        int bufferType = LivePusherSettingsHelper.getExternalVideoFrameBufferType();
        int curFmt = mVideoFrameFmtType.getSelectedItemPosition();
        int curBufferType = mVideoFrameBufferType.getSelectedItemPosition();

        if (curBufferType == LivePusher.VideoFrame.VIDEO_BUFFER_TYPE_BYTE_BUFFER || curBufferType == LivePusher.VideoFrame.VIDEO_BUFFER_TYPE_BYTE_ARRAY) {
            if (curFmt == LivePusher.VideoFrame.VIDEO_PIXEL_FMT_I420) {
                fmt = curFmt;
                bufferType = curBufferType;
            }
        } else if (curBufferType == LivePusher.VideoFrame.VIDEO_BUFFER_TYPE_TEXTURE_ID) {
            if (curFmt == LivePusher.VideoFrame.VIDEO_PIXEL_FMT_2D_TEXTURE) {
                fmt = curFmt;
                bufferType = curBufferType;
            }
        }
        if (curFmt != fmt || curBufferType != bufferType) {
            Toast.makeText(mContext, R.string.medialive_video_frame_format_buffer_combination_invalid, Toast.LENGTH_SHORT).show();
            mVideoFrameFmtType.setSelection(fmt);
            mVideoFrameBufferType.setSelection(bufferType);
        }
        PreferenceUtil.getInstance().setPushExternalVideoFrameType(fmt);
        PreferenceUtil.getInstance().setPushExternalVideoFrameBufferType(bufferType);
    }

    private void saveSettings() {
        if (mPushUrlEt != null) {
            PreferenceUtil.getInstance().setPushUrl(mPushUrlEt.getText().toString());
        }
        if (mVideoCaptureResolution != null) {
            mIsNeedRebuild |= LivePusherSettingsHelper.getCaptureResolutionSettings() != mVideoCaptureResolution.getSelectedItemPosition();
            PreferenceUtil.getInstance().setPushVideoCaptureResolution(mVideoCaptureResolution.getSelectedItemPosition());
        }
        if (mVideoEncodeResolution != null) {
            PreferenceUtil.getInstance().setPushVideoEncodeResolution(mVideoEncodeResolution.getSelectedItemPosition());
        }
        if (mVideoCaptureFps != null) {
            mIsNeedRebuild |= LivePusherSettingsHelper.getCaptureFpsSettings() != mVideoCaptureFps.getSelectedItemPosition();
            PreferenceUtil.getInstance().setPushVideoCaptureFps(mVideoCaptureFps.getSelectedItemPosition());
        }
        if (mVideoEncodeFps != null) {
            PreferenceUtil.getInstance().setPushVideoEncodeFps(mVideoEncodeFps.getSelectedItemPosition());
        }
        if (mAudioEncodeSampleRate != null) {
            PreferenceUtil.getInstance().setPushAudioEncodeSampleRate(mAudioEncodeSampleRate.getSelectedItemPosition());
        }
        checkExternalVideoFrameType();
        if (mEnableAppAudio != null) {
            mIsNeedRebuild |= LivePusherSettingsHelper.getEnableAppAudio() != mEnableAppAudio.isChecked();
            PreferenceUtil.getInstance().setPushEnableAppAudio(mEnableAppAudio.isChecked());
        }
    }

    private void initWindow() {
        setContentView(R.layout.live_dialog_preview_settings);

        Window window = getWindow();
        window.setDimAmount(0.6f);
        window.getAttributes().windowAnimations = R.style.DialogInAndOutStyle;
        int device_width = Resources.getSystem().getDisplayMetrics().widthPixels;
        window.setLayout(device_width, WindowManager.LayoutParams.WRAP_CONTENT);
        window.setGravity(Gravity.BOTTOM);
        window.setBackgroundDrawableResource(android.R.color.transparent);
    }

    private void initPushUrlUI() {
        findViewById(R.id.scan_url)
                .setOnClickListener((View view) -> scanUrl());

        mPushUrlEt = findViewById(R.id.push_url_input);
        mPushUrlEt.setText(LivePusherSettingsHelper.getPushUrl());
    }

    private void initSettingsUI(List<SettingsItem> panelItems) {
        LinearLayout settings = findViewById(R.id.settings_panel);
        LayoutInflater inflater = LayoutInflater.from(getContext());
        for (SettingsItem panelItem : panelItems) {
            switch (panelItem) {
                case VIDEO_CAPTURE_RESOLUTION:
                    mVideoCaptureResolution = createSpinnerItem(
                            inflater,
                            settings,
                            R.string.medialive_setting_capture_resolution,
                            new String[]{"360P", "480P", "540P", "720P", "1080P"},
                            LivePusherSettingsHelper.getCaptureResolutionSettings()
                    );
                    break;
                case VIDEO_ENCODE_RESOLUTION:
                    mVideoEncodeResolution = createSpinnerItem(
                            inflater,
                            settings,
                            R.string.medialive_setting_encode_resolution,
                            new String[]{"360P", "480P", "540P", "720P", "1080P"},
                            LivePusherSettingsHelper.getEncodeResolutionSettings()
                    );
                    break;
                case VIDEO_CAPTURE_FPS:
                    mVideoCaptureFps = createSpinnerItem(
                            inflater,
                            settings,
                            R.string.medialive_setting_capture_fps,
                            new String[]{"15", "20", "25", "30"},
                            LivePusherSettingsHelper.getCaptureFpsSettings()
                    );
                    break;
                case VIDEO_ENCODE_FPS:
                    mVideoEncodeFps = createSpinnerItem(
                            inflater,
                            settings,
                            R.string.medialive_setting_encode_fps,
                            new String[]{"15", "20", "25", "30"},
                            LivePusherSettingsHelper.getEncodeFpsSettings()
                    );
                    break;
                case AUDIO_ENCODE_SAMPLE_RATE:
                    mAudioEncodeSampleRate = createSpinnerItem(
                            inflater,
                            settings,
                            R.string.medialive_setting_audio_sample_rate,
                            new String[]{"8k", "16k", "32k", "44.1k", "48k"},
                            LivePusherSettingsHelper.getAudioEncodeSampleRate()
                    );
                    break;
                case VIDEO_FRAME_TYPE:
                    mVideoFrameFmtType = createSpinnerItem(
                            inflater,
                            settings,
                            R.string.medialive_video_frame_format,
                            new String[]{"I420", "NV12", "NV21", "2DTexture"},
                            LivePusherSettingsHelper.getExternalVideoFrameFmtType()
                    );
                    break;
                case VIDEO_FRAME_BUFFER_TYPE:
                    mVideoFrameBufferType = createSpinnerItem(
                            inflater,
                            settings,
                            R.string.medialive_video_frame_buffer,
                            new String[]{"ByteBuffer", "ByteArray", "TextureID"},
                            LivePusherSettingsHelper.getExternalVideoFrameBufferType()
                    );
                    break;
                case ENABLE_APP_AUDIO:
                    mEnableAppAudio = createSwitchItem(inflater,
                            settings,
                            R.string.medialive_capture_app_audio,
                            LivePusherSettingsHelper.getEnableAppAudio()
                    );
                    break;
                default:
                    throw new IllegalStateException("Unhandled SettingsItem: " + panelItem);
            }
        }
    }

    private void scanUrl() {
        mLivePusher.stopVideoCapture();
        this.dismiss();

        Handler handler = new Handler(Looper.getMainLooper());
        handler.postDelayed(() -> {
            MonitorLog.i("Scanning input url ...");
            new IntentIntegrator((Activity) mContext)
                    .setOrientationLocked(false)
                    .setRequestCode(REQUEST_CODE_SCAN_URL)
                    .initiateScan();
            MonitorLog.i("Scanning input url done.");
        }, 500);
    }

    private Spinner createSpinnerItem(LayoutInflater inflater,
                                      LinearLayout parent,
                                      @StringRes int title,
                                      String[] items,
                                      int defaultPosition) {
        Context context = parent.getContext();
        View view = inflater.inflate(R.layout.live_setting_item_spinner, parent, false);
        TextView titleView = view.findViewById(R.id.title);
        titleView.setText(title);
        Spinner spinner = view.findViewById(R.id.spinner);

        ArrayAdapter<String> adapter = new ArrayAdapter<>(context, R.layout.live_item_select2, items);
        adapter.setDropDownViewResource(R.layout.live_item_drop);
        spinner.setAdapter(adapter);
        spinner.setSelection(defaultPosition);

        parent.addView(view);

        return spinner;
    }

    private SwitchCompat createSwitchItem(LayoutInflater inflater,
                                          LinearLayout parent,
                                          @StringRes int title,
                                          boolean value) {
        View view = inflater.inflate(R.layout.live_setting_item_switch, parent, false);
        SwitchCompat button = (SwitchCompat) view;
        button.setText(title);
        button.setChecked(value);

        parent.addView(view);
        return button;
    }
}
