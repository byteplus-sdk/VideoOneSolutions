// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common;

import android.app.Activity;
import android.content.Context;
import android.view.WindowManager;

public class DensityUtils {
    private DensityUtils() {
    }

    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }


    public static int px2dip(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    public static int getScreenWidth(Activity context){
        WindowManager wm = context.getWindowManager();
        return wm.getDefaultDisplay().getWidth();
    }

    public static int getScreenHeight(Activity context){
        WindowManager wm = context.getWindowManager();
        return wm.getDefaultDisplay().getHeight();
    }
}
