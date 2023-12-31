// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.widget;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;

public class PressedImageView extends AppCompatImageView {
    public PressedImageView(Context context) {
        super(context);
    }

    public PressedImageView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public PressedImageView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public void setPressed(boolean pressed) {
        super.setPressed(pressed);
        if (pressed) {
            setAlpha(0.6f);
        } else {
            setAlpha(1f);
        }
    }
}
