// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.bean

import android.text.TextUtils
import androidx.annotation.DrawableRes
import androidx.annotation.FloatRange
import androidx.annotation.StringRes

abstract class EffectItem(
    @DrawableRes val icon: Int, @StringRes val title: Int, val path: String
) {
    var isSelected: Boolean = false

    val isClose: Boolean
        get() = TextUtils.isEmpty(path)

    open fun reset() {
        isSelected = false
    }
}

abstract class EffectValueItem(
    @DrawableRes icon: Int, @StringRes title: Int, path: String, private val defaultValue: Float
) : EffectItem(icon, title, path) {

    var value: Float = defaultValue

    override fun reset() {
        super.reset()
        value = defaultValue
    }
}

class StickerItem(
    @DrawableRes icon: Int, @StringRes title: Int, path: String = ""
) : EffectItem(icon, title, path)

private const val VALUE_DEFAULT_FILTER = 0.8F

class FilterItem(
    @DrawableRes icon: Int, @StringRes title: Int, path: String = ""
) : EffectValueItem(icon, title, path, VALUE_DEFAULT_FILTER)


class BeautyItem(
    @DrawableRes icon: Int,
    @StringRes title: Int,
    path: String = "",
    val key: String = "",
    @FloatRange(from = 0.0, to = 1.0) defaultValue: Float = 0.0F
) : EffectValueItem(icon, title, path, defaultValue) {

    var isChecked: Boolean = false

    override fun reset() {
        super.reset()
        isChecked = false
    }
}
