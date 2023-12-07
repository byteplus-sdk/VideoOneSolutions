// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer.dialog;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.utils.InputMethodUtils;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

public class InputDialog extends BottomSheetDialogFragment {

    public interface ISendCallback {
        void send(String content);
    }

    private ISendCallback mSendCallback;

    public void setSendCallback(ISendCallback callback) {
        mSendCallback = callback;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        setSoftInputMode();
        return inflater.inflate(R.layout.vevod_dialog_input, container, false);
    }

    private void setSoftInputMode() {
        final Dialog dialog = getDialog();
        if (dialog == null) {
            return;
        }
        dialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        InputMethodUtils.showInputMethod(getContext());
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        EditText input = view.findViewById(R.id.input);
        input.requestFocus();
        input.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEND) {
                String content = input.getText().toString().trim();
                if (!TextUtils.isEmpty(content)) {
                    if (mSendCallback != null) {
                        mSendCallback.send(content);
                    }
                }
                InputMethodUtils.hideInputMethod(getContext(), getView());
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
