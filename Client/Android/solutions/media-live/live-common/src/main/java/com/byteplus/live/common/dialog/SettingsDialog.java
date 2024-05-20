// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;

import com.byteplus.live.common.DensityUtils;
import com.byteplus.live.common.R;

public abstract class SettingsDialog extends Dialog {
    protected LinearLayout mContainer;
    private int mHeight = DensityUtils.dip2px(this.getContext(), 300);
    private int mShorterBoard;

    public SettingsDialog(@NonNull Context context, int height) {
        super(context);
        mHeight = height;
    }

    public SettingsDialog(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        DisplayMetrics displayMetrics = Resources.getSystem().getDisplayMetrics();
        int widthPixels = displayMetrics.widthPixels;
        int heightPixels = displayMetrics.heightPixels;
        mShorterBoard = Math.min(widthPixels, heightPixels);
        if (mHeight > heightPixels) {
            mHeight = heightPixels - 50;
        }
        initWindow();
    }

    private void initWindow() {
        setContentView(getDialogLayout());
        mContainer = findViewById(R.id.container);
        Window window = getWindow();
        window.setDimAmount(0.6f);
        window.getAttributes().windowAnimations = R.style.DialogInAndOutStyle;
        int margin = 70; // dp
        int width = (mShorterBoard - DensityUtils.dip2px(this.getContext(), margin));
        window.setLayout(width, WindowManager.LayoutParams.WRAP_CONTENT);
        window.setLayout(width, mHeight);
        window.setGravity(Gravity.BOTTOM | Gravity.START);
        window.setBackgroundDrawableResource(android.R.color.transparent);
    }

    @LayoutRes
    protected int getDialogLayout() {
        return R.layout.live_dialog_base;
    }
}
