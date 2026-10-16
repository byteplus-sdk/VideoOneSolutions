// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.widget

import android.content.Context
import android.util.TypedValue
import androidx.core.content.ContextCompat
import com.byteplus.live.sport.R

/**
 * Single source of truth for VIP badge styling.
 *
 * Routes per-level diamond assets, background colors and optional gold
 * stroke into a [VipBadgeSpan]. To redesign the badge, edit this file —
 * every screen using the badge picks up the change.
 *
 * Spec follows Figma node 10877:122625 (VIP3) and 10877:122562 (VIP2):
 *   - 42 x 14 dp pill, 7dp corner radius
 *   - 4dp horizontal padding
 *   - 10dp diamond glyph + 2dp gap before the label
 *   - 10sp Semibold white label
 *   - per-level background; VIP3 also has a 0.5dp gold stroke
 */
object VipBadgeFactory {

    private const val WIDTH_DP = 42f
    private const val HEIGHT_DP = 14f
    private const val CORNER_DP = 7f
    private const val PADDING_H_DP = 4f
    private const val ICON_DP = 10f
    private const val ICON_TEXT_GAP_DP = 2f
    private const val LABEL_SP = 10f
    private const val STROKE_DP = 0.5f
    private const val DEFAULT_MARGIN_END_DP = 4f

    private const val LABEL_COLOR: Int = 0xFFFFFFFF.toInt()
    private const val BG_VIP1: Int = 0xFF1F84FF.toInt()
    private const val BG_VIP2: Int = 0xFF606CF2.toInt()
    private const val BG_VIP3: Int = 0xFF822BFF.toInt()
    private const val STROKE_VIP3: Int = 0xFFFFD685.toInt()

    /**
     * Build a fully-styled badge span.
     *
     * @param context     for resource resolution and dp/sp conversion
     * @param level       VIP tier; routes to per-level diamond + palette
     * @param marginEndDp trailing space after the badge in inline contexts
     */
    fun create(
        context: Context,
        level: Int,
        marginEndDp: Float = DEFAULT_MARGIN_END_DP,
    ): VipBadgeSpan {
        val (bg, stroke, iconRes) = palette(level)
        val iconDrawable = ContextCompat.getDrawable(context, iconRes)!!.mutate()
        return VipBadgeSpan(
            level = level,
            widthPx = dp(context, WIDTH_DP),
            heightPx = dp(context, HEIGHT_DP),
            cornerRadiusPx = dp(context, CORNER_DP),
            paddingHorizontalPx = dp(context, PADDING_H_DP),
            iconDrawable = iconDrawable,
            iconSizePx = dp(context, ICON_DP),
            iconTextGapPx = dp(context, ICON_TEXT_GAP_DP),
            labelSizePx = sp(context, LABEL_SP),
            labelColor = LABEL_COLOR,
            backgroundColor = bg,
            strokeColor = stroke,
            strokeWidthPx = if (stroke != 0) dp(context, STROKE_DP) else 0f,
            marginEndPx = dp(context, marginEndDp),
        )
    }

    /** @return Triple(background, stroke, diamond drawable). stroke=0 means no border. */
    private fun palette(level: Int): Triple<Int, Int, Int> = when (level) {
        3 -> Triple(BG_VIP3, STROKE_VIP3, R.drawable.live_sport_vip_diamond_3)
        2 -> Triple(BG_VIP2, 0, R.drawable.live_sport_vip_diamond_2)
        else -> Triple(BG_VIP1, 0, R.drawable.live_sport_vip_diamond_1)
    }

    private fun dp(context: Context, value: Float): Float =
        TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value,
            context.resources.displayMetrics,
        )

    private fun sp(context: Context, value: Float): Float =
        TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_SP,
            value,
            context.resources.displayMetrics,
        )
}
