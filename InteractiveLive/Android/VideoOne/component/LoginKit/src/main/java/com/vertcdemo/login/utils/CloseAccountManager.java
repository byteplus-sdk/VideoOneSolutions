// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.login.utils;

import androidx.annotation.Keep;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.common.IAction;


@SuppressWarnings("unused")
@Keep
public class CloseAccountManager {

    public static void delete(IAction<Boolean> action) {
        SolutionDataManager.ins().logout();
        if (action != null) {
            action.act(true);
        }
    }
}
