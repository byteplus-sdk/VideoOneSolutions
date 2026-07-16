// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.widget

import android.content.Context
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan

/**
 * Composes a structured live-comment ([VipBadgeImageSpan] + user name +
 * content) into a single [SpannableStringBuilder] suitable for a TextView.
 *
 * Drop-in usage: callers pass plain data and colors; this object handles
 * span boundaries and the inline separators. Badge styling itself is
 * delegated to [VipBadgeFactory] so customizing the badge does not require
 * touching this file.
 *
 * Layout (per Figma node 10877:122492):
 *   [badge]  user_name  content
 * Segments are joined by a plain space — no colon between name and content.
 */
object CommentTextBuilder {

    private const val NAME_CONTENT_SEPARATOR = " "

    /**
     * @param context       used by [VipBadgeFactory] for dp/sp conversion
     * @param vipLevel      null hides the badge; non-null inserts a badge span
     * @param userName      display name (no trailing punctuation needed)
     * @param userNameColor name color
     * @param content       comment body
     * @param contentColor  body color
     */
    fun build(
        context: Context,
        vipLevel: Int?,
        userName: String,
        userNameColor: Int,
        content: String,
        contentColor: Int,
    ): SpannableStringBuilder {
        val builder = SpannableStringBuilder()

        if (vipLevel != null) {
            // One-character placeholder: ReplacementSpan paints over it entirely.
            val placeholder = "■"
            val start = builder.length
            builder.append(placeholder)
            builder.setSpan(
                VipBadgeFactory.create(context, vipLevel),
                start,
                start + placeholder.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
            )
        }

        val nameStart = builder.length
        builder.append(userName).append(NAME_CONTENT_SEPARATOR)
        builder.setSpan(
            ForegroundColorSpan(userNameColor),
            nameStart,
            builder.length,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
        )

        val contentStart = builder.length
        builder.append(content)
        builder.setSpan(
            ForegroundColorSpan(contentColor),
            contentStart,
            builder.length,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
        )

        return builder
    }
}
