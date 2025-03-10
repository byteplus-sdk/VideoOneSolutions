// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_HOST_ID;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_ROOM_ID;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveRoomItemBinding;
import com.vertcdemo.solution.interactivelive.util.BVH;
import com.videoone.avatars.Avatars;

import java.util.Collections;
import java.util.List;

public class LiveRoomListAdapter extends RecyclerView.Adapter<BVH<LayoutLiveRoomItemBinding>> {
    @NonNull
    private List<LiveRoomInfo> mItems = Collections.emptyList();

    private final Context mContext;
    private final LayoutInflater mInflater;

    LiveRoomListAdapter(Context context) {
        mContext = context;
        mInflater = LayoutInflater.from(context);
    }

    @NonNull
    @Override
    public BVH<LayoutLiveRoomItemBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutLiveRoomItemBinding binding = LayoutLiveRoomItemBinding.inflate(mInflater, parent, false);
        return new BVH<>(binding.getRoot(), binding);
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<LayoutLiveRoomItemBinding> holder, int position) {
        LiveRoomInfo item = mItems.get(position);
        holder.binding.userName.setText(mContext.getString(R.string.live_show_suffix, item.anchorUserName));
        Glide.with(holder.binding.userAvatar)
                .load(Avatars.byUserId(item.anchorUserId))
                .into(holder.binding.userAvatar);

        holder.itemView.setOnClickListener(DebounceClickListener.create(v -> {
            int pos = holder.getBindingAdapterPosition();
            if (pos < 0 || pos >= mItems.size()) {
                return;
            }
            LiveRoomInfo info = mItems.get(pos);
            Bundle args = new Bundle();
            args.putString(EXTRA_ROOM_ID, info.roomId);
            args.putString(EXTRA_HOST_ID, info.anchorUserId);

            Navigation.findNavController(v)
                    .navigate(R.id.audience_view, args);
        }));
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    void updateList(@NonNull List<LiveRoomInfo> list) {
        final List<LiveRoomInfo> oldItems = mItems;
        final List<LiveRoomInfo> newItems = list;
        mItems = list;
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
                final LiveRoomInfo o = oldItems.get(oldItemPosition);
                final LiveRoomInfo n = newItems.get(newItemPosition);
                return o.anchorUserId.equals(n.anchorUserId)
                        && o.anchorUserName.equals(n.anchorUserName);
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                return true;
            }
        }).dispatchUpdatesTo(this);
    }
}
