// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.settingskit;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

public class CenteredToast {
    @MainThread
    public static void show(@NonNull Context context, String message) {
        final TextView view = (TextView) LayoutInflater.from(context).inflate(R.layout.vevod_toast_centered, null);
        view.setText(message);
        final Toast toast = new Toast(context);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.setView(view);
        toast.show();
    }

    @MainThread
    public static void show(@NonNull Context context, @StringRes int message) {
        show(context, message, Toast.LENGTH_SHORT);
    }

    public static void show(@NonNull Context context, @StringRes int message, int duration) {
        final TextView view = (TextView) LayoutInflater.from(context).inflate(R.layout.vevod_toast_centered, null);
        view.setText(message);
        final Toast toast = new Toast(context);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.setView(view);
        toast.setDuration(duration);
        toast.show();
    }
}