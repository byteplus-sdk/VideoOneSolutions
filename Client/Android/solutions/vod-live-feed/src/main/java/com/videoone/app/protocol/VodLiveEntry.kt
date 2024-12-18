package com.videoone.app.protocol

import android.content.Context
import android.content.Intent
import com.byteplus.vodlive.R
import com.byteplus.vodlive.recommend.RecommendEntryActivity

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