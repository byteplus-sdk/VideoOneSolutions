// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui

import com.vertcdemo.effect.bean.BeautyItem
import com.vertcdemo.effect.bean.EffectType
import com.vertcdemo.effect.bean.EffectValueItem
import com.vertcdemo.effect.bean.FilterItem

data class ValueProgress(val type: EffectType, val value: Float) {
    val isNone: Boolean
        get() = type == EffectType.none

    companion object {
        val NONE: ValueProgress = ValueProgress(EffectType.none, -1f)
    }
}

fun EffectValueItem.progress(): ValueProgress = when {
    this.isClose -> ValueProgress.NONE
    this is BeautyItem -> ValueProgress(EffectType.beauty, this.value)
    this is FilterItem -> ValueProgress(EffectType.filter, this.value)
    else -> ValueProgress.NONE
}
