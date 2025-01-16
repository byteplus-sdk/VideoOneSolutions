// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.view

import android.content.Context
import android.content.res.TypedArray
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.util.AttributeSet
import android.view.View
import com.byteplus.vodlive.R
import com.byteplus.vodlive.utils.ViewUtils
import kotlin.math.abs

class LiveCircleView
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    private var cx: Float = 0F
    private var cy: Float = 0F

    private var mStrokeWidth = 0F
    private var mWaveStrokeWidth = 0F

    private var mRadius: Float = 0F
    private var mWaveRadius = 0F

    private var mWaveWidth = 0F

    init {
        var a: TypedArray? = null
        try {
            a = context.obtainStyledAttributes(attrs, R.styleable.LiveCircleView)

            mStrokeWidth =
                a.getDimension(
                    R.styleable.LiveCircleView_live_strokeWidth,
                    ViewUtils.dip2Px(context, 1.5F)
                )

            mRadius = a.getDimension(
                R.styleable.LiveCircleView_live_radius,
                0F
            )

            mWaveWidth = a.getDimension(
                R.styleable.LiveCircleView_live_waveWidth,
                ViewUtils.dip2Px(context, 3F)
            )

            mWaveRadius = mRadius
        } finally {
            a?.recycle()
        }
    }

    private val mPaint by lazy {
        Paint().apply {
            isAntiAlias = true
            isDither = true
            style = Paint.Style.STROKE
            strokeWidth = mStrokeWidth

            shader = LinearGradient(
                0F, 0F,
                100F, 100F,
                Color.parseColor("#FF1764"),
                Color.parseColor("#ED3495"),
                Shader.TileMode.MIRROR
            )
        }
    }

    private val mCirclePaint by lazy {
        Paint(mPaint)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)

        cx = measuredWidth.toFloat() / 2.0F
        cy = measuredHeight.toFloat() / 2.0F
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.drawCircle(cx, cy, mRadius, mPaint)
        canvas.drawCircle(cx, cy, mWaveRadius, mCirclePaint)
    }

    fun setFraction(fraction: Float) {
        val circleRadius = (mRadius + mWaveWidth * fraction) * 1.08F
        val circleStrokeWidth = mStrokeWidth * (1 - fraction) * 1.20F
        if (abs(circleRadius - mWaveRadius) < 0.5F
            && abs(mWaveStrokeWidth - circleStrokeWidth) < 0.5F
        ) {
            return
        }

        mWaveRadius = circleRadius
        mWaveStrokeWidth = circleStrokeWidth

        val alphaFraction = if (fraction < 0.5) fraction else abs(fraction - 1)

        mPaint.alpha = (255 * (alphaFraction + 0.5)).toInt()

        mCirclePaint.strokeWidth = circleStrokeWidth
        mCirclePaint.alpha = (255 * alphaFraction).toInt()

        postInvalidate()
    }
}