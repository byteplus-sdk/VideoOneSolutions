// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.chat.input;

import android.content.DialogInterface;
import android.os.Bundle;
import android.os.SystemClock;
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

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.rtc.chat.R;
import com.vertcdemo.rtc.chat.databinding.DialogMessageInputBinding;

public class MessageInputDialog extends BottomSheetDialogFragment {
    public static final String REQUEST_KEY_MESSAGE_INPUT = "request-key-message-input";

    public static final String EXTRA_CONTENT = "extra_content";
    public static final String EXTRA_ACTION_DONE = "extra_action_done";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        final Window window = requireDialog().getWindow();
        if (window != null) {
            window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        }
        return inflater.inflate(R.layout.dialog_message_input, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        DialogMessageInputBinding binding = DialogMessageInputBinding.bind(view);

        binding.input.requestFocus();
        binding.input.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEND) {
                String content = binding.input.getText().toString().trim();
                setFragmentResult(content, true);
                dismiss();
            }
            return true;
        });

        final Bundle arguments = getArguments();
        if (arguments != null) {
            String content = arguments.getString(EXTRA_CONTENT, "");
            binding.input.setText(content);
            binding.input.setSelection(content.length());
        }

        view.getViewTreeObserver().addOnGlobalLayoutListener(mLayoutListener);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        requireView().getViewTreeObserver().removeOnGlobalLayoutListener(mLayoutListener);
    }

    @Override
    public void onCancel(@NonNull DialogInterface dialog) {
        final View view = getView();
        if (view == null) {
            return;
        }
        EditText editText = view.findViewById(R.id.input);
        String content = editText.getText().toString().trim();
        setFragmentResult(content, false);
    }

    void setFragmentResult(String content, boolean action) {
        Bundle result = new Bundle();
        result.putString(EXTRA_CONTENT, content);
        result.putBoolean(EXTRA_ACTION_DONE, action);
        getParentFragmentManager()
                .setFragmentResult(REQUEST_KEY_MESSAGE_INPUT, result);
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
            EditText editText = view.findViewById(R.id.input);
            String content = editText.getText().toString().trim();
            setFragmentResult(content, false);
            dismiss();
        }
    };
}
