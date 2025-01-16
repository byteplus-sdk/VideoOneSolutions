// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.minidrama.databinding.VevodMiniDramaTheaterGridItemBinding;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.vertcdemo.core.utils.DebounceClickListener;

import java.util.ArrayList;
import java.util.List;

public class DramaTheaterItemAdapter
        extends RecyclerView.Adapter<DramaTheaterItemAdapter.ViewHolder>
        implements ViewItemType {

    @NonNull
    private List<DramaInfo> mItems = new ArrayList<>();
    private IDramaTheaterClickListener mDramaClickListener;

    public void setItems(List<DramaInfo> items, IDramaTheaterClickListener listener) {
        mDramaClickListener = listener;
        List<DramaInfo> oldItems = mItems;
        List<DramaInfo> newItems = new ArrayList<>(items);
        mItems = newItems;

        DiffUtil.calculateDiff(new DiffUtil.Callback() {
            @Override
            public int getOldListSize() {
                return oldItems.size();
            }

            @Override
            public int getNewListSize() {
                return newItems.size();
            }

            @Override
            public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                DramaInfo oldItem = oldItems.get(oldItemPosition);
                DramaInfo newItem = newItems.get(newItemPosition);
                return TextUtils.equals(oldItem.dramaId, newItem.dramaId);
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                DramaInfo oldItem = oldItems.get(oldItemPosition);
                DramaInfo newItem = newItems.get(newItemPosition);
                return TextUtils.equals(oldItem.dramaTitle, newItem.dramaTitle)
                        && TextUtils.equals(oldItem.dramaCoverUrl, newItem.dramaCoverUrl)
                        && oldItem.dramaPlayTimes == newItem.dramaPlayTimes;
            }

            @Override
            public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                DramaInfo oldItem = oldItems.get(oldItemPosition);
                DramaInfo newItem = newItems.get(newItemPosition);

                if (oldItem.dramaPlayTimes != newItem.dramaPlayTimes) {
                    return PAYLOAD_PLAY_TIMES;
                }

                return null;
            }
        }).dispatchUpdatesTo(this);
    }

    public void appendItems(List<DramaInfo> items) {
        int count = mItems.size();
        mItems.addAll(items);
        notifyItemRangeInserted(count, items.size());
    }

    public List<DramaInfo> getItems() {
        return mItems;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        VevodMiniDramaTheaterGridItemBinding binding =
                VevodMiniDramaTheaterGridItemBinding.inflate(inflater, parent, false);
        return new ViewHolder(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(mItems.get(position), mItems, mDramaClickListener);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position, @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
        } else {
            if (payloads.contains(PAYLOAD_PLAY_TIMES)) {
                holder.bindPlayCount(mItems.get(position));
            }
        }
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    @Override
    public int getItemViewType(int position) {
        return ITEM;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        final VevodMiniDramaTheaterGridItemBinding binding;
        final Context context;

        public ViewHolder(@NonNull VevodMiniDramaTheaterGridItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
            this.context = binding.getRoot().getContext();
        }

        public void bind(DramaInfo drama, List<DramaInfo> items, IDramaTheaterClickListener listener) {
            binding.title.setText(drama.dramaTitle);

            Glide.with(binding.cover)
                    .load(drama.dramaCoverUrl)
                    .centerCrop()
                    .into(binding.cover);

            bindPlayCount(drama);
            binding.getRoot().setOnClickListener(DebounceClickListener.create(v->{
                if (listener != null) {
                    int pos = getBindingAdapterPosition();
                    if (pos >= 0 && pos < items.size()) {
                        listener.onClick(items.get(pos), pos, items);
                    }
                }
            }));
        }

        public void bindPlayCount(DramaInfo drama) {
            binding.playCount.setText(FormatHelper.formatCount(context, drama.dramaPlayTimes));
        }
    }

    private static final String PAYLOAD_PLAY_TIMES = "playTimes";
}