// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.like

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.SystemClock
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.AttributeSet
import android.view.View
import androidx.core.content.ContextCompat
import kotlin.math.PI
import kotlin.math.sin
import kotlin.random.Random

/**
 * Douyin-style double-tap "like" burst, drawn over any area (e.g. a video
 * player). Self-contained: drop this single file into any project — it has no
 * resource (`R`) dependencies and ships with a built-in heart icon.
 *
 * Behaviour
 * ---------
 * Each [like] spawns a fresh icon at the tap point. The icon appears instantly,
 * wobbles left-right twice, holds, then exits by scaling up while fading out —
 * all within [iconLifetimeMs] (~700ms). Rapid taps stack, newest on top, each
 * with a random icon / size / colour.
 *
 * A small "xN" combo counter sits above the latest tap. Its enter→hold→exit is
 * uninterruptible: a new tap never resets a running bubble. When a bubble ends,
 * the next launches with the current count (so shown numbers may skip). The
 * streak resets after [comboResetMs] of inactivity.
 *
 * Usage
 * -----
 *   // XML: place over your content, match_parent, clickable=false
 *   <...LikeBurstView android:id="@+id/like_burst" .../>
 *
 *   // Code: forward double-tap points
 *   gestureDetector double-tap -> likeBurstView.like(e.x, e.y)
 *
 * Optional customisation (all have sensible defaults):
 *   view.setIcons(myDrawables)        // replace the built-in heart
 *   view.setPalette(intArrayOf(...))  // tint colours; empty = keep icon colours
 *   view.hapticEnabled = false        // disable the per-tap vibration
 *
 * Haptics require `<uses-permission android:name="android.permission.VIBRATE"/>`
 * in the host manifest; without it the tick is silently skipped.
 */
