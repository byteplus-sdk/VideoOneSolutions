// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.player

import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import androidx.core.view.updateLayoutParams


class DisplayMode(mode: Int = DISPLAY_MODE_ASPECT_FIT) {
    private var mVideoWidth = 0
    private var mVideoHeight = 0
    private var mDisplayAspectRatio = 0f
    private var mDisplayMode = mode

    private var mContainerView: FrameLayout? = null
    private var mDisplayView: View? = null

    fun setVideoSize(videoWidth: Int, videoHeight: Int) {
        this.mVideoWidth = videoWidth
        this.mVideoHeight = videoHeight
        apply()
    }

    fun setDisplayAspectRatio(dar: Float) {
        this.mDisplayAspectRatio = dar
        apply()
    }

    var displayMode: Int
        get() = this.mDisplayMode
        set(displayMode) {
            this.mDisplayMode = displayMode
            apply()
        }

    fun setContainerView(containerView: FrameLayout?) {
        this.mContainerView = containerView
        apply()
    }

    fun setDisplayView(displayView: View?) {
        this.mDisplayView = displayView
        apply()
    }

    fun updateView(containerView: FrameLayout?, displayView: View?) {
        this.mContainerView = containerView
        this.mDisplayView = displayView
        apply()
    }

    fun getDisplayView(): View? {
        return mDisplayView
    }

    fun apply() {
        val displayView = this.mDisplayView ?: return
        displayView.removeCallbacks(applyDisplayMode)
        displayView.post(applyDisplayMode)
    }

    private val applyDisplayMode = Runnable { applyDisplayMode() }

    private fun applyDisplayMode() {
        val containerView = this.mContainerView ?: return
        val containerWidth = containerView.width
        val containerHeight = containerView.height

        val displayView = this.mDisplayView ?: return

        val displayMode = this.mDisplayMode

        val displayAspectRatio = if (mDisplayAspectRatio > 0) {
            mDisplayAspectRatio
        } else {
            calculateVideoRatio()
        }

        if (displayAspectRatio < 0) return

        val containerRatio = containerWidth / containerHeight.toFloat()

        val displayGravity = Gravity.CENTER
        val displayWidth: Int
        val displayHeight: Int

        when (displayMode) {
            DISPLAY_MODE_DEFAULT -> {
                displayWidth = containerWidth
                displayHeight = containerHeight
            }

            DISPLAY_MODE_ASPECT_FILL_X -> {
                displayWidth = containerWidth
                displayHeight = (containerWidth / displayAspectRatio).toInt()
            }

            DISPLAY_MODE_ASPECT_FILL_Y -> {
                displayWidth = (containerHeight * displayAspectRatio).toInt()
                displayHeight = containerHeight
            }

            DISPLAY_MODE_ASPECT_FIT -> if (displayAspectRatio >= containerRatio) {
                displayWidth = containerWidth
                displayHeight = (containerWidth / displayAspectRatio).toInt()
            } else {
                displayWidth = (containerHeight * displayAspectRatio).toInt()
                displayHeight = containerHeight
            }

            DISPLAY_MODE_ASPECT_FILL -> if (displayAspectRatio >= containerRatio) {
                displayWidth = (containerHeight * displayAspectRatio).toInt()
                displayHeight = containerHeight
            } else {
                displayWidth = containerWidth
                displayHeight = (containerWidth / displayAspectRatio).toInt()
            }

            else -> throw IllegalArgumentException("unknown displayMode = $displayMode")
        }

        displayView.updateLayoutParams<FrameLayout.LayoutParams> {
            width = displayWidth
            height = displayHeight
            gravity = displayGravity
        }
    }

    private fun calculateVideoRatio(requiredRatio: Float = -1F): Float {
        val videoWidth = mVideoWidth
        val videoHeight = mVideoHeight
        return if (videoWidth > 0 && videoHeight > 0) {
            videoWidth.toFloat() / videoHeight
        } else {
            requiredRatio
        }
    }

    companion object {
        /**
         * 可能会变形；画面宽高都充满控件；画面不被裁剪；无黑边
         */
        const val DISPLAY_MODE_DEFAULT: Int = 0

        /**
         * 无变形；画面宽充满控件，高按视频比例适配；画面可能被裁剪；可能有黑边。
         */
        const val DISPLAY_MODE_ASPECT_FILL_X: Int = 1

        /**
         * 无变形；画面高充满控件，宽按视频比例适配；画面可能被裁剪；可能有黑边。
         */
        const val DISPLAY_MODE_ASPECT_FILL_Y: Int = 2

        /**
         * 无变形；画面长边充满控件，短边按比例适配；画面不被裁剪；可能有黑边
         */
        const val DISPLAY_MODE_ASPECT_FIT: Int = 3

        /**
         * 无变形；画面短边充满控件，长边按比例适配；画面可能被裁剪；无黑边
         */
        const val DISPLAY_MODE_ASPECT_FILL: Int = 4
    }
}