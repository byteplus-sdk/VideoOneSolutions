// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.voddemo.utils;

import android.os.Bundle;

import androidx.fragment.app.DialogFragment;

import com.byteplus.vod.scenekit.ui.base.OuterActions;
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogFragment;
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogLFragment;

public class OuterActionsHelper {
    public static void setup() {
        OuterActions.commentDialogOpenHelper = (activity, vid) -> {
            DialogFragment fragment = new CommentDialogFragment();
            Bundle args = new Bundle();
            args.putString("vid", vid);
            fragment.setArguments(args);

            fragment.show(activity.getSupportFragmentManager(), "comment-" + vid);
        };

        OuterActions.commentDialogOpenHelperL = (activity, vid) -> {
            DialogFragment fragment = new CommentDialogLFragment();
            Bundle args = new Bundle();
            args.putString("vid", vid);
            fragment.setArguments(args);

            fragment.show(activity.getSupportFragmentManager(), "comment-" + vid);
        };
    }
}
