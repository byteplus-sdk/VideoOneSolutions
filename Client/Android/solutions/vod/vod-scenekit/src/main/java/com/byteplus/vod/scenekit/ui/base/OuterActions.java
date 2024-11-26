// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.base;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.CommentDialogOpenHelper;

public class OuterActions {
    @Nullable
    private static CommentDialogOpenHelper sHelper;

    public static void showCommentDialog(@NonNull FragmentActivity activity, @NonNull String vid) {
        showCommentDialog(activity, vid, CommentDialogOpenHelper.Style.Portrait);
    }

    public static void showCommentDialogL(@NonNull FragmentActivity activity, @NonNull String vid) {
        showCommentDialog(activity, vid, CommentDialogOpenHelper.Style.Landscape);
    }

    private static void showCommentDialog(@NonNull FragmentActivity activity, @NonNull String vid, @NonNull CommentDialogOpenHelper.Style style) {
        CommentDialogOpenHelper helper = sHelper;
        if (helper != null) {
            helper.show(activity, vid, style);
        }
    }

    public static void setup(@Nullable CommentDialogOpenHelper helper) {
        sHelper = helper;
    }
}
