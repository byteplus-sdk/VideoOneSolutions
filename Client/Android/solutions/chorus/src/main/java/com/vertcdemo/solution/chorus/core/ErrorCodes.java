// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.core;

import com.bytedance.chrous.R;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.utils.ErrorTool;

public class ErrorCodes extends ErrorTool {
    public static String prettyMessage(HttpException e) {
        return prettyMessage(e.getCode(), e.getMessage());
    }

    public static String prettyMessage(int errorCode, String serverMessage) {
        if (errorCode == 540) {
            return ErrorTool.getString(R.string.toast_false_duplicate_song);
        } else {
            return ErrorTool.getErrorMessage(errorCode, serverMessage);
        }
    }
}
