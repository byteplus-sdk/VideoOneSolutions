/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */
package com.videoone.vod.function.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import com.bytedance.vod.settingskit.CenteredToast;
import com.bytedance.voddemo.impl.R;

public class PreventRecordingFragment extends VodFunctionFragment {

    private boolean mShowToast = true;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {

        FragmentActivity activity = requireActivity();
        activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);

        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mShowToast) {
            mShowToast = false;
            CenteredToast.show(requireContext(), R.string.vevod_function_prevent_recording_tips);
        }
    }
}
