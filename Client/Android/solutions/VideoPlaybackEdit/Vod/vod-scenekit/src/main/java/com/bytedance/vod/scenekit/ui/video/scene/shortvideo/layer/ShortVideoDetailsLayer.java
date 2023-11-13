// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.ui.video.layer.base.BaseLayer;

public class ShortVideoDetailsLayer extends BaseLayer {

    private TextView title;
    private TextView subtitle;

    private View bottom;

    @Nullable
    @Override
    public String tag() {
        return "short_video_details";
    }

    public ShortVideoDetailsLayer() {
        setIgnoreLock(true);
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_short_video_details_layer, parent, false);
        title = view.findViewById(R.id.title);
        subtitle = view.findViewById(R.id.subtitle);
        bottom = view.findViewById(R.id.bottom);
        return view;
    }

    /**
     * @see ShortVideoProgressBarLayer
     */
    public void bind(VideoItem item) {
        show();
        title.setText(item.getTitle());

        // Patch for TextView height issue when setMaxLines(int) called
        subtitle.setMaxLines(TextUtils.isEmpty(item.getSubtitle()) ? 0 : 2);

        subtitle.setText(item.getSubtitle());

        // PM: Only show progress bar when duration > 1 Min
        // Leave padding for ProgressBar
        boolean showBottom = item.getDuration() > 60_000;
        bottom.setVisibility(showBottom ? View.VISIBLE : View.GONE);
    }
}
