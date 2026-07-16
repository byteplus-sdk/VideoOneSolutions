// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.compare

import android.content.Context
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader
import android.util.AttributeSet
import android.view.View
import kotlin.math.max

/**
 * Self-drawn bitrate waveform for the cost-reduction tab's "tap to inspect"
 * dialog. Renders the last [capacity] bitrate samples (≈1 min at the 1s stats
 * cadence) as a filled line chart with a light grid. No third-party charting
 * library — just [Canvas].
 *
 * Feed it via [setSamples] (initial backfill) and [addSample] (live ticks).
 */
class BitrateChartView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    private val capacity = 60

    /** Ring buffer of samples in kbps, oldest first once full. */
    private val samples = ArrayDeque<Long>(capacity)

    private val gridPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0x33FFFFFF
        strokeWidth = dp(1f)
        style = Paint.Style.STROKE
    }
    private val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFF4D8DFF.toInt()
        strokeWidth = dp(2f)
        style = Paint.Style.STROKE
        strokeJoin = Paint.Join.ROUND
        strokeCap = Paint.Cap.ROUND
    }
    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }
    private val axisTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0x99FFFFFF.toInt()
        textSize = dp(10f)
    }

    private val linePath = Path()
    private val fillPath = Path()

    private val padLeft = dp(40f)
    private val padRight = dp(12f)
    private val padTop = dp(12f)
    private val padBottom = dp(20f)

    fun setSamples(values: List<Long>) {
        samples.clear()
        values.takeLast(capacity).forEach { samples.addLast(it) }
        invalidate()
    }

    fun addSample(value: Long) {
        if (samples.size >= capacity) samples.removeFirst()
        samples.addLast(value)
        invalidate()
    }

    /** Latest sample, or 0 when empty. */
    fun current(): Long = samples.lastOrNull() ?: 0L

    /** Peak sample, or 0 when empty. */
    fun peak(): Long = samples.maxOrNull() ?: 0L

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val left = padLeft
        val top = padTop
        val right = width - padRight
        val bottom = height - padBottom
        if (right <= left || bottom <= top) return

        // Y scale: 0 .. max(peak, 1), rounded up a touch for headroom.
        val maxVal = max(peak().toFloat(), 1f) * 1.15f

        // Horizontal grid lines + Y labels (0 / mid / max).
        val rows = 4
        for (i in 0..rows) {
            val y = bottom - (bottom - top) * i / rows
            canvas.drawLine(left, y, right, y, gridPaint)
            val label = (maxVal * i / rows).toInt().toString()
            canvas.drawText(label, dp(4f), y + dp(3.5f), axisTextPaint)
        }

        // X axis labels: -60s .. now.
        canvas.drawText(
            context.getString(com.byteplus.live.sport.R.string.live_sport_compare_chart_axis_start),
            left,
            (height - dp(5f)),
            axisTextPaint,
        )
        val nowLabel = context.getString(com.byteplus.live.sport.R.string.live_sport_compare_chart_axis_now)
        canvas.drawText(
            nowLabel,
            right - axisTextPaint.measureText(nowLabel),
            (height - dp(5f)),
            axisTextPaint,
        )

        if (samples.size < 2) return

        // Map each sample to a point. X spans the full plot width over `capacity`
        // slots so a partially-filled buffer grows from the left.
        val stepX = (right - left) / (capacity - 1).toFloat()
        linePath.reset()
        fillPath.reset()
        val list = samples.toList()
        // Right-align the newest sample at `right`.
        val startIndex = capacity - list.size
        list.forEachIndexed { i, v ->
            val x = left + (startIndex + i) * stepX
            val y = bottom - (bottom - top) * (v.toFloat() / maxVal)
            if (i == 0) {
                linePath.moveTo(x, y)
                fillPath.moveTo(x, bottom)
                fillPath.lineTo(x, y)
            } else {
                linePath.lineTo(x, y)
                fillPath.lineTo(x, y)
            }
        }
        val lastX = left + (startIndex + list.size - 1) * stepX
        fillPath.lineTo(lastX, bottom)
        fillPath.close()

        fillPaint.shader = LinearGradient(
            0f, top, 0f, bottom,
            0x664D8DFF, 0x0A4D8DFF,
            Shader.TileMode.CLAMP,
        )
        canvas.drawPath(fillPath, fillPaint)
        canvas.drawPath(linePath, linePaint)
    }

    private fun dp(v: Float): Float = v * resources.displayMetrics.density
}
