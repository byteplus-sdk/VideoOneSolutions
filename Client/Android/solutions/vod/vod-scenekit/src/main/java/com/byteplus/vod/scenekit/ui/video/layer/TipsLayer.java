// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.utils.UIUtils;


public class TipsLayer extends AnimateLayer {

    @Override
    public String tag() {
        return "tips";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        TextView textView = new TextView(parent.getContext());
        textView.setTextColor(Color.WHITE);
        textView.setBackground(ResourcesCompat.getDrawable(parent.getResources(),
                R.drawable.vevod_tips_layer_bg_shape,
                null));
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                Gravity.BOTTOM | Gravity.LEFT);
        lp.setMargins(
                (int) UIUtils.dip2Px(parent.getContext(), 20),
                0,
                0,
                (int) UIUtils.dip2Px(parent.getContext(), 20));
        textView.setLayoutParams(lp);
        int paddingV = (int) UIUtils.dip2Px(parent.getContext(), 2);
        int paddingH = (int) UIUtils.dip2Px(parent.getContext(), 8);
        textView.setPadding(paddingH, paddingV, paddingH, paddingV);
        return textView;
    }

    public void show(CharSequence hintText) {
        animateShow(true);
        TextView text = getView();
        if (text != null) {
            text.setText(hintText);
        }
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {
        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlayerEvent.Action.RELEASE:
                    dismiss();
                    break;
            }
        }
    };
}
