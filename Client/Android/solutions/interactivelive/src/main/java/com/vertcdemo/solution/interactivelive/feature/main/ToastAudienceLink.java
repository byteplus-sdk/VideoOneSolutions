// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.widget.Toast;

import androidx.annotation.DrawableRes;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveToastAudienceLinkBinding;

public class ToastAudienceLink {
    @MainThread
    public static void show(@NonNull Context context,
                            @DrawableRes int icon,
                            @StringRes int title,
                            @StringRes int message) {
        final LayoutInflater layoutInflater = LayoutInflater.from(context);
        LayoutLiveToastAudienceLinkBinding binding = LayoutLiveToastAudienceLinkBinding.inflate(layoutInflater);

        binding.icon.setImageResource(icon);
        binding.title.setText(title);
        binding.message.setText(message);

        Toast toast = new Toast(context);
        toast.setView(binding.getRoot());
        toast.setDuration(Toast.LENGTH_LONG);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.show();
    }
}
