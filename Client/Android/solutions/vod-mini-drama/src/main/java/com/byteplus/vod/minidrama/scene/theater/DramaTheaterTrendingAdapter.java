// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.view.LayoutInflater;
import android.graphics.Rect;
import android.view.View;
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
    private Runnable mViewportChangedListener;

    public void setViewportChangedListener(Runnable listener) {
        mViewportChangedListener = listener;
    }

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
        return new DramaTheaterTrendingAdapter.ViewHolder(binding, () -> {
            if (mViewportChangedListener != null) mViewportChangedListener.run();
        });
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
        private final RecyclerView mRecyclerView;
        private List<DramaInfo> mItems;

        public ViewHolder(@NonNull VevodMiniDramaTrendingBinding binding, Runnable viewportChanged) {
            super(binding.getRoot());
            mRecyclerView = binding.dramaTrendingRecyclerView;
            mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrollStateChanged(@NonNull RecyclerView view, int state) {
                    viewportChanged.run();
                }
            });
            final int spanCount = 3;
            GridLayoutManager layoutManager = new GridLayoutManager(binding.getRoot().getContext(), spanCount,
                            RecyclerView.HORIZONTAL, false);
            binding.dramaTrendingRecyclerView.setLayoutManager(layoutManager);
            binding.dramaTrendingRecyclerView.setHasFixedSize(false);
            adapter = new DramaTheaterTrendingItemAdapter();
            binding.dramaTrendingRecyclerView.setAdapter(adapter);
        }

        public void bind(List<DramaInfo> items, IDramaTheaterClickListener listener) {
            mItems = items;
            adapter.setItems(items, listener);
        }

        void collectVisible(List<DramaInfo> out) {
            if (mItems == null) return;
            for (int i = 0; i < mRecyclerView.getChildCount(); i++) {
                View child = mRecyclerView.getChildAt(i);
                int position = mRecyclerView.getChildAdapterPosition(child);
                if (position >= 0 && position < mItems.size()
                        && child.getGlobalVisibleRect(new Rect())) out.add(mItems.get(position));
            }
        }
    }
}
