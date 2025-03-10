// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.recommend

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.byteplus.vod.scenekit.ext.IComment
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogFragment
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogLFragment
import com.byteplus.vodlive.R
import com.vertcdemo.core.utils.fixNavigationBar

class RecommendActivity : AppCompatActivity(R.layout.activity_recommend) {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        fixNavigationBar()
        super.onCreate(savedInstanceState)

        LocalBroadcastManager.getInstance(this)
            .registerReceiver(commendDialogHandler, IntentFilter().apply {
                addAction(IComment.ACTION_SHOW_PORTRAIT)
                addAction(IComment.ACTION_SHOW_LANDSCAPE)
            })
    }

    override fun onDestroy() {
        LocalBroadcastManager.getInstance(this)
            .unregisterReceiver(commendDialogHandler)
        super.onDestroy()
    }

    private val commendDialogHandler = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val fragment = when (intent.action) {
                IComment.ACTION_SHOW_PORTRAIT -> CommentDialogFragment()
                IComment.ACTION_SHOW_LANDSCAPE -> CommentDialogLFragment()
                else -> return
            }
            fragment.setArguments(intent.extras!!)
            fragment.show(supportFragmentManager, "comment-dialog")
        }
    }
}