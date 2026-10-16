// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.graphics.Rect;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.minidrama.databinding.VevodMiniDramaNewBinding;
import com.byteplus.vod.scenekit.utils.ViewUtils;

import java.util.List;

public class DramaTheaterNewAdapter extends RecyclerView.Adapter<DramaTheaterNewAdapter.ViewHolder>
        implements ViewItemType {
    private List<DramaInfo> mItems;
    private IDramaTheaterClickListener mDramaClickListener;
    private Runnable mViewportChangedListener;

    public void setItems(List<DramaInfo> items, IDramaTheaterClickListener listener) {
        mItems = items;
        mDramaClickListener = listener;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public DramaTheaterNewAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        VevodMiniDramaNewBinding binding =
                VevodMiniDramaNewBinding.inflate(inflater, parent, false);
        return new DramaTheaterNewAdapter.ViewHolder(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull DramaTheaterNewAdapter.ViewHolder holder, int position) {
        holder.bind(mItems, mDramaClickListener, mViewportChangedListener);
    }

    @Override
    public int getItemCount() {
        return mItems == null || mItems.isEmpty() ? 0 : 1;
    }

    @Override
    public int getItemViewType(int position) {
        return RELEASE_NEW;
    }

    public void setViewportChangedListener(Runnable listener) {
        mViewportChangedListener = listener;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        final DramaTheaterNewItemAdapter adapter;
        private final RecyclerView mRecyclerView;
        private Runnable mViewportChangedListener;

        public ViewHolder(@NonNull VevodMiniDramaNewBinding binding) {
            super(binding.getRoot());
            mRecyclerView = binding.dramaNewRecyclerview;
            mRecyclerView.setLayoutManager(new LinearLayoutManager(
                    binding.getRoot().getContext(), RecyclerView.HORIZONTAL, false));
            adapter = new DramaTheaterNewItemAdapter();
            mRecyclerView.setAdapter(adapter);
            mRecyclerView.addItemDecoration(new RecyclerView.ItemDecoration() {
                final int rectMargin = ViewUtils.dp2px(8);
                @Override
                public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                    super.getItemOffsets(outRect, view, parent, state);
                    final int position = parent.getChildAdapterPosition(view);
                    outRect.left = position == 0 ? 0 : rectMargin;
                    outRect.right = position == adapter.getItemCount() - 1 ? 0 : rectMargin;
                }
            });
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
            if (!(manager instanceof LinearLayoutManager layoutManager)) return;

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
