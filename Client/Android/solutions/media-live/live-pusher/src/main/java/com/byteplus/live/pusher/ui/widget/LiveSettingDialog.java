// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher.ui.widget;


import static com.byteplus.live.pusher.ui.activities.LivePushActivity.REQUEST_CODE_SCAN_SEI;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_CAPTURE_MIRROR;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_PREVIEW_MIRROR;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_VIDEO_PUSH_MIRROR;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;

import com.byteplus.live.common.DensityUtils;
import com.byteplus.live.common.dialog.SettingsDialog;
import com.byteplus.live.pusher.LivePusher;
import com.byteplus.live.pusher.LivePusherSettingsHelper;
import com.byteplus.live.pusher.R;
import com.byteplus.live.pusher.ui.activities.LiveCaptureType;
import com.byteplus.live.pusher.ui.activities.LivePushActivity;
import com.byteplus.live.settings.PreferenceUtil;
import com.google.zxing.integration.android.IntentIntegrator;
import com.pandora.ttsdk.MonitorLog;

public class LiveSettingDialog extends SettingsDialog {

    private final Context mContext;

    private final LivePusher mLivePusherAPI;
    private EditText mSEIEditText;

    private final int mCaptureMode;

    public LiveSettingDialog(@NonNull Context context, @NonNull LivePusher livePusher, int captureMode) {
        super(context, DensityUtils.dip2px(context, 600));
        this.mContext = context;
        this.mCaptureMode = captureMode;
        this.mLivePusherAPI = livePusher;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initUI();
    }

    private void initRecordItem(View view) {
        SwitchCompat livingRecordSW = view.findViewById(R.id.record_start);
        boolean videoMode = mCaptureMode != LiveCaptureType.AUDIO;

        Spinner recordResolution = bindSpinner(
                view.findViewById(R.id.record_resolution),
                new String[]{"360P", "480P", "540P", "720P", "1080P"}
        );

        recordResolution.setVisibility(videoMode ? View.VISIBLE : View.GONE);

        Spinner recordFps = bindSpinner(
                view.findViewById(R.id.record_fps),
                new String[]{"15", "20", "25", "30"}
        );
        recordFps.setVisibility(videoMode ? View.VISIBLE : View.GONE);

        EditText recordBitrate = view.findViewById(R.id.record_bitrate);
        recordBitrate.setVisibility(videoMode ? View.VISIBLE : View.GONE);

        TextView recordTimeTV = view.findViewById(R.id.record_time);
        recordTimeTV.setVisibility(View.GONE);

        livingRecordSW.setOnCheckedChangeListener((button, isChecked) -> {
            if (isChecked) {
                recordResolution.setEnabled(false);
                recordFps.setEnabled(false);
                recordBitrate.setEnabled(false);
                mLivePusherAPI.setFileRecordingConfig(
                        recordResolution.getSelectedItemPosition(),
                        recordFps.getSelectedItemPosition(),
                        Integer.parseInt(recordBitrate.getText().toString()));
                mLivePusherAPI.startFileRecording(new LivePusher.FileRecordingListener() {
                    boolean isRecording;

                    @Override
                    public void onFileRecordingStarted() {
                        isRecording = true;
                        new Thread(() -> {
                            int curTime = 0;
                            while (isRecording) {
                                int finalCurTime = curTime;
                                ((LivePushActivity) mContext).runOnUiThread(() -> {
                                    recordTimeTV.setText(convertTime(finalCurTime));
                                });
                                SystemClock.sleep(1000L);
                                curTime++;
                            }
                        }).start();
                    }

                    @Override
                    public void onFileRecordingStopped() {
                        stopRecord();
                    }

                    @Override
                    public void onFileRecordingError(int errorCode, String message) {
                        stopRecord();
                        Toast.makeText(mContext, "errorCode:" + errorCode + ", " + message, Toast.LENGTH_SHORT).show();
                    }

                    private void stopRecord() {
                        isRecording = false;
                        if (!button.isChecked()) {
                            button.setChecked(false);
                        }
                    }
                });
            } else {
                recordResolution.setEnabled(true);
                recordFps.setEnabled(true);
                recordBitrate.setEnabled(true);
                mLivePusherAPI.stopFileRecording();
            }
            recordTimeTV.setVisibility(isChecked ? View.VISIBLE : View.INVISIBLE);
        });

        View groupScreenShot = view.findViewById(R.id.group_screen_shot);
        groupScreenShot.setVisibility(videoMode ? View.VISIBLE : View.GONE);
        if (videoMode) {
            view.findViewById(R.id.screen_snapshot).setOnClickListener(v -> snapshot());
        }
    }

    private void initVideoItem(View view) {
        Spinner resolution = bindSpinner(
                view.findViewById(R.id.resolution),
                new String[]{"360P", "480P", "540P", "720P", "1080P"}
        );
        resolution.setSelection(LivePusherSettingsHelper.getEncodeResolutionSettings());
        resolution.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                PreferenceUtil.getInstance().setPushVideoEncodeResolution(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });


