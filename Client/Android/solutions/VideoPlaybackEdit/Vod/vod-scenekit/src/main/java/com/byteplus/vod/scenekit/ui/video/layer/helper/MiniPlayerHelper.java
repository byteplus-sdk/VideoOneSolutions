// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.layer.helper;

import android.app.AppOpsManager;
import android.content.Context;
import android.os.Build;
import android.os.Process;

import com.byteplus.vod.scenekit.VideoSettings;

public class MiniPlayerHelper {

    private boolean mEnterPictureInPictureModeMethodCalled = false;

    private static class Holder {
        private static final MiniPlayerHelper INS = new MiniPlayerHelper();
    }

    private MiniPlayerHelper() {
    }

    public static MiniPlayerHelper get() {
        return Holder.INS;
    }

    public void exitPictureInPictureMode() {
        mEnterPictureInPictureModeMethodCalled = false;
    }

    public void enterPictureInPictureMode(){
        mEnterPictureInPictureModeMethodCalled = true;
    }

    public boolean isMiniPlayerOff() {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.O
                || !mEnterPictureInPictureModeMethodCalled
                || !VideoSettings.booleanValue(VideoSettings.COMMON_IS_MINIPLAYER_ON);
    }

    public boolean isMiniPlayerOn() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                && VideoSettings.booleanValue(VideoSettings.COMMON_IS_MINIPLAYER_ON);
    }

    public boolean hasMiniPlayerPermission(Context context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false;
        }

        AppOpsManager opsManager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
        if (opsManager == null) {
            return false;
        }

        int mode;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            mode = opsManager.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_PICTURE_IN_PICTURE,
                    Process.myUid(), context.getPackageName());
        } else {
            mode = opsManager.checkOpNoThrow(AppOpsManager.OPSTR_PICTURE_IN_PICTURE,
                    Process.myUid(), context.getPackageName());
        }
        return mode == AppOpsManager.MODE_ALLOWED;
    }

}
