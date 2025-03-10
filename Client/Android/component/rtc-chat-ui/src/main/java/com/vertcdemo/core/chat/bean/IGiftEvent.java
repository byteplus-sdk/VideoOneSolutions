// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.chat.bean;

import com.vertcdemo.core.chat.annotation.GiftType;

public interface IGiftEvent {
    @GiftType
    int getGiftType();

    String getUserId();

    String getUserName();

    int getCount();
}
