// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.cohost;


import android.annotation.SuppressLint;
import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.bumptech.glide.Glide;
import com.videoone.avatars.Avatars;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.databinding.DialogAnchorLinkConfirmInviteBinding;

public final class AnchorLinkConfirmInviteDialog extends DialogFragment {
    public static final int TIMEOUT = 10_000;

    public static final String REQUEST_KEY = "anchor_link_invite_result";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        final Dialog dialog = getDialog();
        if (dialog != null) {
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }
        return inflater.inflate(R.layout.dialog_anchor_link_confirm_invite, container, false);
    }

    private static final int MSG_TIMEOUT = 1;

    @SuppressLint("HandlerLeak")
    Handler mHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull Message msg) {
            if (msg.what == MSG_TIMEOUT) {
                setResult(false);
                dismiss();
            }
        }
    };

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        setCancelable(false);

        DialogAnchorLinkConfirmInviteBinding binding = DialogAnchorLinkConfirmInviteBinding.bind(view);

        final Bundle arguments = requireArguments();
        final LiveUserInfo userInfo = (LiveUserInfo) arguments.getSerializable("userInfo");
        assert userInfo != null;
        String userId = userInfo.userId;

        Glide.with(binding.userAvatar)
                .load(Avatars.byUserId(userId))
                .circleCrop()
                .into(binding.userAvatar);

        binding.userName.setText(getString(R.string.anchor_link_from, userInfo.userName));

        binding.cancel.setOnClickListener(v -> {
            mHandler.removeMessages(MSG_TIMEOUT);
            setResult(false);
            dismiss();
        });

        binding.ok.setOnClickListener(v -> {
            mHandler.removeMessages(MSG_TIMEOUT);
            setResult(true);
            dismiss();
        });

        mHandler.sendEmptyMessageDelayed(MSG_TIMEOUT, TIMEOUT);
    }

    void setResult(boolean isAccept) {
        final Bundle arguments = requireArguments();
        arguments.putBoolean("accept", isAccept);
        getParentFragmentManager().setFragmentResult(REQUEST_KEY, arguments);
    }
}
