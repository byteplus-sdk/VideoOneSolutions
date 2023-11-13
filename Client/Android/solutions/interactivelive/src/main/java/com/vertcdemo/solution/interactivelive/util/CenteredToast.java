// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.util;

import android.app.Application;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.MainThread;
import androidx.annotation.StringRes;

import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.core.utils.AppUtil;

public class CenteredToast {
    @MainThread
    public static void show(String message) {
        final Application context = AppUtil.getApplicationContext();
        final TextView view = (TextView) LayoutInflater.from(context).inflate(R.layout.toast_centered, null);
        view.setText(message);
        final Toast toast = new Toast(context);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.setView(view);
        toast.show();
    }

    public static void show(@StringRes int message) {
        show(message, Toast.LENGTH_SHORT);
    }

    public static void show(@StringRes int message, int duration) {
        final Application context = AppUtil.getApplicationContext();
        final TextView view = (TextView) LayoutInflater.from(context).inflate(R.layout.toast_centered, null);
        view.setText(message);
        final Toast toast = new Toast(context);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.setView(view);
        toast.setDuration(duration);
        toast.show();
    }
}
