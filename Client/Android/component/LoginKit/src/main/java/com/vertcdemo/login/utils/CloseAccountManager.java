// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.login.utils;

import androidx.annotation.Keep;
import androidx.core.util.Consumer;

import com.vertcdemo.core.SolutionDataManager;


@SuppressWarnings("unused")
@Keep
public class CloseAccountManager {

    public static void delete(Consumer<Boolean> action) {
        SolutionDataManager.ins().logout();
        if (action != null) {
            action.accept(true);
        }
    }
}
