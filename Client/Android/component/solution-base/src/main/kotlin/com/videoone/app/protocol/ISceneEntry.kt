// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import android.content.Context
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.vertcdemo.base.R

interface ISceneEntry {
    /**
     * Entry card title, Required
     */
    @get:StringRes
    val title: Int

    @get:ColorRes
    val titleColor: Int
        get() = R.color.scene_title_text_color

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

    @get:ColorRes
    val descriptionColor: Int
        get() = R.color.scene_description_text_color

    @get:DrawableRes
    val iconNext: Int
        get() = R.drawable.ic_action_next

    val showGear: Boolean
        get() = false

    /**
     * Entry card entry, Required
     */
    fun startup(context: Context)

    fun startSettings(context: Context) {}
}
