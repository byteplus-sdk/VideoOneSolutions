package com.byteplus.vodlive.utils

import android.util.Log
import androidx.annotation.CallSuper
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ViewHolder
import androidx.viewpager2.widget.ViewPager2

private const val TAG = "OnPageChangeCallbackExt"

open class OnPageChangeCallbackExt : ViewPager2.OnPageChangeCallback() {
    private var mCurrentScrollState: Int = ViewPager2.SCROLL_STATE_IDLE
    private var mCurrentSelectedPosition: Int = RecyclerView.NO_POSITION

    val currentPosition: Int
        get() = mCurrentSelectedPosition

    /**
     * 标记在用户拖动过程中可以被用户看到的位置
     */
    private var mLastWinPosition: Int = RecyclerView.NO_POSITION

    /**
     * 对应的位置的 ViewHolder 即将进入或离开屏幕显示区域
     *
     * @param oldPosition 即将离开的位置
     * @param newPosition 即将进入的位置
     */
    open fun onPositionVisibilityChanged(oldPosition: Int, newPosition: Int) {
    }

    /**
     * {@inheritDoc}
     */
    @CallSuper
    override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
        if (mCurrentScrollState == ViewPager2.SCROLL_STATE_DRAGGING) {
            val winPosition = if (mCurrentSelectedPosition == position) {
                position + 1
            } else {
                position
            }

            if (winPosition != mLastWinPosition) {
                Log.i(TAG, "onPageScrolled: winPosition=$winPosition")
                val lastWinPosition = mLastWinPosition
                mLastWinPosition = winPosition

                onPositionVisibilityChanged(lastWinPosition, winPosition)
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    @CallSuper
    override fun onPageSelected(position: Int) {
        Log.d(TAG, "onPageSelected: $position")

        mCurrentSelectedPosition = position
        mLastWinPosition = RecyclerView.NO_POSITION
    }

    /**
     * {@inheritDoc}
     */
    @CallSuper
    override fun onPageScrollStateChanged(state: Int) {
        Log.d(TAG, "onPageScrollStateChanged: ${state.str()}")
        mCurrentScrollState = state

        val lastWinPosition = mLastWinPosition
        if (state == ViewPager2.SCROLL_STATE_IDLE
            && lastWinPosition != RecyclerView.NO_POSITION
            && lastWinPosition != mCurrentSelectedPosition
        ) {
            // Position not changed, should clear onWindowPositionChanged
            Log.d(TAG, "onPageScrollStateChanged: clear lastWinPosition: $lastWinPosition")
            onPositionVisibilityChanged(lastWinPosition, RecyclerView.NO_POSITION)
            mLastWinPosition = RecyclerView.NO_POSITION
        }
    }

    private fun Int.str(): String = when (this) {
        ViewPager2.SCROLL_STATE_IDLE -> "SCROLL_STATE_IDLE"
        ViewPager2.SCROLL_STATE_DRAGGING -> "SCROLL_STATE_DRAGGING"
        ViewPager2.SCROLL_STATE_SETTLING -> "SCROLL_STATE_SETTLING"
        else -> "UNKNOWN"
    }
}

fun ViewPager2.get(position: Int): ViewHolder? {
    if (position == RecyclerView.NO_POSITION) return null
    val recycler = getChildAt(0) as? RecyclerView ?: return null
    return recycler.findViewHolderForLayoutPosition(position)
}

inline fun <reified T> ViewPager2.findViewHolderForLayoutPosition(position: Int): T? {
    return this.get(position) as? T
}