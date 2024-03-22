// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.utils;

import android.content.Context;

import com.vertcdemo.core.utils.AppUtil;

public class ContextProvider {
    public static Context get() {
        return AppUtil.getApplicationContext();
    }
}
