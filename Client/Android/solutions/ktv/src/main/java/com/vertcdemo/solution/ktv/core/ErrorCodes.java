// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.core;

import androidx.annotation.StringRes;

import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.ktv.R;

public class ErrorCodes {
    public static String prettyMessage(int errorCode, String serverMessage) {
        if (errorCode == 540) {
            return getString(R.string.toast_false_duplicate_song);
        } else {
            return ErrorTool.getErrorMessageByErrorCode(errorCode, serverMessage);
        }
    }

    private static String getString(@StringRes int res) {
        return AppUtil.getApplicationContext().getString(res);
    }
}
