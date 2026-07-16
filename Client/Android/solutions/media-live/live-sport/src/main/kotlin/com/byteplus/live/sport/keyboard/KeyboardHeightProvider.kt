// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.keyboard

import android.app.Activity
import android.graphics.Rect
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewTreeObserver.OnGlobalLayoutListener
import android.view.WindowManager.LayoutParams
import android.widget.PopupWindow

/**
 * Tracks the soft keyboard (IME) and reports how far an input view should
 * translate up so that it sits flush against the IME's top edge.
 *
 * ## When to use
 *
 * Use this whenever an Activity needs the input bar (and any sibling
 * content) to follow the IME without letting the system resize / pan the
 * whole window. Typical scenarios: a video player or live-stream page
 * where panning the viewport during typing is unacceptable.
 *
 * For pages where the standard `adjustResize` behaviour is fine — i.e. you
 * are happy for the system to push your content up — you do NOT need this
 * class.
 *
 * ## Required environment
 *
 * 1. Declare the host Activity with **`windowSoftInputMode="adjustNothing"`**
 *    in `AndroidManifest.xml`:
 *
 *    ```xml
 *    <activity
 *        android:name=".MyActivity"
 *        android:windowSoftInputMode="adjustNothing" />
 *    ```
 *
 *    Without this, the system also resizes the window and your view will be
 *    moved twice (once by the system, once by this provider's callback).
 *
 * 2. The host Activity must have a non-null content view by the time
 *    [init] is called (usually any time after `setContentView`).
 *
 * 3. minSdk 24+. The class internally uses [WindowInsets.Type.ime] on
 *    Android 11+ and a PopupWindow probe on 11-; both paths are guarded.
 *
 * ## Usage
 *
 * ```kotlin
 * class MyActivity : AppCompatActivity() {
 *
 *     private var keyboardProvider: KeyboardHeightProvider? = null
 *     private lateinit var inputBar: View
 *     private lateinit var chatList: View
 *
 *     override fun onCreate(savedInstanceState: Bundle?) {
 *         super.onCreate(savedInstanceState)
 *         setContentView(R.layout.activity_my)
 *         inputBar = findViewById(R.id.input_bar)
 *         chatList = findViewById(R.id.chat_list)
 *
 *         keyboardProvider = KeyboardHeightProvider(this, inputBar)
 *             .setHeightListener { translateY ->
 *                 // Move both the input bar and any sibling that should
 *                 // ride with it. Player / header should stay put.
 *                 inputBar.translationY = -translateY.toFloat()
 *                 chatList.translationY = -translateY.toFloat()
 *             }
 *             .init()
 *     }
 *
 *     override fun onDestroy() {
 *         keyboardProvider?.destroySelf()
 *         keyboardProvider = null
 *         super.onDestroy()
 *     }
 * }
 * ```
 *
 * ## What [contentView] should be
 *
 * Pass the **view you want to land flush against the IME's top edge**.
 * Almost always that is the bottom input bar itself. The provider measures
 * its on-screen bottom Y and computes how many pixels it must move up.
 *
 * - Do NOT pass the screen root under EdgeToEdge — the root extends below
 *   the navigation bar and the gap math will overshoot.
 * - It is fine to translate the [contentView] (or its ancestors) inside
 *   [HeightListener.onHeightChanged]: the provider compensates for any
 *   `translationY` already applied to the view chain.
 *
 * ## Lifecycle notes
 *
 * - Call [init] once after `setContentView`. It schedules a transparent
 *   probe PopupWindow to attach 300 ms later (immediate attach against a
 *   freshly created Activity is known to throw `BadTokenException`).
 * - [setHeightListener] can be called any time before / after [init];
 *   ordering does not matter.
 * - **Always call [destroySelf] in `onDestroy`**. It dismisses the probe
 *   PopupWindow, removes the inset listener and clears the height listener.
 *   Forgetting this leaks the Activity.
 *
 * ## Threading
 *
 * Construct, configure and tear down on the main thread. Callbacks are
 * delivered on the main thread.
 *
 * @param activity     host Activity. Used to read window / decor state.
 * @param contentView  the input view that should sit flush against the IME
 *                     top edge — typically the bottom input bar.
 */
