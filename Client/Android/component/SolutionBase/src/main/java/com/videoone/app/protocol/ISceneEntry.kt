// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import android.content.Context
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

interface ISceneEntry {
    /**
     * Entry card title, Required
     */
    @get:StringRes
    val title: Int

    /**
     * Entry card background image, Required
     */
    @get:DrawableRes
    val background: Int

    /**
     * Entry card description, Required
     */
    @get:StringRes
    val description: Int

    val showGear: Boolean
        get() = false

    /**
     * Entry card entry, Required
     */
    fun startup(context: Context)

    fun startSettings(context: Context) {}
}
