// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.main;

import android.graphics.Color;
import android.os.Bundle;

import androidx.fragment.app.DialogFragment;

import com.bytedance.vod.scenekit.ui.base.BaseActivity;
import com.bytedance.vod.scenekit.ui.base.OuterActions;
import com.bytedance.vod.scenekit.utils.UIUtils;
import com.bytedance.voddemo.impl.R;
import com.bytedance.voddemo.ui.video.scene.comment.CommentDialogFragment;
import com.bytedance.voddemo.ui.video.scene.comment.CommentDialogLFragment;

public class MainTabActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        UIUtils.setSystemBarTheme(
                this,
                Color.TRANSPARENT,
                true,
                true,
                Color.WHITE,
                true,
                false
        );

        setContentView(R.layout.vevod_main_tab_activity);
        setupOuterActions();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        clearOuterActions();
    }

    private void setupOuterActions() {
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

    private void clearOuterActions() {
        OuterActions.commentDialogOpenHelper = null;
        OuterActions.commentDialogOpenHelperL = null;
    }
}
