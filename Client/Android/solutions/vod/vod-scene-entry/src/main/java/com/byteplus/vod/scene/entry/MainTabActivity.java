// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scene.entry;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;

import androidx.fragment.app.DialogFragment;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.byteplus.vod.scenekit.ext.IComment;
import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.utils.UIUtils;
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogFragment;
import com.byteplus.voddemo.ui.video.scene.comment.CommentDialogLFragment;

import java.util.Objects;

public class MainTabActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        UIUtils.setSystemBarTheme(
                this,
                Color.TRANSPARENT,
                true,
                true,
                Color.TRANSPARENT,
                true,
                true
        );

        setContentView(R.layout.vevod_main_tab_activity);

        IntentFilter filter = new IntentFilter();
        filter.addAction(IComment.ACTION_SHOW_PORTRAIT);
        filter.addAction(IComment.ACTION_SHOW_LANDSCAPE);
        LocalBroadcastManager.getInstance(this).registerReceiver(
                commendDialogHandler, filter);
    }

    @Override
    protected void onDestroy() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(
                commendDialogHandler);
        super.onDestroy();
    }

    private final BroadcastReceiver commendDialogHandler = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            DialogFragment fragment = switch (Objects.requireNonNull(intent.getAction())) {
                case IComment.ACTION_SHOW_PORTRAIT -> new CommentDialogFragment();
                case IComment.ACTION_SHOW_LANDSCAPE -> new CommentDialogLFragment();
                default ->
                        throw new IllegalStateException("Unexpected value: " + intent.getAction());
            };

            fragment.setArguments(Objects.requireNonNull(intent.getExtras()));
            fragment.show(getSupportFragmentManager(), "comment-dialog");
        }
    };
}
