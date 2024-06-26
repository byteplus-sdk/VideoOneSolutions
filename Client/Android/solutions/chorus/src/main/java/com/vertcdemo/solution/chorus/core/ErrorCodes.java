// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.core;

import com.bytedance.chrous.R;
import com.vertcdemo.core.net.ErrorTool;

public class ErrorCodes extends ErrorTool{
    public static String prettyMessage(int errorCode, String serverMessage) {
        if (errorCode == 540) {
            return ErrorTool.getString(R.string.toast_false_duplicate_song);
        } else {
            return ErrorTool.getErrorMessageByErrorCode(errorCode, serverMessage);
        }
    }
}
