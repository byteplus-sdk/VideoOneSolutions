// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.util;

import android.content.res.Resources;
import android.view.ViewGroup;

import androidx.annotation.FloatRange;
import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.Group;

public class ViewUtils {

    public static void setGroupAlpha(@NonNull Group group, @FloatRange(from = 0.0, to = 1.0) float alpha) {
        ViewGroup rootView = (ViewGroup) group.getParent();
        for (int id : group.getReferencedIds()) {
            rootView.findViewById(id).setAlpha(alpha);
        }
    }

    public static void setGroupEnable(@NonNull Group group, boolean enable) {
        ViewGroup rootView = (ViewGroup) group.getParent();
        for (int id : group.getReferencedIds()) {
            rootView.findViewById(id).setEnabled(enable);
            rootView.findViewById(id).setClickable(enable);
        }
    }

    public static int dp2px(float dpValue) {
        final float scale = Resources.getSystem().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }
}
