// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.annotation.SuppressLint;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;

import com.vertcdemo.solution.interactivelive.core.LiveSettingConfig;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveRoleType;
import com.vertcdemo.solution.interactivelive.core.live.StatisticsInfo;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveInformationBinding;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class LiveInfoDialog extends BottomSheetDialogFragment {
    private DialogLiveInformationBinding mBinding;
    private StatisticsInfo mStatisticsInfo;

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialog;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SolutionEventBus.register(this);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_information, container, false);
    }

    public static final int MSG_UPDATE_INFO = 1;
    public static final int INTERVAL_UPDATE_INFO = 2000;

    @SuppressLint("HandlerLeak")
    Handler mHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull Message msg) {
            if (MSG_UPDATE_INFO == msg.what) {
                removeMessages(MSG_UPDATE_INFO);
                if (mStatisticsInfo != null) {
                    final int transportRealFps = (int) mStatisticsInfo.getVideoTransportRealFps();
                    final int transportRealBitrate = (int) mStatisticsInfo.getVideoTransportRealBitrate();
                    final int videoEncodeRealFps = (int) mStatisticsInfo.getVideoEncodeRealFps();
                    final int videoEncodeRealBitrate = (int) mStatisticsInfo.getVideoEncodeRealBitrate();

                    mBinding.realtimeCaptureFps.setText(getString(R.string.format_fps, videoEncodeRealFps));
                    mBinding.realtimeTransmissionFps.setText(getString(R.string.format_fps, transportRealFps));

                    mBinding.realtimeEncodingBitrate.setText(getString(R.string.format_bitrate_kbps, videoEncodeRealBitrate));
                    mBinding.realtimeTransmissionBitrate.setText(getString(R.string.format_bitrate_kbps, transportRealBitrate));
                }

                sendEmptyMessageDelayed(MSG_UPDATE_INFO, INTERVAL_UPDATE_INFO);
            }
        }
    };

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mBinding = DialogLiveInformationBinding.bind(view);

        mBinding.tabBasicInfo.setOnClickListener(v -> selectTab(true));
        mBinding.tabRealtimeInfo.setOnClickListener(v -> selectTab(false));

        selectTab(true);
        renderBasicInfo();

        mHandler.sendEmptyMessage(MSG_UPDATE_INFO);
    }

    void renderBasicInfo() {
        final LiveRTCManager manager = LiveRTCManager.ins();
        LiveSettingConfig config = null;
        try {
            config = manager.getLiveConfigByRole(LiveRoleType.HOST);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (config == null) {
            return;
        }

        int minBitrate = 800;
        int maxBitrate = 1900;
        if (config.width == 1080) {
            minBitrate = 1000;
            maxBitrate = 3800;
        } else if (config.width == 540) {
            minBitrate = 500;
            maxBitrate = 1520;
        }

        mBinding.initialVideoBitrate.setText(getString(R.string.format_bitrate_kbps, config.bitRate));
        mBinding.maximumVideoBitrate.setText(getString(R.string.format_bitrate_kbps, maxBitrate));
        mBinding.minimumVideoBitrate.setText(getString(R.string.format_bitrate_kbps, minBitrate));

        mBinding.captureResolution.setText(getString(R.string.format_resolution, config.width, config.height));
        mBinding.pushVideoResolution.setText(getString(R.string.format_resolution, config.width, config.height));

        mBinding.captureFps.setText(getString(R.string.format_fps, config.frameRate));

        mBinding.encodingFormat.setText(R.string.video_encoder_name);
        mBinding.adaptiveBitrateMode.setText(R.string.adaptive_bitrate_mode_normal);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mHandler.removeMessages(MSG_UPDATE_INFO);
        SolutionEventBus.unregister(this);
    }

    void selectTab(boolean isBasic) {
        final Typeface bold = Typeface.defaultFromStyle(Typeface.BOLD);
        final Typeface normal = Typeface.defaultFromStyle(Typeface.NORMAL);

        mBinding.tabBasicInfo.setSelected(isBasic);
        mBinding.tabBasicInfo.setTypeface(isBasic ? bold : normal);
        mBinding.tabRealtimeInfo.setSelected(!isBasic);
        mBinding.tabRealtimeInfo.setTypeface(!isBasic ? bold : normal);

        mBinding.indicatorBasicInfo.setVisibility(isBasic ? View.VISIBLE : View.GONE);
        mBinding.indicatorRealtimeInfo.setVisibility(isBasic ? View.GONE : View.VISIBLE);

        mBinding.groupBasic.setVisibility(isBasic ? View.VISIBLE : View.GONE);
        mBinding.groupRealtime.setVisibility(isBasic ? View.GONE : View.VISIBLE);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onStatisticsInfoUpdate(StatisticsInfo info) {
        mStatisticsInfo = info;
    }
}
