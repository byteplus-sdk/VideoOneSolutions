// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.core

import com.vertcdemo.effect.ui.OnEffectHandlerUpdatedListener
import java.util.regex.Pattern

interface IEffect {
    fun enableEffect(licensePath: String, modelPath: String): EffectResult

    fun setEffectNodes(paths: List<String>)

    fun updateEffectNode(path: String, key: String, value: Float)

    fun setColorFilter(path: String)

    fun setColorFilterIntensity(intensity: Float)

    fun setSticker(path: String)

    fun setOnEffectHandlerUpdatedListener(listener: OnEffectHandlerUpdatedListener?)

    companion object {
        private val pathPattern =
            Pattern.compile("(ComposeMakeup|FilterResource|LicenseBag|ModelResource|StickerResource)\\.bundle")

        @JvmStatic
        fun trim(path: String?): String? {
            if (path.isNullOrEmpty()) return path

            val matcher = pathPattern.matcher(path)
            return if (matcher.find()) {
                path.substring(matcher.start())
            } else {
                path
            }
        }

        @JvmStatic
        fun trim(paths: List<String>): Array<String?> =
            paths.map { trim(it) }.toTypedArray()
    }

    data class EffectResult(val code: Int, val message: String? = "") {
        val success: Boolean
            get() = code == 0

        companion object {
            @JvmField
            val OK = EffectResult(0)
        }
    }
}
