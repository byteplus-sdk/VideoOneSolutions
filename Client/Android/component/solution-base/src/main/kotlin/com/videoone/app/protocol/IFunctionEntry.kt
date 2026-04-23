// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import android.content.Context
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

interface IFunctionEntry {
    /**
     * Entry card title, Required
     */
    @get:StringRes
    val title: Int

    /**
     * Entry card background image, Required
     */
    @get:DrawableRes
    val icon: Int

    /**
     * Entry card description, Required
     */
    @get:StringRes
    val description: Int

    /**
     * Entry card entry, Required
     */
    fun startup(context: Context)
}
