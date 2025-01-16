// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.minidrama.databinding.VevodMiniDramaNewItemBinding;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.vertcdemo.core.utils.DebounceClickListener;

import java.util.List;

public class DramaTheaterNewItemAdapter extends RecyclerView.Adapter<DramaTheaterNewItemAdapter.ViewHolder>
        implements ViewItemType {
    private List<DramaInfo> mItems;
    private IDramaTheaterClickListener mDramaClickListener;

    public void setItems(List<DramaInfo> items, IDramaTheaterClickListener listener) {
        mItems = items;
        mDramaClickListener = listener;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public DramaTheaterNewItemAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        VevodMiniDramaNewItemBinding binding =
                VevodMiniDramaNewItemBinding.inflate(inflater, parent, false);
        return new DramaTheaterNewItemAdapter.ViewHolder(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull DramaTheaterNewItemAdapter.ViewHolder holder, int position) {
        holder.bind(mItems.get(position), mItems, mDramaClickListener);
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        final VevodMiniDramaNewItemBinding binding;

        public ViewHolder(@NonNull VevodMiniDramaNewItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        public void bind(DramaInfo info, List<DramaInfo> items, IDramaTheaterClickListener listener) {
            Glide.with(binding.dramaNewImageview.getContext()).load(info.dramaCoverUrl).centerCrop().into(binding.dramaNewImageview);
            binding.dramaNewTextviewPlaytime.setText(FormatHelper.formatCount(binding.getRoot().getContext(), info.dramaPlayTimes));
            binding.dramaNewTextviewText.setText(info.dramaTitle);
            binding.dramaNewImageviewMark.setVisibility(info.newRelease ? View.VISIBLE : View.GONE);
            binding.getRoot().setOnClickListener(DebounceClickListener.create(v->{
                if (listener != null) {
                    int pos = getBindingAdapterPosition();
                    if (pos >= 0 && pos < items.size()) {
                        listener.onClick(items.get(pos), pos, items);
                    }
                }
            }));
        }
    }
}
