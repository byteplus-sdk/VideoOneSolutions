// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer.dialog;

import android.os.Bundle;
import android.os.SystemClock;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.byteplus.vod.scenekit.R;
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
        Window window = requireDialog().getWindow();
        if (window != null) {
            window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        }
        return inflater.inflate(R.layout.vevod_dialog_input, container, false);
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
        // Disable first 300ms to avoid the case that the keyboard is animating popping up.
        private final static long KEYBOARD_HIDE_DELAY = 300;

        private boolean imeVisible = false;
        private long mShowTime = 0;

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
                long interval = SystemClock.uptimeMillis() - mShowTime;
                if (interval > KEYBOARD_HIDE_DELAY) {
                    onKeyboardHidden(view);
                }
            }
            if (!imeVisible && newValue) {
                mShowTime = SystemClock.uptimeMillis();
            }
            imeVisible = newValue;
        }

        private void onKeyboardHidden(View view) {
            dismiss();
        }
    };
}
