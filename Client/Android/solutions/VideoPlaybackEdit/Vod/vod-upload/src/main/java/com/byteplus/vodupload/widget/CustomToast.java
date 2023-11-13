// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.DrawableRes;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import com.byteplus.vodupload.R;

public class CustomToast {

    @MainThread
    public static void show(@NonNull Context context,
                            @DrawableRes int icon,
                            @StringRes int message) {
        final LayoutInflater layoutInflater = LayoutInflater.from(context);
        View root = layoutInflater.inflate(R.layout.toast_custom, null);
        ImageView iv = root.findViewById(R.id.icon);
        iv.setImageResource(icon);
        TextView tv = root.findViewById(R.id.toast_text);
        tv.setText(message);

        Toast toast = new Toast(context);
        toast.setView(root);
        toast.setDuration(Toast.LENGTH_LONG);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.show();
    }
}