class KeyboardHeightProvider(
    private val activity: Activity,
    private val contentView: View,
) : PopupWindow(activity), OnGlobalLayoutListener {

    /** Receives the translate distance in pixels (>= 0). */
    fun interface HeightListener {
        fun onHeightChanged(height: Int)
    }

    /** Internal probe view used by both API paths. */
    private val rootView: View = View(activity)
    private var decorView: View? = null
    private var listener: HeightListener? = null

    private val keyboardHeightUtilAbove11 = KeyboardHeightUtil(activity)
    private val keyboardVisibilityListener =
        KeyboardHeightUtil.OnKeyboardVisibilityListener { visible, height ->
            Log.d(TAG, "above11 visible=$visible imeHeight=$height")
            val translateY = if (visible) calculateTranslateYAbove11(height) else 0
            listener?.onHeightChanged(translateY)
        }

    private val showRunnable = Runnable {
        val decor = decorView ?: return@Runnable
        if (activity.isFinishing || activity.isDestroyed) return@Runnable
        showAtLocation(decor, Gravity.NO_GRAVITY, 0, 0)
        Log.d(TAG, "showAtLocation")
    }

    init {
        setContentView(rootView)
        rootView.viewTreeObserver.addOnGlobalLayoutListener(this)
        setBackgroundDrawable(ColorDrawable(0))
        // width=0 so the popup never intercepts touch events — it exists
        // purely as a layout probe for the 11- path.
        width = 0
        height = LayoutParams.MATCH_PARENT
        softInputMode = LayoutParams.SOFT_INPUT_ADJUST_RESIZE
        inputMethodMode = INPUT_METHOD_NEEDED

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            keyboardHeightUtilAbove11.register(keyboardVisibilityListener)
        }
    }

    /**
     * Starts monitoring. Must be called once per instance, after the host
     * Activity's content view has been set. Safe to call only on the main
     * thread.
     */
    fun init(): KeyboardHeightProvider {
        if (!isShowing) {
            decorView = activity.window.decorView
            // Drop any previously scheduled show before queuing a new one,
            // in case init() is called more than once within SHOW_DELAY_MS.
            decorView?.removeCallbacks(showRunnable)
            // Delay slightly: showing the popup against a freshly attached
            // Activity is known to throw BadTokenException.
            decorView?.postDelayed(showRunnable, SHOW_DELAY_MS)
        }
        return this
    }

    /**
     * Registers (or replaces) the listener that receives translate
     * distances. The listener will be invoked whenever the IME visibility
     * or height changes; the value is always >= 0.
     */
    fun setHeightListener(listener: HeightListener): KeyboardHeightProvider {
        this.listener = listener
        return this
    }

    /**
     * Stops monitoring and releases all resources. Must be called from the
     * host's `onDestroy`. Calling it more than once is a no-op.
     */
    fun destroySelf() {
        decorView?.removeCallbacks(showRunnable)
        listener = null
        keyboardHeightUtilAbove11.unregister()
        dismiss()
    }

    /**
     * 11- path callback. 11+ skips this listener and reports through
     * [keyboardVisibilityListener] instead.
     */
    override fun onGlobalLayout() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) return
        val translateY = calculateTranslateYBelow11()
        listener?.onHeightChanged(translateY)
    }

    /**
     * 11- math: under adjustNothing the host window's decorView is never
     * resized, but our probe popup IS (it carries softInputMode=ADJUST_RESIZE).
     * The popup's visible-rect bottom drops to the IME's top edge when the
     * IME opens.
     *
     *   contentBottom: bottom Y of [contentView] in screen coordinates.
     *   realBottom:    popup visible-rect bottom — equals the IME top edge
     *                  when the IME is open, otherwise equals the popup's
     *                  natural bottom (typically the nav bar top edge).
     *
     * Translate distance = contentBottom - realBottom, clamped at 0.
     *
     * Note we do NOT use the popup's largest observed visible bottom as the
     * "no-IME baseline": under EdgeToEdge the popup's visible rect never
     * extends below the navigation bar, while the host content view does.
     * Using contentBottom directly keeps both sides on the same coordinate
     * system regardless of EdgeToEdge.
     */
    private fun calculateTranslateYBelow11(): Int {
        val rect = Rect()
        rootView.rootView.getWindowVisibleDisplayFrame(rect)
        val realBottom = rect.bottom
        val contentBottom = getViewBottomInScreen(contentView)
        val result = (contentBottom - realBottom).coerceAtLeast(0)
        Log.d(
            TAG,
            "below11 translateY=$result realBottom=$realBottom contentBottom=$contentBottom"
        )
        return result
    }

    /**
     * 11+ math:
     *   imeHeight is the IME top edge measured from the screen bottom
     *   (provided by [WindowInsets.Type.ime]).
     *   roomViewBottom is the gap between [contentView] bottom and the
     *   real screen bottom. The view needs to move up by
     *   max(0, imeHeight - roomViewBottom).
     *
     * Uses [android.util.DisplayMetrics.heightPixels] for the screen
     * height: when the probe popup is ADJUST_RESIZE'd by the IME, its own
     * root height shrinks by the IME amount and would mis-compute the gap
     * — especially visible when the system has a navigation bar.
     */
    private fun calculateTranslateYAbove11(imeHeight: Int): Int {
        if (imeHeight <= 0) return 0
        val screenHeight = activity.resources.displayMetrics.heightPixels
        val contentBottom = getViewBottomInScreen(contentView)
        val roomViewBottom = screenHeight - contentBottom
        val result = (imeHeight - roomViewBottom).coerceAtLeast(0)
        Log.d(
            TAG,
            "above11 translateY=$result imeHeight=$imeHeight " +
                "screenHeight=$screenHeight contentBottom=$contentBottom " +
                "roomViewBottom=$roomViewBottom"
        )
        return result
    }

    /**
     * Returns the on-screen bottom Y of [view], with any `translationY`
     * applied to the view or its ancestors **subtracted out**.
     *
     * Why: the listener typically translates the very view we measure
     * here. [View.getLocationOnScreen] returns the rendered position which
     * already includes translation. Without compensation the second IME
     * tick would read the post-translate position and miscompute the gap,
     * producing a flicker.
     */
    private fun getViewBottomInScreen(view: View): Int {
        val pos = IntArray(2)
        view.getLocationOnScreen(pos)
        var translateSum = 0f
        var current: View? = view
        while (current != null) {
            translateSum += current.translationY
            current = current.parent as? View
        }
        return pos[1] + view.height - translateSum.toInt()
    }

    companion object {
        private const val TAG = "KeyboardHeightProvider"
        private const val SHOW_DELAY_MS = 300L
    }
}
