// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.eventbus

class RefreshUserNameEvent(
    @JvmField
    val userName: String,
    @JvmField
    val isSuccess: Boolean
)
