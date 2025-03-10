// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import android.content.Context
import android.content.Intent
import androidx.annotation.Keep
import com.byteplus.vodlive.R
import com.byteplus.vodlive.recommend.RecommendEntryActivity

@Keep
class VodLiveEntry : ISceneEntry {
    override val title: Int
        get() = R.string.vod_live_entry_title
    override val description: Int
        get() = R.string.vod_live_entry_desc
    override val background: Int
        get() = R.drawable.vod_live_bg_entry

    override fun startup(context: Context) {
        context.startActivity(Intent(context, RecommendEntryActivity::class.java))
    }
}