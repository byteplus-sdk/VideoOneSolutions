// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.like

import android.content.Context
import android.graphics.Canvas
import android.graphics.Path
import android.graphics.PathMeasure
import android.graphics.drawable.Drawable
import android.os.SystemClock
import android.util.AttributeSet
import android.view.View
import kotlin.random.Random

/**
 * Douyin-style "floating like" overlay anchored to a fixed point (e.g. above the
 * settings / gift button). Each [spawn] launches one icon that rises from the
 * anchor along one of several random cubic Bézier paths while fading + scaling,
 * then removes itself.
 *
 * Unlike [LikeBurstView] (which bursts icons at the touch point with a combo
 * counter), this view is purely the rising-stream effect from a fixed corner.
 * The two run together on each like.
 *
 * Self-drawn (no per-icon ImageView / AnimatorSet) to match LikeBurstView's
 * rendering model and keep allocations low under rapid taps.
 *
 * Usage:
 *   // XML: full-screen, clickable=false, above content / below the controls.
 *   // Code: set the icons once, then call spawn(anchorX, anchorY) per like.
 *   view.setIcons(drawables)
 *   view.spawn(anchorXInThisView, anchorYInThisView)
 */
class ThumbFloatingView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    /** Fixed icon size in dp (no random sizing, per product). */
    var iconSizeDp: Float = 32f

    /** Lifetime of one icon's rise→fade cycle, in ms. */
    var lifetimeMs: Float = 1_300f

    /** How far (dp) an icon travels upward from the anchor over its life. */
    var riseDistanceDp: Float = 140f

    /**
     * Replace the cycled icon set. Drawables are [Drawable.mutate]d defensively
     * so per-icon alpha never leaks across spawns sharing the same constant
     * state.
     */
    fun setIcons(drawables: List<Drawable>) {
        if (drawables.isEmpty()) return
        icons = drawables.map { it.mutate() }
        drawableIndex = 0
    }

    /**
     * Launch one floating icon from ([anchorX], [anchorY]) — coordinates are in
     * this view's own space. Cycles through the icon set in order so a streak
     * fans out the full set.
     */
    fun spawn(anchorX: Float, anchorY: Float) {
        if (width == 0 || height == 0) return
        val icon = icons[drawableIndex % icons.size]
        drawableIndex++
        marks.addLast(
            Mark(
                drawable = icon,
                path = createPath(anchorX, anchorY),
                size = dp(iconSizeDp),
                rotation = ROTATIONS[Random.nextInt(ROTATIONS.size)] * BASE_ROTATION_DEG,
                bornAt = SystemClock.uptimeMillis(),
            )
        )
        while (marks.size > MAX_MARKS) marks.removeFirst()
        invalidate()
    }

    // --- Internal state -------------------------------------------------------

    private class Mark(
        val drawable: Drawable,
        val path: Path,
        val size: Float,
        val rotation: Float,
        val bornAt: Long,
    ) {
        val measure = PathMeasure(path, false)
        val length = measure.length
        val pos = FloatArray(2)
    }

    private val marks = ArrayDeque<Mark>()
    private var icons: List<Drawable> = emptyList()
    private var drawableIndex = 0
    private var lastPathPick = -1

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val now = SystemClock.uptimeMillis()

        while (marks.isNotEmpty() && now - marks.first().bornAt > lifetimeMs) {
            marks.removeFirst()
        }

        marks.forEach { mark ->
            val t = (now - mark.bornAt).toFloat() / lifetimeMs
            val alpha = alphaAt(t)
            if (alpha <= 0f) return@forEach
            mark.measure.getPosTan(mark.length * t, mark.pos, null)
            val half = mark.size / 2f
            val scale = scaleAt(t)

            canvas.save()
            canvas.translate(mark.pos[0], mark.pos[1])
            canvas.rotate(mark.rotation)
            canvas.scale(scale, scale)
            mark.drawable.alpha = (alpha * 255).toInt()
            mark.drawable.setBounds(
                (-half).toInt(), (-half).toInt(), half.toInt(), half.toInt(),
            )
            mark.drawable.draw(canvas)
            canvas.restore()
        }

        if (marks.isNotEmpty()) postInvalidateOnAnimation()
    }

    /**
     * Build a rising cubic Bézier from the anchor. The path picks one of five
     * horizontal drifts so consecutive icons spread out; the same drift is never
     * picked twice in a row (matches the reference's anti-repeat behaviour).
     */
    private fun createPath(anchorX: Float, anchorY: Float): Path {
        val path = Path()
        path.moveTo(anchorX, anchorY)

        val rise = dp(riseDistanceDp)
        val endY = anchorY - rise
        val drift = dp(DRIFT_STEP_DP)
        var pick = Random.nextInt(DRIFTS.size)
        while (pick == lastPathPick) pick = Random.nextInt(DRIFTS.size)
        lastPathPick = pick
        val endX = anchorX + DRIFTS[pick] * drift

        // Two control points give the lazy S-curve sway as the icon rises.
        val ctrl1X = anchorX + DRIFTS[pick] * drift * 0.6f
        val ctrl1Y = anchorY - rise * 0.35f
        val ctrl2X = anchorX - DRIFTS[pick] * drift * 0.4f
        val ctrl2Y = anchorY - rise * 0.7f
        path.cubicTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, endX, endY)
        return path
    }

    /** Quick pop-in, hold, then gentle scale-up while exiting. */
    private fun scaleAt(t: Float): Float = when {
        t < 0.15f -> 0.4f + (t / 0.15f) * 0.6f
        else -> 1f
    }

    /** Fade in fast, hold, then fade out over the back half of the rise. */
    private fun alphaAt(t: Float): Float = when {
        t < 0.15f -> t / 0.15f
        t < FADE_START_T -> 1f
        t < 1f -> 1f - (t - FADE_START_T) / (1f - FADE_START_T)
        else -> 0f
    }

    private fun dp(value: Float): Float = value * resources.displayMetrics.density

    private companion object {
        const val MAX_MARKS = 16
        const val FADE_START_T = 0.5f
        const val BASE_ROTATION_DEG = 30f
        const val DRIFT_STEP_DP = 18f
        val ROTATIONS = intArrayOf(-1, 1)
        // Horizontal drift multipliers for the five spread lanes.
        val DRIFTS = floatArrayOf(-2f, -1f, 0f, 1f, 2f)
    }
}
