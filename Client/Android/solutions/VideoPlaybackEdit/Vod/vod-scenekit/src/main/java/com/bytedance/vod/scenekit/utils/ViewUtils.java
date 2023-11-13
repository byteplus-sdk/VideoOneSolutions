// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.utils;

import android.view.View;
import android.view.ViewGroup;

public class ViewUtils {

    public static ViewGroup removeFromParent(View view) {
        ViewGroup parent = (ViewGroup) view.getParent();
        if (parent != null) {
            parent.removeView(view);
        }
        return parent;
    }
}
