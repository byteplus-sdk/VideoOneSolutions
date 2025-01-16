// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets;

import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.byteplus.vod.minidrama.scene.widgets.viewholder.DramaVideoItemViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.adatper.ViewHolder;
import com.byteplus.vod.scenekit.data.model.ItemType;

public class DramaVideoViewHolderFactory implements ViewHolder.Factory {
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case ItemType.ITEM_TYPE_VIDEO:
                final ViewHolder holder = new DramaVideoItemViewHolder(new FrameLayout(parent.getContext()));
                holder.itemView.setTag(holder);
                return holder;
        }
        throw new IllegalArgumentException("unsupported type!");
    }
}
