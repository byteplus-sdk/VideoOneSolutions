package com.byteplus.vodlive.utils

import android.content.Context

object ViewUtils {
    fun dip2Px(context: Context, dipValue: Float): Float {
        val scale: Float = context.resources.displayMetrics.density
        return dipValue * scale + 0.5F
    }
}