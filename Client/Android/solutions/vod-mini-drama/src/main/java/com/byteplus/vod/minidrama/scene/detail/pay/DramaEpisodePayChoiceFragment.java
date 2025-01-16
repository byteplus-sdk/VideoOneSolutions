// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.pay;

import android.app.Dialog;
import android.os.Bundle;
import android.view.View;
import android.view.Window;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.byteplus.minidrama.R;

public class DramaEpisodePayChoiceFragment extends DialogFragment {
    public static final String REQUEST_KEY = "request_key_pay_choice";
    public static final String EXTRA_CHOICE = "extra_choice";

    public static final int CHOICE_WATCH_AD = 1;
    public static final int CHOICE_UNLOCK_ALL = 2;

    public DramaEpisodePayChoiceFragment() {
        super(R.layout.vevod_mini_drama_episode_pay_choice_fragment);
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        final Dialog dialog = super.onCreateDialog(savedInstanceState);
        Window window = dialog.getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(android.R.color.transparent);
        }
        return dialog;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        view.findViewById(R.id.watch_ad).setOnClickListener(v -> {
            Bundle result = new Bundle();
            result.putInt(EXTRA_CHOICE, CHOICE_WATCH_AD);
            getParentFragmentManager().setFragmentResult(REQUEST_KEY, result);

            dismiss();
        });

        view.findViewById(R.id.unlock_all).setOnClickListener(v -> {
            Bundle result = new Bundle();
            result.putInt(EXTRA_CHOICE, CHOICE_UNLOCK_ALL);
            getParentFragmentManager().setFragmentResult(REQUEST_KEY, result);

            dismiss();
        });
    }
}
