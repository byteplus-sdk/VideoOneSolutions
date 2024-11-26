// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.cohost;


import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.http.callback.OnFailure;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveAnchorLinkConfirmFinishBinding;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.ui.CenteredToast;
import com.videoone.avatars.Avatars;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public final class AnchorLinkConfirmFinishDialog extends BottomSheetDialogFragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_anchor_link_confirm_finish, container, false);
    }

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialog;
    }

    private String mLinkId;
    private String mRoomId;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        DialogLiveAnchorLinkConfirmFinishBinding binding = DialogLiveAnchorLinkConfirmFinishBinding.bind(view);

        final Bundle arguments = requireArguments();

        mLinkId = arguments.getString("linkId");
        mRoomId = arguments.getString("rtsRoomId");
        LiveUserInfo host = (LiveUserInfo) arguments.getSerializable("host");
        LiveUserInfo coHost = (LiveUserInfo) arguments.getSerializable("coHost");

        Glide.with(binding.hostAvatar)
                .load(Avatars.byUserId(host.userId))
                .into(binding.hostAvatar);
        binding.hostName.setText(host.userName);

        binding.coHostName.setText(coHost.userName);
        Glide.with(binding.coHostAvatar)
                .load(Avatars.byUserId(coHost.userId))
                .into(binding.coHostAvatar);

        binding.ok.setOnClickListener(v -> {
            finishLink(mLinkId, mRoomId);
            dismiss();
        });
        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAnchorLinkFinishEvent(AnchorLinkFinishEvent event) {
        dismiss();
    }

    public static void finishLink(String linkId, String roomId) {
        LiveService.get()
                .finishAnchorLink(linkId, roomId, OnFailure.of(e -> {
                    if (e.getCode() == 560) { // record not found
                        // Status error, so we fake an AnchorLinkFinishEvent
                        SolutionEventBus.post(new AnchorLinkFinishEvent());
                    } else {
                        CenteredToast.show(ErrorTool.getErrorMessage(e));
                    }
                }));
    }
}
