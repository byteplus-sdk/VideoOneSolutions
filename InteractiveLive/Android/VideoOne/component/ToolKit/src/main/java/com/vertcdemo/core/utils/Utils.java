// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.utils;

import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import androidx.annotation.Nullable;

public class Utils {

    public static void attachViewToViewGroup(@Nullable ViewGroup viewGroup,
                                             @Nullable View view,
                                             @Nullable ViewGroup.LayoutParams params) {
        if (view == null || viewGroup == null) {
            return;
        }
        ViewParent viewParent = view.getParent();
        if (viewParent == null) {
            viewGroup.addView(view, params);
        } else if (viewParent instanceof ViewGroup) {
            ViewGroup parentViewGroup = (ViewGroup) viewParent;
            if (parentViewGroup != viewGroup) {
                parentViewGroup.removeView(view);
                viewGroup.addView(view, params);
            }
        }
    }

    public static void attachViewToViewGroup(@Nullable ViewGroup viewGroup,
                                             @Nullable View view) {
        if (view == null || viewGroup == null) {
            return;
        }
        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        attachViewToViewGroup(viewGroup, view, params);
    }

    public static float dp2Px(float dipValue) {
        float scale = AppUtil.getApplicationContext().getResources().getDisplayMetrics().density;
        return dipValue * scale + 0.5F;
    }
}
