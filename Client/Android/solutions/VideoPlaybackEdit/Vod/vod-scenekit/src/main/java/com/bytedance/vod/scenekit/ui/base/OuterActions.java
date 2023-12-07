/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.bytedance.vod.scenekit.ui.base;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer.CommentDialogOpenHelper;

public class OuterActions {
    @Nullable
    public static CommentDialogOpenHelper commentDialogOpenHelper;

    @Nullable
    public static CommentDialogOpenHelper commentDialogOpenHelperL;

    public static void showCommentDialog(FragmentActivity activity, String vid) {
        CommentDialogOpenHelper helper = commentDialogOpenHelper;
        if (helper != null) {
            helper.showCommentDialog(activity, vid);
        }
    }

    public static void showCommentDialogL(FragmentActivity activity, String vid) {
        CommentDialogOpenHelper helper = commentDialogOpenHelperL;
        if (helper != null) {
            helper.showCommentDialog(activity, vid);
        }
    }
}
