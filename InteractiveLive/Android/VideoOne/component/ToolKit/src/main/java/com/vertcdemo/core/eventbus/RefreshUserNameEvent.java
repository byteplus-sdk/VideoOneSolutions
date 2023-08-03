// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.eventbus;

public class RefreshUserNameEvent {
    public boolean isSuccess;
    public String userName;
    public String errorMsg;

    public RefreshUserNameEvent(String userName, boolean isSuccess) {
        this.userName = userName;
        this.isSuccess = isSuccess;
    }
}
