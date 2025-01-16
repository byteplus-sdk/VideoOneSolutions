// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.minidrama.databinding.VevodMiniDramaTrendingBinding;

import java.util.List;

public class DramaTheaterTrendingAdapter  extends RecyclerView.Adapter<DramaTheaterTrendingAdapter.ViewHolder>
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
    public DramaTheaterTrendingAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        VevodMiniDramaTrendingBinding binding =
                VevodMiniDramaTrendingBinding.inflate(inflater, parent, false);
        return new DramaTheaterTrendingAdapter.ViewHolder(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull DramaTheaterTrendingAdapter.ViewHolder holder, int position) {
        holder.bind(mItems, mDramaClickListener);
    }

    @Override
    public int getItemCount() {
        return mItems == null || mItems.isEmpty() ? 0 : 1;
    }

    @Override
    public int getItemViewType(int position) {
        return TRENDING;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        final DramaTheaterTrendingItemAdapter adapter;

        public ViewHolder(@NonNull VevodMiniDramaTrendingBinding binding) {
            super(binding.getRoot());
            final int spanCount = 3;
            GridLayoutManager layoutManager = new GridLayoutManager(binding.getRoot().getContext(), spanCount,
                            RecyclerView.HORIZONTAL, false);
            binding.dramaTrendingRecyclerView.setLayoutManager(layoutManager);
            binding.dramaTrendingRecyclerView.setHasFixedSize(false);
            adapter = new DramaTheaterTrendingItemAdapter();
            binding.dramaTrendingRecyclerView.setAdapter(adapter);
        }

        public void bind(List<DramaInfo> items, IDramaTheaterClickListener listener) {
            adapter.setItems(items, listener);
        }
    }
}
