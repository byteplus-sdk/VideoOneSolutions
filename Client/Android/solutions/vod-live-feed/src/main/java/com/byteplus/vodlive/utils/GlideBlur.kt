// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.utils

import android.graphics.drawable.Drawable
import com.bumptech.glide.RequestBuilder
import com.bumptech.glide.request.RequestOptions
import jp.wasabeef.glide.transformations.BlurTransformation

private const val ENABLE_BLUE = false

object GlideBlur {
    fun RequestBuilder<Drawable>.blur(): RequestBuilder<Drawable> = if (ENABLE_BLUE) {
        apply(RequestOptions.bitmapTransform(BlurTransformation(24, 8)))
    } else {
        this
    }
}