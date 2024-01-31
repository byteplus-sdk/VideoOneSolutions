// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.video.scene.detail;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CenterCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.utils.FormatHelper;
import com.bytedance.vod.scenekit.utils.UIUtils;
import com.bytedance.voddemo.impl.databinding.VevodRecommendVideoItemBinding;

import java.util.ArrayList;
import java.util.List;

public class RecommendVideoAdapter extends RecyclerView.Adapter<RecommendVideoAdapter.ViewHolder> {

    public interface OnItemClickListener {
        void onItemClick(VideoItem videoItem);
    }

    @NonNull
    private final List<VideoItem> mItems = new ArrayList<>();

    private final OnItemClickListener mItemClickListener;
    private final Context mContext;

    private final int mCoverCorner;

    public RecommendVideoAdapter(@NonNull Context context, OnItemClickListener itemClickListener) {
        mContext = context;
        mItemClickListener = itemClickListener;
        mCoverCorner = (int) UIUtils.dip2Px(mContext, 4);
    }

    @NonNull
    @Override
    public RecommendVideoAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(
                VevodRecommendVideoItemBinding.inflate(
                        LayoutInflater.from(parent.getContext()),
                        parent,
                        false
                )
        );
    }

    @Override
    public void onBindViewHolder(@NonNull RecommendVideoAdapter.ViewHolder holder, int position) {
        final VideoItem videoItem = mItems.get(position);
        Glide.with(holder.binding.cover)
                .load(videoItem.getCover())
                .transform(new CenterCrop(), new RoundedCorners(mCoverCorner))
                .into(holder.binding.cover);

        holder.binding.title.setText(videoItem.getTitle());
        holder.binding.username.setText(videoItem.getUserName());
        holder.binding.videoDescription.setText(FormatHelper.formatCountAndCreateTime(mContext, videoItem));
        holder.binding.duration.setText(FormatHelper.formatDuration(mContext, videoItem));

        holder.binding.getRoot().setOnClickListener(v -> {
            if (mItemClickListener != null) {
                mItemClickListener.onItemClick(videoItem);
            }
        });
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void clear() {
        int count = mItems.size();
        if (count == 0) {
            return;
        }
        mItems.clear();
        notifyItemRangeRemoved(0, count);
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setItems(List<VideoItem> videoItems) {
        mItems.clear();
        mItems.addAll(videoItems);
        notifyDataSetChanged();
    }

    public void appendItems(List<VideoItem> videoItems) {
        int count = mItems.size();
        mItems.addAll(videoItems);
        notifyItemRangeInserted(count, videoItems.size());
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        public final VevodRecommendVideoItemBinding binding;

        public ViewHolder(@NonNull VevodRecommendVideoItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
    }
}
