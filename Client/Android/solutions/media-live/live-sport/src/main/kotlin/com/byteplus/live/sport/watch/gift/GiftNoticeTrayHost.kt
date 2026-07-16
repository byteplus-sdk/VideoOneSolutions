// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.gift

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.byteplus.live.sport.R
import com.google.android.material.imageview.ShapeableImageView
import java.util.ArrayDeque

/**
 * Single-slot host for portrait gift notices. One tray is shown at a time;
 * later notices queue up and play after the current one fades out.
 */
class GiftNoticeTrayHost @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    private val queue = ArrayDeque<GiftNoticeData>()

    private val avatarView: ShapeableImageView
    private val senderNameView: TextView
    private val giftDescView: TextView
    private val giftIconView: ImageView
    private val giftCountView: TextView

    private var isRunning = false

    private val fadeOutRunnable = Runnable { fadeOutCurrent() }

    init {
        clipChildren = false
        clipToPadding = false
        LayoutInflater.from(context).inflate(R.layout.live_sport_view_gift_notice, this, true)
        avatarView = findViewById(R.id.gift_notice_avatar)
        senderNameView = findViewById(R.id.gift_notice_sender)
        giftDescView = findViewById(R.id.gift_notice_desc)
        giftIconView = findViewById(R.id.gift_notice_icon)
        giftCountView = findViewById(R.id.gift_notice_count)
        visibility = View.INVISIBLE
        alpha = 0f
    }

    fun enqueue(data: GiftNoticeData) {
        queue.addLast(data)
        if (!isRunning) {
            showNext()
        }
    }

    fun clear() {
        removeCallbacks(fadeOutRunnable)
        animate().cancel()
        queue.clear()
        isRunning = false
        translationX = 0f
        alpha = 0f
        visibility = View.INVISIBLE
    }

    override fun onDetachedFromWindow() {
        clear()
        super.onDetachedFromWindow()
    }

    private fun showNext() {
        val next = if (queue.isEmpty()) null else queue.removeFirst()
        if (next == null) {
            isRunning = false
            visibility = View.INVISIBLE
            alpha = 0f
            return
        }
        isRunning = true
        bind(next)

        if (width == 0) {
            translationX = -resources.displayMetrics.widthPixels.toFloat()
            alpha = 1f
            visibility = View.VISIBLE
            post { startEnterAnim() }
        } else {
            startEnterAnim()
        }
    }

    private fun startEnterAnim() {
        removeCallbacks(fadeOutRunnable)
        animate().cancel()
        translationX = -width.toFloat()
        alpha = 1f
        visibility = View.VISIBLE
        animate()
            .translationX(0f)
            .setDuration(IN_ANIM_MS)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction { postDelayed(fadeOutRunnable, STAY_MS) }
            .start()
    }

    private fun fadeOutCurrent() {
        removeCallbacks(fadeOutRunnable)
        animate().cancel()
        animate()
            .alpha(0f)
            .setDuration(OUT_ANIM_MS)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                translationX = 0f
                visibility = View.INVISIBLE
                if (queue.isEmpty()) {
                    isRunning = false
                }
                showNext()
            }
            .start()
    }

    private fun bind(data: GiftNoticeData) {
        avatarView.setImageResource(data.avatarRes)
        senderNameView.text = data.senderName
        giftDescView.text = context.getString(R.string.live_sport_watch_gift_notice_sent, data.giftName)
        giftIconView.setImageResource(data.giftIconRes)
        giftCountView.text = data.count.toString()
    }

    private companion object {
        const val IN_ANIM_MS = 300L
        const val STAY_MS = 3_000L
        const val OUT_ANIM_MS = 300L
    }
}