        Spinner fps = bindSpinner(
                view.findViewById(R.id.frame_rate),
                new String[]{"15", "20", "25", "30"}
        );
        fps.setSelection(LivePusherSettingsHelper.getEncodeFpsSettings());
        fps.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                PreferenceUtil.getInstance().setPushVideoEncodeFps(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private void initMirrorItem(View view) {
        SwitchCompat captureMirror = view.findViewById(R.id.capture_mirror);
        captureMirror.setOnCheckedChangeListener((button, isChecked) -> {
            mLivePusherAPI.setVideoMirror(PUSH_VIDEO_CAPTURE_MIRROR, isChecked);
        });

        SwitchCompat previewMirror = view.findViewById(R.id.preview_mirror);
        previewMirror.setOnCheckedChangeListener((button, isChecked) -> {
            mLivePusherAPI.setVideoMirror(PUSH_VIDEO_PREVIEW_MIRROR, isChecked);
        });

        SwitchCompat streamMirror = view.findViewById(R.id.stream_mirror);
        streamMirror.setOnCheckedChangeListener((button, isChecked) -> {
            mLivePusherAPI.setVideoMirror(PUSH_VIDEO_PUSH_MIRROR, isChecked);
        });
    }

    private void initAudioSettingsItem(View view) {
        SeekBar audioLoudness = view.findViewById(R.id.audio_loudness);
        audioLoudness.setOnSeekBarChangeListener(new OnSeekBarChangeAdapter() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mLivePusherAPI.setVoiceLoudness(progress / 100.F);
            }
        });
        audioLoudness.setProgress((int) (mLivePusherAPI.getVoiceLoudness() * 100));

        SwitchCompat earphoneMonitor = view.findViewById(R.id.hardware_earphone_monitor);
        earphoneMonitor.setOnCheckedChangeListener((button, isChecked) -> {
            boolean success = mLivePusherAPI.enableEcho(isChecked);
            if (isChecked && !success) {
                // Earphone monitor not supported
                earphoneMonitor.setChecked(false);
            }
        });
    }

    private void initSeiItem(View view) {
        mSEIEditText = view.findViewById(R.id.input);
        view.findViewById(R.id.scan_url).setOnClickListener(v -> scanSEI());
        view.findViewById(R.id.send).setOnClickListener(this::sendSEI);
    }

    private void initUI() {
        View view = LayoutInflater.from(getContext()).inflate(R.layout.live_dialog_settings, mContainer);

        initRecordItem(view.findViewById(R.id.record_settings));

        initAudioSettingsItem(view.findViewById(R.id.audio_settings));

        if (mCaptureMode == LiveCaptureType.CAMERA) {
//            View videoRoot = view.findViewById(R.id.video_settings);
//            videoRoot.setVisibility(View.VISIBLE);
//            initVideoItem(videoRoot);

            View mirrorRoot = view.findViewById(R.id.mirror_settings);
            mirrorRoot.setVisibility(View.VISIBLE);
            initMirrorItem(mirrorRoot);
        }

        initSeiItem(view.findViewById(R.id.sei_settings));
    }

    public void release() {

    }

    private void scanSEI() {
        Handler handler = new Handler(Looper.getMainLooper());
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                MonitorLog.i("Scanning input url ...");
                IntentIntegrator integrator = new IntentIntegrator((Activity) mContext);
                integrator.setOrientationLocked(false);
                integrator.setRequestCode(REQUEST_CODE_SCAN_SEI);
                integrator.initiateScan();
                MonitorLog.i("Scanning input url done.");
            }
        }, 500);
        this.dismiss();
    }

    public void setScanSei(String content) {
        mSEIEditText.setText(content);
    }

    private void sendSEI(View v) {
        TextView button = (TextView) v;
        boolean isSending = v.getTag(R.id.tag_sei_sending) == Boolean.TRUE;
        if (isSending) {
            v.setTag(R.id.tag_sei_sending, false);
            button.setText(R.string.medialive_sei_send);
            // Stop sending
            mLivePusherAPI.sendSeiMessage("", 0);
        } else {
            v.setTag(R.id.tag_sei_sending, true);
            String content = mSEIEditText.getText().toString();
            if (!TextUtils.isEmpty(content)) {
                button.setText(R.string.medialive_sei_puase);
                mLivePusherAPI.sendSeiMessage(content, -1); // -1 always repeat
            }
        }
    }

    private void snapshot() {
        mLivePusherAPI.snapshot();
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
    }

    private static String convertTime(int time) {
        int minutes = time / 60;
        int seconds = time % 60;
        return (minutes < 10 ? "0" + minutes : String.valueOf(minutes))
                + ":"
                + (seconds < 10 ? ("0" + seconds) : String.valueOf(seconds));
    }

    private static Spinner bindSpinner(Spinner spinner, String[] spinnerItems) {
        ArrayAdapter<String> spinnerAdapter = new ArrayAdapter<>(spinner.getContext(), com.byteplus.live.common.R.layout.live_item_select2, spinnerItems);
        spinnerAdapter.setDropDownViewResource(com.byteplus.live.common.R.layout.live_item_drop);
        spinner.setAdapter(spinnerAdapter);
        return spinner;
    }

    static class OnSeekBarChangeAdapter implements SeekBar.OnSeekBarChangeListener {
        @Override
        public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {

        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {

        }
    }
}
