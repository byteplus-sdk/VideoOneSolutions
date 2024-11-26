// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.voddemo.utils;

import android.os.Bundle;

import androidx.fragment.app.DialogFragment;

import com.byteplus.vod.scenekit.ui.base.OuterActions;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.CommentDialogOpenHelper;
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogFragment;
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogLFragment;

public final class OuterActionsHelper {

    private static final CommentDialogOpenHelper sHelper = (activity, vid, style) -> {
        DialogFragment fragment;
        switch (style) {
            case Portrait:
                fragment = new CommentDialogFragment();
                break;
            case Landscape:
                fragment = new CommentDialogLFragment();
                break;

            default:
                throw new IllegalArgumentException("Unknown style: " + style);
        }

        Bundle args = new Bundle();
        args.putString("vid", vid);
        fragment.setArguments(args);

        fragment.show(activity.getSupportFragmentManager(), "comment-" + vid);
    };

    public static void setup() {
        OuterActions.setup(sHelper);
    }
}
