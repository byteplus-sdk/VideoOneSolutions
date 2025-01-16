// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.carousel;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.byteplus.minidrama.R;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.theater.IDramaTheaterClickListener;
import com.vertcdemo.core.utils.DebounceClickListener;

import java.util.Collections;
import java.util.List;

public class DramaCarouselAdapter extends RecyclerView.Adapter<DramaCarouselAdapter.CarouselItemViewHolder> {
    private IDramaTheaterClickListener mDramaClickListener;

    public static final int MAX_COUNT = Integer.MAX_VALUE - 1;

    protected DramaCarouselAdapter() {
    }

    private List<DramaInfo> mItems = Collections.emptyList();

    @Override
    public int getItemCount() {
        return mItems.isEmpty() ? 0 : MAX_COUNT;
    }

    public DramaInfo getItem(int position) {
        return mItems.get(position % mItems.size());
    }

    public void submitList(List<DramaInfo> items) {
        int oldItemCount = mItems.size();
        mItems = items;
        int newItemCount = mItems.size();
        if (oldItemCount == 0 && newItemCount != 0) {
            notifyItemRangeInserted(0, MAX_COUNT);
        } else if (oldItemCount != 0 && newItemCount == 0) {
            notifyItemRangeRemoved(0, MAX_COUNT);
        } else if (oldItemCount != 0) {
            notifyItemRangeChanged(0, MAX_COUNT);
        }
    }

    public int centerPosition() {
        int size = mItems.size();
        if (size == 0) {
            return RecyclerView.NO_POSITION;
        }

        int center = Integer.MAX_VALUE / 2;
        return center - center % size;
    }

    public int next(int position) {
        int newPosition = (position + 1) % MAX_COUNT;
        if (newPosition == 0) {
            // Means the last item is selected,
            // roll back to an item which item's close to center & indicator is equal to (position + 1)
            int indicatorPosition = position % mItems.size();
            return centerPosition() + indicatorPosition + 1;
        }
        return newPosition;
    }

    @NonNull
    @Override
    public CarouselItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new CarouselItemViewHolder(
                LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_mini_drama_carousel_item, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull CarouselItemViewHolder holder, int position) {
        DramaInfo item = getItem(position);
        Glide.with(holder.imageView)
                .load(item.dramaCoverUrl)
                .centerCrop()
                .into(holder.imageView);

        holder.playNowImageView.setOnClickListener(DebounceClickListener.create(v -> {
            IDramaTheaterClickListener listener = mDramaClickListener;
            if (listener != null) {
                int adapterPosition = holder.getBindingAdapterPosition();
                DramaInfo info = getItem(adapterPosition);
                listener.onClick(info, adapterPosition % mItems.size(), mItems);
            }
        }));
    }

    public void setDramaClickListener(IDramaTheaterClickListener listener) {
        mDramaClickListener = listener;
    }

    public static class CarouselItemViewHolder extends RecyclerView.ViewHolder {

        final ImageView imageView;
        final ImageView playNowImageView;

        CarouselItemViewHolder(@NonNull View itemView) {
            super(itemView);
            imageView = itemView.findViewById(R.id.carousel_image_view);
            playNowImageView = itemView.findViewById(R.id.carsousel_play_now);
        }
    }
}
