// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.view;

import android.app.Dialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveSendMessageInputBinding;

public class LiveSendMessageInputDialog extends BottomSheetDialogFragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        setSoftInputMode();
        return inflater.inflate(R.layout.dialog_live_send_message_input, container, false);
    }

    private void setSoftInputMode() {
        final Dialog dialog = getDialog();
        if (dialog == null) {
            return;
        }
        dialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        final Bundle arguments = requireArguments();
        final String roomId = arguments.getString("rtsRoomId");
        DialogLiveSendMessageInputBinding binding = DialogLiveSendMessageInputBinding.bind(view);

        binding.input.requestFocus();
        binding.input.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEND) {
                String content = binding.input.getText().toString().trim();
                if (!TextUtils.isEmpty(content)) {
                    MessageBody body = MessageBody.createMessage(content);
                    LiveRTCManager.ins().getRTSClient().sendMessage(roomId, body);
                }

                dismiss();
            }
            return true;
        });

        view.getViewTreeObserver().addOnGlobalLayoutListener(mLayoutListener);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        requireView().getViewTreeObserver().removeOnGlobalLayoutListener(mLayoutListener);
    }

    /**
     * Used to Observer IME status
     */
    private final ViewTreeObserver.OnGlobalLayoutListener mLayoutListener = new ViewTreeObserver.OnGlobalLayoutListener() {
        private boolean imeVisible = false;

        @Override
        public void onGlobalLayout() {
            final View view = getView();
            if (view == null) {
                return;
            }
            WindowInsetsCompat windowInsets = ViewCompat.getRootWindowInsets(view);
            if (windowInsets == null) {
                return;
            }
            final boolean newValue = windowInsets.isVisible(WindowInsetsCompat.Type.ime());
            if (imeVisible && !newValue) {
                dismiss();
            }
            imeVisible = newValue;
        }
    };
}
