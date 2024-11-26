// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room.song;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.ItemChorusSongsBinding;
import com.vertcdemo.solution.chorus.bean.StatusSongItem;
import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.chorus.utils.BVH;

import java.util.Collections;
import java.util.List;

public class MusicLibraryAdapter extends RecyclerView.Adapter<BVH<ItemChorusSongsBinding>> {
    private final Consumer<StatusSongItem> mOnClickListener;
    @NonNull
    private List<StatusSongItem> mItems = Collections.emptyList();

    public MusicLibraryAdapter(Consumer<StatusSongItem> onClickListener) {
        mOnClickListener = onClickListener;
    }

    @NonNull
    @Override
    public BVH<ItemChorusSongsBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_chorus_songs, parent, false);
        return new BVH<>(view, ItemChorusSongsBinding.bind(view));
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<ItemChorusSongsBinding> holder, int position) {
        StatusSongItem item = mItems.get(position);

        String coverUrl = item.getCoverUrl();

        Glide.with(holder.binding.cover)
                .load(coverUrl)
                .placeholder(R.drawable.ic_play_original)
                .into(holder.binding.cover);

        holder.binding.trackName.setText(item.getSongName());
        String singer = holder.itemView.getContext().getString(R.string.label_music_list_singer_xxx, item.getArtist());
        holder.binding.trackArtist.setText(singer);

        updateStatus(holder, item);

        if (mOnClickListener != null) {
            holder.itemView.setOnClickListener(v -> {
                StatusSongItem info = mItems.get(holder.getBindingAdapterPosition());
                mOnClickListener.accept(info);
            });
        }
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<ItemChorusSongsBinding> holder, int position, @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
        } else {
            Object payload = payloads.get(0);
            if (PAYLOAD_STATUS == payload) {
                StatusSongItem item = mItems.get(position);
                updateStatus(holder, item);
            }
        }
    }

    private void updateStatus(BVH<ItemChorusSongsBinding> holder, StatusSongItem item) {
        if (item.status == SongStatus.PICKED) {
            holder.binding.action.setSelected(true);
            holder.binding.action.setText(R.string.button_music_list_already);
        } else if (item.status == SongStatus.DOWNLOADING) {
            holder.binding.action.setSelected(true);
            holder.binding.action.setText(R.string.button_music_list_downloading);
        } else {
            holder.binding.action.setSelected(false);
            holder.binding.action.setText(R.string.button_music_list_request_song);
        }
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void setList(@NonNull List<StatusSongItem> newItems) {
        final List<StatusSongItem> oldItems = mItems;
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
                StatusSongItem oldItem = oldItems.get(oldItemPosition);
                StatusSongItem newItem = newItems.get(newItemPosition);
                return oldItem.getSongId().equals(newItem.getSongId());
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                StatusSongItem oldItem = oldItems.get(oldItemPosition);
                StatusSongItem newItem = newItems.get(newItemPosition);
                return oldItem.status == newItem.status;
            }

            @Override
            public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                return PAYLOAD_STATUS;
            }
        }).dispatchUpdatesTo(this);
    }

    private static final String PAYLOAD_STATUS = "status";
}
