// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.settingskit;

import android.content.Context;

public class Utils {
    public static float dip2Px(Context context, float dipValue) {
        if (context != null) {
            final float scale = context.getResources().getDisplayMetrics().density;
            return dipValue * scale + 0.5f;
        }
        return 0;
    }
}
