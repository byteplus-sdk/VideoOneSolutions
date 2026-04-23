// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol

import android.content.Context
import android.content.Intent
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.Keep
import androidx.annotation.StringRes
import com.byteplus.aichat.R

@Keep
class AiChatEntry : ISceneEntry {
    @StringRes
    override val title: Int = R.string.ai_chat_entry_title

    @get:ColorRes
    override val titleColor: Int
        get() = com.vertcdemo.base.R.color.scene_title_text_color_dark

    @DrawableRes
    override val background: Int = R.drawable.ai_chat_entry_bg

    @StringRes
    override val description: Int = R.string.ai_chat_entry_description

    @get:ColorRes
    override val descriptionColor: Int
        get() = com.vertcdemo.base.R.color.scene_description_text_color_dark

    @get:DrawableRes
    override val iconNext: Int
        get() = com.vertcdemo.base.R.drawable.ic_action_next_blue

    override fun startup(context: Context) {
        context.startActivity(Intent(context, AiChatEntryActivity::class.java))
    }
}
