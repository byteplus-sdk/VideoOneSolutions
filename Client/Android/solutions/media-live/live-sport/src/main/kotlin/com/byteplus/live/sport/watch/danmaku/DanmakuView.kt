// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.danmaku

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.os.SystemClock
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View

/**
 * Bilibili-style scrolling danmaku (barrage) drawn over any area, e.g. a video
 * player. Self-contained: drop this single file into any project — it has no
 * resource (`R`) dependencies.
 *
 * Rendering
 * ---------
 * Everything is painted on this one View's [Canvas]; each comment is a
 * lightweight data object, NOT a child View. Items move right→left at a
 * constant speed, so each item's x position is a pure function of elapsed time
 * (`x = width - speed * age`). This makes the animation cheap (one View, zero
 * per-item allocation per frame) and overlap-free by construction.
 *
 * No-overlap
 * ----------
 * The visible height is split into equal horizontal tracks (lanes). Because
 * every item shares the same speed, two items on the same track can never catch
 * up to each other — we only need to guarantee a safe gap when a new item
 * enters. An item is placed on the first track whose last item's tail has
 * already cleared the right edge by [trackSafeGapDp]. If no track is free the
 * item waits in a backlog queue (capped at [maxBacklog]) and is retried every
 * frame, so nothing scheduled is dropped while space exists.
 *
 * Usage
 * -----
 *   // XML: place over your content, match_parent, clickable=false
 *   <...DanmakuView android:id="@+id/danmaku" .../>
 *
 *   // Code: feed comments from any source (self / IM / mock)
 *   danmakuView.add("hello")                 // default white text
 *   danmakuView.add("hi", Color.YELLOW)      // tinted, e.g. to mark the self user
 *   danmakuView.addGift("Me sent Rose", icon) // icon + text, for gift notices
 *
 * Optional customisation (all have sensible defaults):
 *   view.speedDpPerSec  = 120f
 *   view.textSizeSp     = 16f
 *   view.trackHeightDp  = 32f
 */
