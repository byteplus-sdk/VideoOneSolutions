/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

@FunctionalInterface
public interface CommentDialogOpenHelper {
    void showCommentDialog(@NonNull FragmentActivity activity, @NonNull String vid);
}
