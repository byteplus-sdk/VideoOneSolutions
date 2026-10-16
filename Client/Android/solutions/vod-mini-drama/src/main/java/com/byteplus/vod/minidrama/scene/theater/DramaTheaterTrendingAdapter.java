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
    private Runnable mViewportChangedListener;

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
        holder.bind(mItems, mDramaClickListener, mViewportChangedListener);
    }

    @Override
    public int getItemCount() {
        return mItems == null || mItems.isEmpty() ? 0 : 1;
    }

    @Override
    public int getItemViewType(int position) {
        return TRENDING;
    }

    public void setViewportChangedListener(Runnable listener) {
        mViewportChangedListener = listener;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        final DramaTheaterTrendingItemAdapter adapter;
        private final RecyclerView mRecyclerView;
        private Runnable mViewportChangedListener;

        public ViewHolder(@NonNull VevodMiniDramaTrendingBinding binding) {
            super(binding.getRoot());
            final int spanCount = 3;
            GridLayoutManager layoutManager = new GridLayoutManager(binding.getRoot().getContext(), spanCount,
                            RecyclerView.HORIZONTAL, false);
            mRecyclerView = binding.dramaTrendingRecyclerView;
            mRecyclerView.setLayoutManager(layoutManager);
            mRecyclerView.setHasFixedSize(false);
            adapter = new DramaTheaterTrendingItemAdapter();
            mRecyclerView.setAdapter(adapter);
            mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                    if (newState == RecyclerView.SCROLL_STATE_IDLE
                            && mViewportChangedListener != null) {
                        mViewportChangedListener.run();
                    }
                }
            });
        }

        public void bind(List<DramaInfo> items,
                         IDramaTheaterClickListener listener,
                         Runnable viewportChangedListener) {
            mViewportChangedListener = viewportChangedListener;
            adapter.setItems(items, listener);
        }

        public void collectCandidates(List<DramaInfo> out, int lookAheadCount) {
            RecyclerView.LayoutManager manager = mRecyclerView.getLayoutManager();
            if (!(manager instanceof GridLayoutManager layoutManager)) return;

            int first = layoutManager.findFirstVisibleItemPosition();
            int last = layoutManager.findLastVisibleItemPosition();
            if (first == RecyclerView.NO_POSITION || last == RecyclerView.NO_POSITION) return;

            int end = Math.min(adapter.getItemCount() - 1, last + lookAheadCount);
            for (int position = first; position <= end; position++) {
                DramaInfo item = adapter.getItem(position);
                if (item != null) {
                    out.add(item);
                }
            }
        }
    }
}
