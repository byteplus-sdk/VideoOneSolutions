// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room.song;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.ItemChorusPickedSongBinding;
import com.vertcdemo.solution.chorus.bean.PickedSongInfo;
import com.vertcdemo.solution.chorus.bean.StatusPickedSongItem;
import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.chorus.utils.BVH;

import java.util.Collections;
import java.util.List;

public class PickedSongsAdapter extends RecyclerView.Adapter<BVH<ItemChorusPickedSongBinding>> {
    @NonNull
    private List<StatusPickedSongItem> mItems = Collections.emptyList();

    public PickedSongsAdapter() {
    }

    @NonNull
    @Override
    public BVH<ItemChorusPickedSongBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_chorus_picked_song, parent, false);
        return new BVH<>(view, ItemChorusPickedSongBinding.bind(view));
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<ItemChorusPickedSongBinding> holder, int position) {
        StatusPickedSongItem item = mItems.get(position);

        String coverUrl = item.getCoverUrl();

        Glide.with(holder.binding.cover)
                .load(coverUrl)
                .placeholder(R.drawable.ic_play_original)
                .into(holder.binding.cover);

        holder.binding.trackName.setText(item.getSongName());
        String singer = holder.itemView.getContext().getString(R.string.label_pick_song_singer_xxx, item.getArtist());
        holder.binding.trackArtist.setText(singer);

        holder.binding.action.setVisibility(item.isSinging() ? View.VISIBLE : View.GONE);
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<ItemChorusPickedSongBinding> holder, int position, @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
        } else {
            Object payload = payloads.get(0);
            if (PAYLOAD_STATUS == payload) {
                StatusPickedSongItem item = mItems.get(position);
                holder.binding.action.setVisibility(item.isSinging() ? View.VISIBLE : View.GONE);
            }
        }
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void setList(@NonNull List<StatusPickedSongItem> newItems) {
        final List<StatusPickedSongItem> oldItems = mItems;
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
                StatusPickedSongItem oldItem = oldItems.get(oldItemPosition);
                StatusPickedSongItem newItem = newItems.get(newItemPosition);
                return oldItem.getSongId().equals(newItem.getSongId())
                        && oldItem.getOwnerUid().equals(newItem.getOwnerUid());
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                StatusPickedSongItem oldItem = oldItems.get(oldItemPosition);
                StatusPickedSongItem newItem = newItems.get(newItemPosition);
                return oldItem.status == newItem.status;
            }

            @Override
            public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                return PAYLOAD_STATUS;
            }
        }).dispatchUpdatesTo(this);
    }

    public void updatePlayingState(@Nullable PickedSongInfo current) {
        for (int i = 0; i < mItems.size(); i++) {
            StatusPickedSongItem item = mItems.get(i);
            if (item.isSinging() && !item.match(current)) {
                item.status = SongStatus.PICKED;
                notifyItemChanged(i, PAYLOAD_STATUS);
            } else if (!item.isSinging() && item.match(current)) {
                item.status = SongStatus.SINGING;
                notifyItemChanged(i, PAYLOAD_STATUS);
            }
        }
    }

    private static final String PAYLOAD_STATUS = "status";
}