class DanmakuView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    // --- Public configuration -------------------------------------------------

    /** Horizontal scroll speed, in dp per second. */
    var speedDpPerSec: Float = 120f

    /** Text size, in sp. */
    var textSizeSp: Float = 16f

    /** Height of a single track (lane), in dp. Determines how many lanes fit. */
    var trackHeightDp: Float = 32f

    /** Minimum horizontal gap left behind an item's tail before its track is
     *  considered free for a new item, in dp. */
    var trackSafeGapDp: Float = 48f

    /** Default text colour when [add] is called without an explicit colour. */
    var defaultColor: Int = Color.WHITE

    /** Size of a leading icon (for rich danmaku such as gift notices), in dp. */
    var leadingIconSizeDp: Float = 20f

    /** Gap between a leading icon and the following text, in dp. */
    var leadingIconGapDp: Float = 4f

    /** Max number of waiting (not-yet-shown) items. Beyond this the oldest
     *  pending item is dropped so the freshest content wins and memory stays
     *  bounded. On-screen items are never affected. */
    var maxBacklog: Int = 50

    // --- Internal state -------------------------------------------------------

    private class Item(
        val text: String,
        val textWidth: Float,
        val color: Int,
        val track: Int,
        val bornAt: Long,
        val leadingIcon: Drawable? = null,
        val leadingIconSize: Float = 0f,
        val leadingIconGap: Float = 0f,
    ) {
        val contentWidth: Float = if (leadingIcon == null) {
            textWidth
        } else {
            leadingIconSize + leadingIconGap + textWidth
        }
    }

    /** Active (on-screen or entering) items, oldest first. */
    private val active = ArrayList<Item>()

    /** The most recently placed item on each track (index = track), or null if
     *  the track is empty. Lets placement run in O(tracks) without scanning
     *  [active]. Resized in [onSizeChanged]. */
    private var trackTails = arrayOfNulls<Item>(0)

    /** Items waiting for a free track. */
    private val backlog = ArrayDeque<Pending>()

    private class Pending(
        val text: String,
        val color: Int,
        val leadingIcon: Drawable? = null,
        val leadingIconSize: Float = 0f,
        val leadingIconGap: Float = 0f,
    )

    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        style = Paint.Style.FILL
        color = Color.WHITE
    }

    private val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        style = Paint.Style.STROKE
        color = STROKE_COLOR
    }

    /** Number of horizontal lanes; derived from view height in [onSizeChanged]. */
    private var trackCount = 0

    // --- API ------------------------------------------------------------------

    /** Enqueue a danmaku with the default colour. */
    fun add(text: String) = add(text, defaultColor)

    /**
     * Enqueue a danmaku in [color]. The item is placed on a free track now if
     * possible, otherwise it waits in the backlog (capped at [maxBacklog]).
     * Safe to call from the UI thread.
     */
    fun add(text: String, color: Int) {
        addInternal(text, color)
    }

    /**
     * Enqueue a gift danmaku with a leading [icon]. The icon is cloned so each
     * active item keeps its own bounds / alpha state.
     */
    fun addGift(text: String, icon: Drawable, color: Int = defaultColor) {
        addInternal(
            text = text,
            color = color,
            leadingIcon = cloneDrawable(icon),
            leadingIconSize = dp(leadingIconSizeDp),
            leadingIconGap = dp(leadingIconGapDp),
        )
    }

    private fun addInternal(
        text: String,
        color: Int,
        leadingIcon: Drawable? = null,
        leadingIconSize: Float = 0f,
        leadingIconGap: Float = 0f,
    ) {
        val trimmed = text.trim()
        if (trimmed.isEmpty()) return
        val pending = Pending(
            text = trimmed,
            color = color,
            leadingIcon = leadingIcon,
            leadingIconSize = leadingIconSize,
            leadingIconGap = leadingIconGap,
        )

        // If the view isn't laid out yet, hold everything in the backlog; it
        // will be drained once we have a size.
        if (width == 0 || trackCount == 0) {
            enqueue(pending)
            invalidate()
            return
        }

        val item = tryPlace(pending)
        if (item == null) {
            enqueue(pending)
        }
        invalidate()
    }

    /** Remove every on-screen and pending danmaku. */
    fun clear() {
        active.clear()
        backlog.clear()
        trackTails.fill(null)
        invalidate()
    }

    // --- Placement ------------------------------------------------------------

    private fun enqueue(p: Pending) {
        while (backlog.size >= maxBacklog) backlog.removeFirst()
        backlog.addLast(p)
    }

    /**
     * Try to put a new item on the first free track. A track is free when its
     * most recent item's tail (right edge) has cleared `width - safeGap`, so the
     * new item won't visually overlap or collide with it. Returns the placed
     * item, or null when no track is available right now.
     */
    private fun tryPlace(pending: Pending): Item? {
        val now = SystemClock.uptimeMillis()
        val textWidth = fillPaint.measureText(pending.text)
        val safeGap = dp(trackSafeGapDp)

        for (track in 0 until trackCount) {
            val last = trackTails[track]
            if (last != null) {
                val lastTailX = currentX(last, now) + last.contentWidth
                if (lastTailX > width - safeGap) continue // too close, skip lane
            }
            val item = Item(
                text = pending.text,
                textWidth = textWidth,
                color = pending.color,
                track = track,
                bornAt = now,
                leadingIcon = pending.leadingIcon,
                leadingIconSize = pending.leadingIconSize,
                leadingIconGap = pending.leadingIconGap,
            )
            active.add(item)
            trackTails[track] = item
            return item
        }
        return null
    }

    /** Current left-edge x of [item] at [now], moving right→left. */
    private fun currentX(item: Item, now: Long): Float {
        val speedPx = dp(speedDpPerSec)
        val age = (now - item.bornAt) / 1000f
        return width - speedPx * age
    }

    // --- Drawing --------------------------------------------------------------

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        applyPaintSizes()
        trackCount = if (trackHeightDp <= 0f) 0 else (h / dp(trackHeightDp)).toInt().coerceAtLeast(1)
        // Drop any items whose lane no longer exists, then resize the tail map.
        if (trackTails.size != trackCount) {
            active.retainAll { it.track < trackCount }
            trackTails = arrayOfNulls(trackCount)
        }
    }

    private fun applyPaintSizes() {
        val px = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_SP, textSizeSp, resources.displayMetrics,
        )
        fillPaint.textSize = px
        strokePaint.textSize = px
        strokePaint.strokeWidth = dp(2f)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val now = SystemClock.uptimeMillis()

        // Drain the backlog onto any tracks that have freed up this frame.
        drainBacklog()

        // Draw + cull. An item is done once its tail leaves the left edge.
        val trackH = dp(trackHeightDp)
        val baselineOffset = (trackH - (fillPaint.descent() + fillPaint.ascent())) / 2f

        val it = active.iterator()
        while (it.hasNext()) {
            val item = it.next()
            val x = currentX(item, now)
            if (x + item.contentWidth < 0f) {
                it.remove()
                continue
            }
            val y = item.track * trackH + baselineOffset
            var textX = x
            if (item.leadingIcon != null) {
                val iconTop = item.track * trackH + (trackH - item.leadingIconSize) / 2f
                val iconRight = x + item.leadingIconSize
                item.leadingIcon.alpha = 255
                item.leadingIcon.setBounds(
                    x.toInt(),
                    iconTop.toInt(),
                    iconRight.toInt(),
                    (iconTop + item.leadingIconSize).toInt(),
                )
                item.leadingIcon.draw(canvas)
                textX = iconRight + item.leadingIconGap
            }
            canvas.drawText(item.text, textX, y, strokePaint)
            fillPaint.color = item.color
            canvas.drawText(item.text, textX, y, fillPaint)
        }

        if (active.isNotEmpty() || backlog.isNotEmpty()) {
            postInvalidateOnAnimation()
        }
    }

    private fun drainBacklog() {
        if (backlog.isEmpty() || trackCount == 0 || width == 0) return
        // Try to place as many waiting items as there are free tracks this
        // frame. Stop as soon as a placement fails to preserve FIFO order.
        var guard = trackCount
        while (backlog.isNotEmpty() && guard-- > 0) {
            val p = backlog.first()
            val placed = tryPlace(p)
            if (placed == null) break
            backlog.removeFirst()
        }
    }

    // --- Helpers --------------------------------------------------------------

    private fun dp(value: Float): Float = value * resources.displayMetrics.density

    private fun cloneDrawable(drawable: Drawable): Drawable {
        return drawable.constantState?.newDrawable(resources)?.mutate() ?: drawable.mutate()
    }

    private companion object {
        /** Semi-transparent black outline behind every item for legibility on
         *  any video background. */
        const val STROKE_COLOR = 0x99000000.toInt()
    }
}
