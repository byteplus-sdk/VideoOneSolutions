// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.view;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;
import androidx.fragment.app.DialogFragment;

import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveCommonBinding;

public class LiveCommonDialog extends DialogFragment {

    public static final String EXTRA_REQUEST_KEY = "extra_request_key";
    public static final String EXTRA_RESULT = "extra_button";

    public static final String EXTRA_CANCELABLE = "extra_cancelable";
    public static final String EXTRA_TITLE = "extra_title";
    public static final String EXTRA_MESSAGE = "extra_message";
    public static final String EXTRA_MESSAGE_S = "extra_message_s";
    public static final String EXTRA_BUTTON_POSITIVE = "extra_button_positive";
    public static final String EXTRA_BUTTON_NEGATIVE = "extra_button_negative";

    @Override
    public int getTheme() {
        return R.style.LiveCommonDialogTheme;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_common, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {

        DialogLiveCommonBinding binding = DialogLiveCommonBinding.bind(view);

        final Bundle arguments = requireArguments();

        setCancelable(arguments.getBoolean(EXTRA_CANCELABLE, true));

        final String requestKey = arguments.getString(EXTRA_REQUEST_KEY);

        final int title = arguments.getInt(EXTRA_TITLE);
        if (title == ResourcesCompat.ID_NULL) {
            binding.title.setVisibility(View.GONE);
        } else {
            binding.title.setText(title);
        }

        final int message = arguments.getInt(EXTRA_MESSAGE, ResourcesCompat.ID_NULL);
        if (message == ResourcesCompat.ID_NULL) {
            String messageStr = arguments.getString(EXTRA_MESSAGE_S, null);
            if (messageStr == null) {
                binding.message.setVisibility(View.GONE);
            } else {
                binding.message.setText(messageStr);
            }
        } else {
            binding.message.setText(message);
        }

        final int button1 = arguments.getInt(EXTRA_BUTTON_POSITIVE);
        if (button1 == ResourcesCompat.ID_NULL) {
            binding.separatorV.setVisibility(View.GONE);
            binding.button1.setVisibility(View.GONE);
        } else {
            binding.button1.setText(button1);
            binding.button1.setOnClickListener(v -> { // Positive
                dismiss();
                Bundle result = new Bundle();
                result.putInt(EXTRA_RESULT, Dialog.BUTTON_POSITIVE);
                getParentFragmentManager().setFragmentResult(requestKey, result);
            });
        }

        final int button2 = arguments.getInt(EXTRA_BUTTON_NEGATIVE);
        if (button2 == ResourcesCompat.ID_NULL) {
            binding.separatorV.setVisibility(View.GONE);
            binding.button2.setVisibility(View.GONE);
        } else {
            binding.button2.setText(button2);
            binding.button2.setOnClickListener(v -> { // Negative
                dismiss();
                Bundle result = new Bundle();
                result.putInt(EXTRA_RESULT, Dialog.BUTTON_NEGATIVE);
                getParentFragmentManager().setFragmentResult(requestKey, result);
            });
        }

        if (button1 == ResourcesCompat.ID_NULL && button2 == ResourcesCompat.ID_NULL) {
            binding.separatorH.setVisibility(View.GONE);
        }
    }

    @Override
    public void onCancel(@NonNull DialogInterface dialog) {
        final Bundle arguments = requireArguments();
        final String requestKey = arguments.getString(EXTRA_REQUEST_KEY);

        Bundle result = new Bundle();
        result.putInt(EXTRA_RESULT, Dialog.BUTTON_NEGATIVE);
        getParentFragmentManager().setFragmentResult(requestKey, result);
    }
}
