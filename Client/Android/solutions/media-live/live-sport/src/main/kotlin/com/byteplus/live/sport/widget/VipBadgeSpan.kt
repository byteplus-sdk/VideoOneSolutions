// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.widget

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.text.style.ReplacementSpan

/**
 * Inline VIP badge for live-comment text.
 *
 * Drawn as a fixed-size pill that matches the Figma badge spec
 * (e.g. node 10877:122625 for VIP3):
 *
 *   [ pad | diamond drawable | gap | "VIP{level}" label | pad ]
 *   42 x 14dp pill, 7dp corner radius, optional stroke for high tiers.
 *
 * The diamond glyph itself is supplied as a [Drawable] (one PNG per level)
 * so designers can iterate on it without code changes; the pill background,
 * stroke and label are drawn here.
 *
 * Why [ReplacementSpan] (not [android.text.style.ImageSpan]):
 *  - Mixes inline with user name + content in the same TextView so wrapping
 *    behaves naturally.
 *  - Width / height are fixed by spec; drawing the pill on canvas avoids
 *    nine-patch / per-tier full-pill assets.
 */
class VipBadgeSpan(
    private val level: Int,
    private val widthPx: Float,
    private val heightPx: Float,
    private val cornerRadiusPx: Float,
    private val paddingHorizontalPx: Float,
    private val iconDrawable: Drawable,
    private val iconSizePx: Float,
    private val iconTextGapPx: Float,
    private val labelSizePx: Float,
    private val labelColor: Int,
    private val backgroundColor: Int,
    private val strokeColor: Int = 0,
    private val strokeWidthPx: Float = 0f,
    private val marginEndPx: Float,
) : ReplacementSpan() {

    private val labelText: String = "VIP$level"
    private val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = labelColor
        textSize = labelSizePx
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }
    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = backgroundColor
    }
    private val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        color = strokeColor
        strokeWidth = strokeWidthPx
    }
    private val rect = RectF()
    private val labelBounds = Rect()

    override fun getSize(
        paint: Paint,
        text: CharSequence?,
        start: Int,
        end: Int,
        fm: Paint.FontMetricsInt?,
    ): Int = (widthPx + marginEndPx).toInt()

    override fun draw(
        canvas: Canvas,
        text: CharSequence?,
        start: Int,
        end: Int,
        x: Float,
        top: Int,
        y: Int,
        bottom: Int,
        paint: Paint,
    ) {
        // Center the fixed-size pill vertically on the host text baseline so
        // the badge optically aligns with surrounding 13sp text.
        val fm = paint.fontMetrics
        val lineCenter = y + (fm.ascent + fm.descent) / 2f
        val pillTop = lineCenter - heightPx / 2f
        val pillBottom = lineCenter + heightPx / 2f
        rect.set(x, pillTop, x + widthPx, pillBottom)
        canvas.drawRoundRect(rect, cornerRadiusPx, cornerRadiusPx, bgPaint)

        if (strokeWidthPx > 0f) {
            // Inset by half stroke so the stroke stays inside the pill bounds
            // (drawRoundRect strokes are centred on the path).
            val inset = strokeWidthPx / 2f
            val strokeRect = RectF(
                rect.left + inset,
                rect.top + inset,
                rect.right - inset,
                rect.bottom - inset,
            )
            canvas.drawRoundRect(strokeRect, cornerRadiusPx, cornerRadiusPx, strokePaint)
        }

        // Diamond drawable, vertically centred against the pill, anchored at
        // the left padding offset.
        val iconLeft = rect.left + paddingHorizontalPx
        val iconTop = rect.centerY() - iconSizePx / 2f
        iconDrawable.setBounds(
            iconLeft.toInt(),
            iconTop.toInt(),
            (iconLeft + iconSizePx).toInt(),
            (iconTop + iconSizePx).toInt(),
        )
        iconDrawable.draw(canvas)

        // Label centred within (iconRight + iconTextGap, badgeRight - paddingH).
        val labelRegionLeft = iconLeft + iconSizePx + iconTextGapPx
        val labelRegionRight = rect.right - paddingHorizontalPx
        labelPaint.getTextBounds(labelText, 0, labelText.length, labelBounds)
        val textVisualWidth = labelBounds.width().toFloat()
        val textLeft = labelRegionLeft +
            (labelRegionRight - labelRegionLeft - textVisualWidth) / 2f -
            labelBounds.left

        // Vertical: align using tight glyph bounds for true optical centering.
        val baseline = rect.centerY() + labelBounds.height() / 2f - labelBounds.bottom
        canvas.drawText(labelText, textLeft, baseline, labelPaint)
    }
}
