// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.audience;

import com.vertcdemo.solution.ktv.bean.UserInfo;

@FunctionalInterface
public interface OnOptionSelected {
    int ACTION_OK = 1;
    int ACTION_CANCEL = 2;

    void onOption(int option, UserInfo info);
}
