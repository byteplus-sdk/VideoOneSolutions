// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import androidx.annotation.StringRes
import androidx.fragment.app.Fragment

interface IFunctionTabEntry {
    /**
     * Entry title, Required
     */
    @get:StringRes
    val title: Int

    /**
     * Entry page, Required
     */
    fun fragment(): Fragment
}
