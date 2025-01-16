// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.adatper;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;


import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.ui.video.scene.IViewHolderFactory;

import java.util.List;

public abstract class ViewHolder extends RecyclerView.ViewHolder {
    public interface Factory extends IViewHolderFactory {
        @NonNull
        ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType);
    }

    public ViewHolder(@NonNull View itemView) {
        super(itemView);
        itemView.setTag(this);
    }

    public void onViewAttachedToWindow() {
        L.v(this, "onViewAttachedToWindow", getBindingAdapterPosition());
    }

    public void onViewDetachedFromWindow() {
        L.v(this, "onViewDetachedFromWindow", getBindingAdapterPosition());
    }

    public void onViewRecycled() {
        L.v(this, "onViewRecycled", getBindingAdapterPosition());
    }

    public boolean onBackPressed() {
        return false;
    }

    public abstract void bind(List<ViewItem> items, int position);

    public abstract ViewItem getBindingItem();

    public final void executeAction(int action) {
        executeAction(action, null);
    }

    public void executeAction(int action, @Nullable Object o) {
    }
}