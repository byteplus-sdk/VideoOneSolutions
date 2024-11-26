package com.byteplus.vodlive.view.recycler

import android.content.Context
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.PagerSnapHelper
import androidx.recyclerview.widget.RecyclerView

private const val TAG: String = "PagerLayoutManager"

class PagerLayoutManager(
    context: Context, @RecyclerView.Orientation orientation: Int = RecyclerView.VERTICAL
) : LinearLayoutManager(context, orientation, false) {

    var onViewPagerListener: OnViewPagerListener? = null

    private val mPagerSnapHelper = PagerSnapHelper()

    private var mDrift = 0

    override fun onAttachedToWindow(view: RecyclerView) {
        super.onAttachedToWindow(view)
        mPagerSnapHelper.attachToRecyclerView(view)
        view.addOnChildAttachStateChangeListener(mChildAttachStateChangeListener)
        view.addOnScrollListener(mScrollListener)
    }

    override fun scrollVerticallyBy(
        dy: Int, recycler: RecyclerView.Recycler, state: RecyclerView.State
    ): Int {
        this.mDrift = dy
        return super.scrollVerticallyBy(dy, recycler, state)
    }

    override fun scrollHorizontallyBy(
        dx: Int, recycler: RecyclerView.Recycler, state: RecyclerView.State
    ): Int {
        this.mDrift = dx
        return super.scrollHorizontallyBy(dx, recycler, state)
    }

    private val mChildAttachStateChangeListener: RecyclerView.OnChildAttachStateChangeListener =
        object : RecyclerView.OnChildAttachStateChangeListener {
            override fun onChildViewAttachedToWindow(view: View) {
                var isNext = false
                if (mDrift >= 0) {
                    isNext = true
                }
                Log.d(
                    TAG,
                    "onChildViewAttachedToWindow childCount=$childCount, position=${getPosition(view)}, isNext=$isNext"
                )
                if (childCount == 1) {
                    onViewPagerListener?.onInitComplete()
                } else if (childCount > 1) {
                    onViewPagerListener?.onPageDisplay(isNext, getPosition(view))
                }
            }

            override fun onChildViewDetachedFromWindow(view: View) {
                val isNext = mDrift >= 0
                Log.d(
                    TAG,
                    "onChildViewDetachedFromWindow, position=${getPosition(view)}, isNext=$isNext"
                )
                onViewPagerListener?.onPageRelease(isNext, getPosition(view))
            }
        }

    private val mScrollListener: RecyclerView.OnScrollListener =
        object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                when (newState) {
                    RecyclerView.SCROLL_STATE_IDLE -> {
                        val position = findSnapViewPosition()
                        Log.d(
                            TAG,
                            "onScrollStateChanged->SCROLL_STATE_IDLE, position=$position, childCount=$childCount"
                        )
                        if (childCount == 1) {
                            onViewPagerListener?.onPageSelected(
                                position, position == itemCount - 1
                            )
                        }
                    }

                    RecyclerView.SCROLL_STATE_DRAGGING -> {
                        val position = findSnapViewPosition()
                        Log.d(
                            TAG, "onScrollStateChanged->SCROLL_STATE_DRAGGING, position =$position"
                        )
                    }

                    RecyclerView.SCROLL_STATE_SETTLING -> {
                        val position = findSnapViewPosition()
                        Log.d(
                            TAG, "onScrollStateChanged->SCROLL_STATE_SETTLING, position =$position"
                        )
                    }
                }
            }

            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
            }
        }

    private fun findSnapViewPosition(): Int {
        val view = mPagerSnapHelper.findSnapView(this) ?: return RecyclerView.NO_POSITION
        return getPosition(view)
    }
}

interface OnViewPagerListener {
    fun onInitComplete()

    fun onPageDisplay(isNext: Boolean, position: Int)

    fun onPageRelease(isNext: Boolean, position: Int)

    fun onPageSelected(position: Int, isBottom: Boolean)
}