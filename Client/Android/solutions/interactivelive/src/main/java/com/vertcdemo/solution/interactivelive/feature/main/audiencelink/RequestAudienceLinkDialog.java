// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import android.Manifest;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.ui.BottomDialogFragmentX;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.core.annotation.InviteReply;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveRequestAudienceLinkBinding;
import com.vertcdemo.solution.interactivelive.event.InviteAudienceEvent;
import com.vertcdemo.solution.interactivelive.feature.main.AudienceViewModel;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.core.utils.DebounceClickListener;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Map;

public class RequestAudienceLinkDialog extends BottomDialogFragmentX {

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialogTheme;
    }

    private AudienceViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(requireParentFragment()).get(AudienceViewModel.class);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_request_audience_link, container, false);
    }

    DialogLiveRequestAudienceLinkBinding mBinding;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mBinding = DialogLiveRequestAudienceLinkBinding.bind(view);

        mBinding.application.setOnClickListener(DebounceClickListener.create(this::onCoHostApplicationClicked));
        mBinding.cancel.setOnClickListener(v -> {
            if (mViewModel.requestLinkStatus.getValue() == InviteReply.WAITING) {
                mViewModel.sendCancelAudienceLinkRequest();
            }
            dismiss();
        });

        mViewModel.requestLinkStatus.observe(getViewLifecycleOwner(), requestLinkStatus -> {
            boolean isRequesting = requestLinkStatus == InviteReply.WAITING;
            mBinding.groupWaiting.setVisibility(isRequesting ? View.VISIBLE : View.GONE);
            mBinding.groupApplication.setVisibility(isRequesting ? View.GONE : View.VISIBLE);
        });

        SolutionEventBus.register(this);
    }

    void onCoHostApplicationClicked(View view) {
        launcher.launch(new String[]{
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO,
        });
    }

    final ActivityResultLauncher<String[]> launcher = registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(), results -> {
        for (Map.Entry<String, Boolean> entry : results.entrySet()) {
            if (entry.getValue() != Boolean.TRUE) {
                CenteredToast.show(R.string.audience_link_need_permission);
                return;
            }
        }
        mViewModel.sendApplyAudienceLinkRequest();
    });

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInviteAudienceEvent(InviteAudienceEvent event) {
        String myUserId = SolutionDataManager.ins().getUserId();
        if (TextUtils.equals(event.userId, myUserId)) {
            if (event.reply != InviteReply.WAITING) {
                dismiss();
            }
        }
    }
}
