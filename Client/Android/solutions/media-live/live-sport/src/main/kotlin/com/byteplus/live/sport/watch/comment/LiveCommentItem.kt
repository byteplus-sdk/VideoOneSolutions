// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.comment

/**
 * Data model for a single live comment. Local-mock only in this version
 * (no IM protocol wiring yet), so we keep the field set minimal.
 *
 * @param vipLevel null hides the VIP badge
 */
data class LiveCommentItem(
    val vipLevel: Int?,
    val userName: String,
    val content: String,
)
