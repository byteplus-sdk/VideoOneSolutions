// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.core.ui.BottomDialogFragmentX;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveMoreActionBinding;

public class HostMoreActionDialog extends BottomDialogFragmentX {

    @Nullable
    private String mRoomId;

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialogTheme;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_more_action, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        final Bundle arguments = requireArguments();
        mRoomId = arguments.getString("roomId");
        DialogLiveMoreActionBinding binding = DialogLiveMoreActionBinding.bind(view);
        final LiveRTCManager manager = LiveRTCManager.ins();

        {
            boolean isCameraOn = manager.isCameraOn();
            binding.camera.setText(isCameraOn ? com.vertcdemo.core.R.string.camera : com.vertcdemo.core.R.string.camera_off);
            binding.camera.setSelected(isCameraOn);

            binding.flip.setEnabled(isCameraOn);

            boolean isMicrophoneOn = manager.isMicOn();
            binding.microphone.setText(isMicrophoneOn ? com.vertcdemo.core.R.string.microphone : com.vertcdemo.core.R.string.microphone_off);
            binding.microphone.setSelected(isMicrophoneOn);
        }

        binding.flip.setOnClickListener(v -> {
            v.setSelected(!v.isSelected());
            manager.switchCamera();
        });
        binding.microphone.setOnClickListener(DebounceClickListener.create(v -> {
            boolean isMicrophoneOn = manager.toggleMicrophone();
            binding.microphone.setText(isMicrophoneOn ? com.vertcdemo.core.R.string.microphone : com.vertcdemo.core.R.string.microphone_off);
            binding.microphone.setSelected(isMicrophoneOn);
            updateMediaStatus();
        }));
        binding.camera.setOnClickListener(DebounceClickListener.create(v -> {
            boolean isCameraOn = manager.toggleCamera();
            binding.flip.setEnabled(isCameraOn);
            binding.camera.setText(isCameraOn ? com.vertcdemo.core.R.string.camera : com.vertcdemo.core.R.string.camera_off);
            binding.camera.setSelected(isCameraOn);
            updateMediaStatus();
        }));

        binding.info.setVisibility(View.VISIBLE);
        binding.info.setOnClickListener(v -> {
            dismiss();
            LiveInfoDialog dialog = new LiveInfoDialog();
            dialog.show(getParentFragmentManager(), "live_info");
        });
    }

    void updateMediaStatus() {
        if (!TextUtils.isEmpty(mRoomId)) {
            final LiveRTCManager ins = LiveRTCManager.ins();
            int microphoneStatus = ins.isMicOn() ? MediaStatus.ON : MediaStatus.OFF;
            int cameraStatus = ins.isCameraOn() ? MediaStatus.ON : MediaStatus.OFF;
            LiveRTCManager.rts().updateMediaStatus(mRoomId, microphoneStatus, cameraStatus, null);
        }
    }
}