class LikeBurstView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    // --- Public configuration -------------------------------------------------

    /** Whether each like fires a short haptic tick (needs VIBRATE permission). */
    var hapticEnabled: Boolean = true

    /** Lifetime of a single icon's appear→wobble→hold→exit cycle, in ms. */
    var iconLifetimeMs: Float = 700f

    /** Inactivity gap after which the combo streak restarts, in ms. */
    var comboResetMs: Long = 1_000L

    /** Random icon size range (dp). Each spawn picks uniformly within it. */
    var iconMinSizeDp: Int = 54
    var iconMaxSizeDp: Int = 86

    /**
     * How far (dp) the icon is lifted above the tap point, so the heart appears
     * above the finger / cursor (matches Douyin: the tap sits at the icon's
     * lower edge).
     */
    var iconLiftDp: Float = 32f

    /**
     * Replace the icon set cycled through on each tap. Pass your own drawables
     * to swap the built-in heart. Drawables are [Drawable.mutate]d defensively.
     */
    fun setIcons(drawables: List<Drawable>) {
        if (drawables.isEmpty()) return
        icons = drawables.map { it.mutate() }
    }

    /**
     * Tint colours randomly applied to each icon. Pass an empty array to keep
     * each icon's own colours (useful for multi-colour artwork).
     */
    fun setPalette(colors: IntArray) {
        palette = colors
    }

    // --- Internal state -------------------------------------------------------

    private class Mark(
        val x: Float,
        val y: Float,
        val drawable: Drawable,
        val size: Float,
        val tint: Int?,
        val bornAt: Long,
    )

    private val marks = ArrayDeque<Mark>()

    private var icons: List<Drawable> = listOf(BuiltInHeartDrawable())

    private var palette: IntArray = intArrayOf(
        Color.parseColor("#FF4D6D"),
        Color.parseColor("#FF8A3D"),
        Color.parseColor("#FFC53D"),
        Color.parseColor("#7C5CFF"),
        Color.parseColor("#22C3FF"),
        Color.parseColor("#37D67A"),
    )

    private val comboPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD_ITALIC)
        textSize = dp(18f)
        color = Color.WHITE
        textAlign = Paint.Align.CENTER
        setShadowLayer(dp(2f), 0f, dp(1f), 0x88000000.toInt())
    }

    private var comboCount = 0
    private var comboX = 0f
    private var comboY = 0f
    private var lastLikeAt = 0L

    /** Last icon index used, so two consecutive taps never show the same icon. */
    private var lastIconIndex = -1

    // The text bubble runs an uninterruptible enter→hold→exit cycle. Once it
    // finishes it re-checks comboCount and, if the streak advanced, pops a fresh
    // bubble with the latest number (so shown numbers may skip).
    private var bubbleStartAt = 0L
    private var bubbleCount = 0
    private var bubbleX = 0f
    private var bubbleY = 0f

    private val vibrator: Vibrator? =
        ContextCompat.getSystemService(context, Vibrator::class.java)

    // --- API ------------------------------------------------------------------

    /**
     * Register a like at ([x], [y]) within this view. Spawns an icon, advances
     * the combo (anchored at this tap) and fires haptic feedback.
     */
    fun like(x: Float, y: Float) {
        val now = SystemClock.uptimeMillis()

        // New streak if the previous one timed out.
        if (now - lastLikeAt > comboResetMs || comboCount == 0) {
            comboCount = 0
            // The previous streak's bubble has long finished; clear it so the
            // new streak can show its number even if it matches the old one.
            bubbleCount = 0
        }
        comboCount++
        lastLikeAt = now

        // Lift the icon above the tap so the finger / cursor sits at its lower
        // edge (Douyin behaviour).
        val iconY = y - dp(iconLiftDp)
        // Counter follows the latest tap, anchored to the lifted icon.
        comboX = x
        comboY = iconY

        val iconIndex = nextIconIndex()
        val icon = icons[iconIndex]
        marks.addLast(
            Mark(
                x = x,
                y = iconY,
                drawable = icon,
                size = dp(Random.nextInt(iconMinSizeDp, iconMaxSizeDp + 1).toFloat()),
                tint = if (palette.isEmpty()) null else palette[Random.nextInt(palette.size)],
                bornAt = now,
            )
        )
        while (marks.size > MAX_MARKS) marks.removeFirst()

        vibrate()
        invalidate()
    }

    /** Pick an icon index that differs from the previous tap when possible. */
    private fun nextIconIndex(): Int {
        if (icons.size <= 1) return 0
        var idx = Random.nextInt(icons.size)
        while (idx == lastIconIndex) idx = Random.nextInt(icons.size)
        lastIconIndex = idx
        return idx
    }

    // --- Drawing --------------------------------------------------------------

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val now = SystemClock.uptimeMillis()

        // Drop expired icons (oldest first).
        while (marks.isNotEmpty() && now - marks.first().bornAt > iconLifetimeMs) {
            marks.removeFirst()
        }

        // Oldest first so the newest is painted last (on top).
        marks.forEach { mark ->
            val t = (now - mark.bornAt).toFloat() / iconLifetimeMs
            val alpha = iconAlpha(t)
            if (alpha <= 0f) return@forEach
            val half = mark.size / 2f

            canvas.save()
            canvas.translate(mark.x, mark.y)
            canvas.rotate(iconWobble(t))
            val scale = iconScale(t)
            canvas.scale(scale, scale)
            mark.tint?.let { mark.drawable.setTint(it) }
            mark.drawable.alpha = (alpha * 255).toInt()
            mark.drawable.setBounds(
                (-half).toInt(), (-half).toInt(), half.toInt(), half.toInt(),
            )
            mark.drawable.draw(canvas)
            canvas.restore()
        }

        drawCombo(canvas, now)

        val bubbleActive = bubbleCount > 0 && now - bubbleStartAt < bubbleTotalMs()
        if (marks.isNotEmpty() || bubbleActive) {
            postInvalidateOnAnimation()
        }
    }

    /**
     * Combo counter above the latest tap. Each bubble plays an uninterruptible
     * enter→hold→exit cycle; new taps never reset a running bubble. When one
     * finishes, the next is launched with the current [comboCount] (numbers may
     * skip). A bubble only shows for combos > 1.
     */
    private fun drawCombo(canvas: Canvas, now: Long) {
        val total = bubbleTotalMs()
        val elapsed = now - bubbleStartAt

        // Launch a new bubble when none is running and the streak is ahead of
        // what we last displayed.
        if ((bubbleCount == 0 || elapsed >= total) &&
            comboCount > 1 && comboCount != bubbleCount
        ) {
            bubbleStartAt = now
            bubbleCount = comboCount
            bubbleX = comboX
            bubbleY = comboY
            // Restart the clock for the freshly launched bubble.
            return drawCombo(canvas, now)
        }

        if (bubbleCount <= 1 || elapsed >= total) return

        val text = "x$bubbleCount"
        val tx = bubbleX.coerceIn(dp(8f), width - dp(8f))
        // Baseline so the text sits just above the icon, overlapping its top a
        // touch at full size.
        val baseY = (bubbleY - dp(COMBO_GAP_DP)).coerceAtLeast(comboPaint.textSize)
        // Pivot at the glyphs' visual centre so scaling grows/shrinks in place.
        val pivotY = baseY - comboPaint.textSize * 0.35f

        val scale: Float
        val alpha: Float
        val dy: Float
        if (elapsed < TEXT_ENTER_MS) {
            // Enter: alpha stays 1, scale grows from tiny → full with a
            // decelerating ease, no vertical movement.
            val t = elapsed / TEXT_ENTER_MS
            val eased = 1f - (1f - t) * (1f - t)
            scale = TEXT_MIN_SCALE + (1f - TEXT_MIN_SCALE) * eased
            alpha = 1f
            dy = 0f
        } else if (elapsed < TEXT_ENTER_MS + TEXT_HOLD_MS) {
            scale = 1f
            alpha = 1f
            dy = 0f
        } else {
            // Exit: scale 1 → 0.5 while rising ~1.5× text height and fading out,
            // on an accelerating ease (ends the instant scale hits 0.5).
            val t = ((elapsed - TEXT_ENTER_MS - TEXT_HOLD_MS) / TEXT_EXIT_MS).coerceIn(0f, 1f)
            val eased = t * t
            scale = 1f - (1f - TEXT_EXIT_SCALE) * eased
            alpha = 1f - eased
            dy = -comboPaint.textSize * TEXT_EXIT_RISE_FACTOR * eased
        }

        comboPaint.alpha = (alpha * 255).toInt()
        canvas.save()
        canvas.translate(0f, dy)
        canvas.scale(scale, scale, tx, pivotY)
        canvas.drawText(text, tx, baseY, comboPaint)
        canvas.restore()
    }

    // --- Animation curves -----------------------------------------------------

    /** Instant pop-in, steady hold, then scale-up while exiting. */
    private fun iconScale(t: Float): Float = when {
        t < 0.08f -> 0.7f + (t / 0.08f) * 0.3f
        t < ICON_EXIT_T -> 1f
        else -> 1f + ((t - ICON_EXIT_T) / (1f - ICON_EXIT_T)) * 0.5f
    }

    /** Quick fade-in, full hold, then alpha fade-out over the exit phase. */
    private fun iconAlpha(t: Float): Float = when {
        t < 0.08f -> t / 0.08f
        t < ICON_EXIT_T -> 1f
        t < 1f -> 1f - (t - ICON_EXIT_T) / (1f - ICON_EXIT_T)
        else -> 0f
    }

    /** Two damped left-right wobbles over the first ~45% of life. */
    private fun iconWobble(t: Float): Float {
        if (t >= WOBBLE_END_T) return 0f
        val p = t / WOBBLE_END_T
        return (WOBBLE_AMP_DEG * (1f - p) * sin(p.toDouble() * PI * 2 * WOBBLE_CYCLES)).toFloat()
    }

    // --- Helpers --------------------------------------------------------------

    private fun bubbleTotalMs(): Float = TEXT_ENTER_MS + TEXT_HOLD_MS + TEXT_EXIT_MS

    private fun vibrate() {
        if (!hapticEnabled) return
        val v = vibrator ?: return
        if (!v.hasVibrator()) return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                v.vibrate(VibrationEffect.createOneShot(VIBRATE_MS, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                v.vibrate(VIBRATE_MS)
            }
        } catch (_: SecurityException) {
            // VIBRATE permission not granted by the host app; skip silently.
        }
    }

    private fun dp(value: Float): Float = value * resources.displayMetrics.density

    /**
     * A simple solid heart rendered with a [Path], so the view needs no drawable
     * resources. Tinted at runtime like any other icon.
     */
    private class BuiltInHeartDrawable : Drawable() {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE }
        private val path = Path()

        override fun onBoundsChange(bounds: android.graphics.Rect) {
            val w = bounds.width().toFloat()
            val h = bounds.height().toFloat()
            val l = bounds.left.toFloat()
            val t = bounds.top.toFloat()
            path.reset()
            // Heart built from the top notch, two lobes and a bottom tip.
            path.moveTo(l + w * 0.5f, t + h * 0.30f)
            path.cubicTo(
                l + w * 0.42f, t + h * 0.08f, l + w * 0.06f, t + h * 0.12f,
                l + w * 0.06f, t + h * 0.40f,
            )
            path.cubicTo(
                l + w * 0.06f, t + h * 0.66f, l + w * 0.36f, t + h * 0.84f,
                l + w * 0.5f, t + h * 0.95f,
            )
            path.cubicTo(
                l + w * 0.64f, t + h * 0.84f, l + w * 0.94f, t + h * 0.66f,
                l + w * 0.94f, t + h * 0.40f,
            )
            path.cubicTo(
                l + w * 0.94f, t + h * 0.12f, l + w * 0.58f, t + h * 0.08f,
                l + w * 0.5f, t + h * 0.30f,
            )
            path.close()
        }

        override fun draw(canvas: Canvas) = canvas.drawPath(path, paint)
        override fun setAlpha(alpha: Int) { paint.alpha = alpha }
        override fun setColorFilter(cf: android.graphics.ColorFilter?) { paint.colorFilter = cf }
        override fun setTint(tintColor: Int) { paint.color = tintColor }
        @Deprecated("Deprecated in Java", ReplaceWith("PixelFormat.TRANSLUCENT"))
        override fun getOpacity(): Int = android.graphics.PixelFormat.TRANSLUCENT
    }

    private companion object {
        const val MAX_MARKS = 8
        const val ICON_EXIT_T = 0.62f
        const val WOBBLE_END_T = 0.45f
        const val WOBBLE_AMP_DEG = 12f
        const val WOBBLE_CYCLES = 2

        // Combo text "xN": scale-in (no move) → hold → scale-down + rise + fade.
        // ~500ms total per the Douyin reference.
        const val TEXT_ENTER_MS = 140f
        const val TEXT_HOLD_MS = 200f
        const val TEXT_EXIT_MS = 160f
        /** Start size of the scale-in, ~1/5 of full per the Douyin reference. */
        const val TEXT_MIN_SCALE = 0.2f
        /** Exit ends the moment the text has shrunk to this fraction. */
        const val TEXT_EXIT_SCALE = 0.5f
        /** Exit rise distance as a multiple of the text size (~1.5× height). */
        const val TEXT_EXIT_RISE_FACTOR = 1.5f
        /** Gap (dp) between the text baseline anchor and the icon centre, so the
         *  full-size text overlaps the icon's top slightly. */
        const val COMBO_GAP_DP = 40f

        const val VIBRATE_MS = 18L
    }
}
