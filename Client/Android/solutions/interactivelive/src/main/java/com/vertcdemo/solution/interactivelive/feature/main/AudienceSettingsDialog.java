// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_NEGATIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_POSITIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_MESSAGE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_REQUEST_KEY;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_RESULT;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_TITLE;

import android.content.DialogInterface;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentResultListener;
import androidx.lifecycle.ViewModelProvider;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.feature.bottomsheet.BottomDialogFragmentX;
import com.vertcdemo.solution.interactivelive.bean.LiveResponse;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.databinding.DialogAudienceSettingsBinding;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkStatusEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;
import com.vertcdemo.solution.interactivelive.util.CenteredToast;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class AudienceSettingsDialog extends BottomDialogFragmentX {

    private static final String REQUEST_KEY = "request_key_confirm_finish_interact";

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialogTheme;
    }

    AudienceViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(requireParentFragment()).get(AudienceViewModel.class);
        getChildFragmentManager().setFragmentResultListener(REQUEST_KEY, this, mConfirmFinishInteractCallback);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_audience_settings, container, false);
    }

    DialogAudienceSettingsBinding mBinding;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mBinding = DialogAudienceSettingsBinding.bind(view);
        mBinding.flip.setOnClickListener(v -> LiveRTCManager.ins().switchCamera());

        mBinding.microphone.setOnClickListener(v -> {
            LiveRTCManager.ins().toggleMicrophone();
            notifyMediaStatus(mViewModel.getRTSRoomId());
        });

        mBinding.camera.setOnClickListener(v -> {
            LiveRTCManager.ins().toggleCamera();
            notifyMediaStatus(mViewModel.getRTSRoomId());
        });

        mBinding.hangup.setOnClickListener(v -> showConfirmFinishInteractDialog());

        mBinding.cancel.setOnClickListener(v -> dismiss());

        updateLocalViewStatus();
        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    void updateLocalViewStatus() {
        final LiveRTCManager rtcManager = LiveRTCManager.ins();
        mBinding.microphone.setSelected(rtcManager.isMicOn());
        mBinding.microphoneText.setText(rtcManager.isMicOn() ? com.vertcdemo.core.R.string.microphone : com.vertcdemo.core.R.string.microphone_off);
        mBinding.camera.setSelected(rtcManager.isCameraOn());
        mBinding.cameraText.setText(rtcManager.isCameraOn() ? com.vertcdemo.core.R.string.camera : com.vertcdemo.core.R.string.camera_off);

        mBinding.flip.setEnabled(rtcManager.isCameraOn());
    }

    void notifyMediaStatus(String roomId) {
        final LiveRTCManager rtcManager = LiveRTCManager.ins();
        int micStatus = rtcManager.isMicOn() ? MediaStatus.ON : MediaStatus.OFF;
        int cameraStatus = rtcManager.isCameraOn() ? MediaStatus.ON : MediaStatus.OFF;
        LiveRTCManager.rts().updateMediaStatus(roomId, micStatus, cameraStatus, null);
    }

    void showConfirmFinishInteractDialog() {
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        final Bundle args = new Bundle();
        args.putString(EXTRA_REQUEST_KEY, REQUEST_KEY);
        args.putInt(EXTRA_TITLE, R.string.audience_finish_interact_title);
        args.putInt(EXTRA_MESSAGE, R.string.audience_finish_interact_message);
        args.putInt(EXTRA_BUTTON_POSITIVE, R.string.confirm);
        args.putInt(EXTRA_BUTTON_NEGATIVE, R.string.cancel);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "confirm_finish_interact_dialog");
    }

    final FragmentResultListener mConfirmFinishInteractCallback = new FragmentResultListener() {
        @Override
        public void onFragmentResult(@NonNull String requestKey, @NonNull Bundle result) {
            int button = result.getInt(EXTRA_RESULT);
            if (button == DialogInterface.BUTTON_POSITIVE) {
                LiveRTCManager.rts().finishAudienceLinkByAudience(
                        mViewModel.getLinkerId(),
                        mViewModel.getRTSRoomId(),
                        sFinishInteractResponse);
                dismiss();
            }
        }
    };

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaChangedEvent(UserMediaChangedEvent event) {
        final String myUserId = SolutionDataManager.ins().getUserId();
        if (TextUtils.equals(myUserId, event.userId)) {
            updateLocalViewStatus();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkFinishEvent(AudienceLinkFinishEvent event) {
        dismiss();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkStatusEvent(AudienceLinkStatusEvent event) {
        if (event.userId.equals(SolutionDataManager.ins().getUserId())) {
            dismiss();
        }
    }
    // finish interact callback
    private static final IRequestCallback<LiveResponse> sFinishInteractResponse = new IRequestCallback<LiveResponse>() {
        @Override
        public void onSuccess(LiveResponse data) {

        }

        @Override
        public void onError(int errorCode, String message) {
            CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
        }
    };
}
