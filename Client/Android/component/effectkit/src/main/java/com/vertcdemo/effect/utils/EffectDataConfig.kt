// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.utils

import com.vertcdemo.effect.R
import com.vertcdemo.effect.bean.BeautyItem
import com.vertcdemo.effect.bean.FilterItem
import com.vertcdemo.effect.bean.StickerItem
import java.util.Arrays

object EffectDataConfig {
    private const val NODE_BEAUTY = "beauty_Android_lite"
    private const val NODE_RESHAPE = "reshape_lite"

    val BEAUTY_CLOSE: BeautyItem =
        BeautyItem(R.drawable.ic_effect_clear, R.string.close)

    fun defaultBeauty(): List<BeautyItem> {
        return listOf(
            BEAUTY_CLOSE,
            BeautyItem(
                R.drawable.ic_effect_beauty_whiten,
                R.string.beauty_face_whiten,
                NODE_BEAUTY,
                "whiten",
                0.38f
            ),
            BeautyItem(
                R.drawable.ic_effect_beauty_smooth,
                R.string.beauty_face_smooth,
                NODE_BEAUTY,
                "smooth",
                0.53f
            ),
            BeautyItem(
                R.drawable.ic_effect_beauty_cheek_reshape,
                R.string.beauty_reshape_face_group,
                NODE_RESHAPE,
                "Internal_Deform_Overall",
                0.5f
            ),
            BeautyItem(
                R.drawable.ic_effect_reshape_eye_size,
                R.string.beauty_reshape_eye_group,
                NODE_RESHAPE,
                "Internal_Deform_Eye",
                0.5f
            ),
            BeautyItem(
                R.drawable.ic_effect_beauty_sharpen,
                R.string.beauty_face_sharpen,
                NODE_BEAUTY,
                "sharp",
                0.35f
            ),
            BeautyItem(
                R.drawable.ic_effect_beauty_clarity,
                R.string.beauty_face_clarity,
                NODE_BEAUTY,
                "clear",
                0.23f
            )
        )
    }

    val FILTER_CLOSE: FilterItem =
        FilterItem(R.drawable.ic_effect_clear_padding, R.string.filter_normal)

    fun defaultFilters(): List<FilterItem> = listOf(
        FILTER_CLOSE,
        FilterItem(
            R.drawable.icon_filter_lianaichaotian,
            R.string.filter_lianaichaotian,
            "Filter_24_Po2"
        ),
        FilterItem(R.drawable.icon_filter_ziran, R.string.filter_ziran, "Filter_38_F1"),
        FilterItem(R.drawable.icon_filter_hongzong, R.string.filter_hongzong, "Filter_36_L4"),
        FilterItem(R.drawable.icon_filter_qiannuan, R.string.filter_musi, "Filter_10_11"),
        FilterItem(R.drawable.icon_filter_naiyou, R.string.filter_cream, "Filter_02_14"),
        FilterItem(R.drawable.icon_filter_luolita, R.string.filter_lolita, "Filter_05_10"),
        FilterItem(R.drawable.icon_filter_qianxia, R.string.filter_qianxia, "Filter_34_L2"),
        FilterItem(R.drawable.icon_filter_mitao, R.string.filter_mitao, "Filter_06_03")
    )

    val STICKER_CLOSE: StickerItem =
        StickerItem(R.drawable.ic_effect_clear_padding, R.string.filter_normal)

    fun defaultStickers(): List<StickerItem> = listOf(
        STICKER_CLOSE,
        StickerItem(R.drawable.icon_heimaoyanjing, R.string.sticker_heimaoyanjing, "heimaoyanjing"),
        StickerItem(R.drawable.icon_huahua, R.string.sticker_huahua, "huahua"),
        StickerItem(R.drawable.icon_aixinxin, R.string.sticker_aixinpiaola, "aixinpiaola"),
        StickerItem(R.drawable.icon_aidou, R.string.style_makeup_aidou, "aidou"),
        StickerItem(R.drawable.icon_qise, R.string.style_makeup_qise, "qise")
    )
}
