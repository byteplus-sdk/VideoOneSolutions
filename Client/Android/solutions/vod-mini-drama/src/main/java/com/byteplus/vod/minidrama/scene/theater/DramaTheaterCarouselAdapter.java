// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.widgets.carousel.DramaCarouselView;
import com.byteplus.minidrama.R;

import java.util.Collections;
import java.util.List;

public class DramaTheaterCarouselAdapter extends RecyclerView.Adapter<DramaTheaterCarouselAdapter.ViewHolder>
        implements ViewItemType {

    public static final int MAX_COUNT = 8;

    @NonNull
    private List<DramaInfo> mItems = Collections.emptyList();
    private IDramaTheaterClickListener mDramaClickListener;

    @NonNull
    @Override
    public DramaTheaterCarouselAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        DramaCarouselView view = (DramaCarouselView) LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_mini_drama_theater_carousel_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull DramaTheaterCarouselAdapter.ViewHolder holder, int position) {
        holder.bind(mItems, mDramaClickListener);
    }

    @Override
    public int getItemCount() {
        return mItems.isEmpty() ? 0 : 1;
    }

    @Override
    public int getItemViewType(int position) {
        return ViewItemType.CAROUSEL;
    }

    public void setItems(List<DramaInfo> items, IDramaTheaterClickListener listener) {
        mDramaClickListener = listener;
        if (items == null || items.isEmpty()) {
            mItems = Collections.emptyList();
        } else {
            mItems = items.subList(0, Math.min(items.size(), MAX_COUNT));
        }
        notifyDataSetChanged();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {

        private final DramaCarouselView mCarouselView;

        public ViewHolder(@NonNull DramaCarouselView itemView) {
            super(itemView);
            mCarouselView = itemView;
        }

        void bind(List<DramaInfo> items, IDramaTheaterClickListener listener) {
            mCarouselView.setItems(items, listener);
        }
    }
}
