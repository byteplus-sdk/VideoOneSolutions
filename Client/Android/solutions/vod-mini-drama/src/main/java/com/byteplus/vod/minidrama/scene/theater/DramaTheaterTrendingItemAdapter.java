// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaTrendingItemBinding;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.vertcdemo.core.utils.DebounceClickListener;

import java.util.List;

public class DramaTheaterTrendingItemAdapter extends RecyclerView.Adapter<DramaTheaterTrendingItemAdapter.ViewHolder>
        implements ViewItemType {

    private List<DramaInfo> mItems;
    private IDramaTheaterClickListener mDramaClickListener;

    public void setItems(List<DramaInfo> items, IDramaTheaterClickListener listener) {
        mDramaClickListener = listener;
        mItems = items;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public DramaTheaterTrendingItemAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        VevodMiniDramaTrendingItemBinding binding =
                VevodMiniDramaTrendingItemBinding.inflate(inflater, parent, false);
        int width = (int) (parent.getWidth() * 0.5f);
        binding.getRoot().setMaxWidth(width);
        binding.getRoot().setMinWidth(width);
        return new DramaTheaterTrendingItemAdapter.ViewHolder(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull DramaTheaterTrendingItemAdapter.ViewHolder holder, int position) {
        holder.bind(mItems.get(position), position, mItems, mDramaClickListener);
    }

    @Override
    public int getItemCount() {
        return mItems == null ? 0 : mItems.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        final VevodMiniDramaTrendingItemBinding binding;

        public ViewHolder(@NonNull VevodMiniDramaTrendingItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        public void bind(DramaInfo info, int position, List<DramaInfo> items, IDramaTheaterClickListener listener) {
            binding.dramaTrendingTextviewText.setText(info.dramaTitle);
            binding.dramaTrendingTextviewDesc.setText(FormatHelper.formatCount(binding.getRoot().getContext(), info.dramaPlayTimes));
            setMarkFillText(position + 1, binding.dramaTrendingTextviewMark, binding.dramaTrendingImageviewMark);
            Glide.with(binding.dramaTrendingImageview.getContext()).load(info.dramaCoverUrl).centerCrop().into(binding.dramaTrendingImageview);
            binding.getRoot().setOnClickListener(DebounceClickListener.create(v -> {
                int pos = getBindingAdapterPosition();
                if (pos >=0 && pos < items.size()) {
                    if (listener != null) {
                        listener.onClick(info, pos, items);
                    }
                }
            }));
        }

        private void setMarkFillText(int fillIndex, TextView markTextView, ImageView markImageView) {
            switch (fillIndex) {
                case 1 -> {
                    markImageView.setVisibility(View.VISIBLE);
                    markTextView.setVisibility(View.GONE);
                    markImageView.setImageResource(R.drawable.vevod_ic_mini_drama_trending_item_top1);
                }
                case 2 -> {
                    markImageView.setVisibility(View.VISIBLE);
                    markTextView.setVisibility(View.GONE);
                    markImageView.setImageResource(R.drawable.vevod_ic_mini_drama_trending_item_top2);
                }
                case 3 -> {
                    markImageView.setVisibility(View.VISIBLE);
                    markTextView.setVisibility(View.GONE);
                    markImageView.setImageResource(R.drawable.vevod_ic_mini_drama_trending_item_top3);
                }
                default -> {
                    markImageView.setVisibility(View.GONE);
                    markTextView.setVisibility(View.VISIBLE);
                    markTextView.setText(String.format("%s", fillIndex));
                }
            }
        }
    }
}
