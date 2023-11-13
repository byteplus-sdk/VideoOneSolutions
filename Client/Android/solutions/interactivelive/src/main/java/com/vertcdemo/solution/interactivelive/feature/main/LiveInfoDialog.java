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

import com.ss.avframework.livestreamv2.LiveStreamReport;
import com.ss.avframework.livestreamv2.core.LiveCore;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.feature.bottomsheet.BottomDialogFragmentX;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.live.LiveConfigParams;
import com.vertcdemo.solution.interactivelive.core.live.LiveCoreHolder;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveInformationBinding;

public class LiveInfoDialog extends BottomDialogFragmentX {
    private DialogLiveInformationBinding mBinding;

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialogTheme;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_information, container, false);
    }

    public static final int MSG_UPDATE_INFO = 1;
    public static final int INTERVAL_UPDATE_INFO = 2000;

    LiveStreamReport mReport = new LiveStreamReport();

    @SuppressLint("HandlerLeak")
    Handler mHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull Message msg) {
            if (MSG_UPDATE_INFO == msg.what) {
                removeMessages(MSG_UPDATE_INFO);
                final LiveCore liveCore = LiveRTCManager.ins().getLiveCore();
                if (liveCore != null) {
                    liveCore.getLiveStreamInfo(mReport);

                    final int transportRealFps = (int) mReport.getVideoTransportRealFps();
                    final int transportRealBps = (int) mReport.getVideoTransportRealBps();
                    final int videoEncodeRealFps = (int) mReport.getVideoEncodeRealFps();
                    final int videoEncodeRealBps = (int) mReport.getVideoEncodeRealBps();

                    mBinding.realtimeCaptureFps.setText(getString(R.string.format_fps, videoEncodeRealFps));
                    mBinding.realtimeTransmissionFps.setText(getString(R.string.format_fps, transportRealFps));

                    mBinding.realtimeEncodingBitrate.setText(getString(R.string.format_bitrate_kbps, videoEncodeRealBps / 1000));
                    mBinding.realtimeTransmissionBitrate.setText(getString(R.string.format_bitrate_kbps, transportRealBps / 1000));
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
        final LiveConfigParams params = LiveCoreHolder.sLiveParams;
        mBinding.initialVideoBitrate.setText(getString(R.string.format_bitrate_kbps, params.defaultBitrate / 1000));
        mBinding.maximumVideoBitrate.setText(getString(R.string.format_bitrate_kbps, params.maxBitrate / 1000));
        mBinding.minimumVideoBitrate.setText(getString(R.string.format_bitrate_kbps, params.minBitrate / 1000));

        mBinding.captureResolution.setText(getString(R.string.format_resolution, params.width, params.height));
        mBinding.pushVideoResolution.setText(getString(R.string.format_resolution, params.width, params.height));

        mBinding.captureFps.setText(getString(R.string.format_fps, params.fps));
        mBinding.encodingFormat.setText(R.string.video_encoder_name);
        mBinding.adaptiveBitrateMode.setText(R.string.adaptive_bitrate_mode_normal);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mHandler.removeMessages(MSG_UPDATE_INFO);
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
}
