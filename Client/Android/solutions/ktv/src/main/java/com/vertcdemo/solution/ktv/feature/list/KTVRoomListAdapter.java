// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.list;

import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_REFERRER;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_ROOM_INFO;

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
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.databinding.LayoutKtvRoomItemBinding;
import com.vertcdemo.solution.ktv.utils.BVH;
import com.videoone.avatars.Avatars;

import java.util.Collections;
import java.util.List;
import java.util.Locale;

public class KTVRoomListAdapter extends RecyclerView.Adapter<BVH<LayoutKtvRoomItemBinding>> {
    @NonNull
    private List<RoomInfo> mItems = Collections.emptyList();

    private final Context mContext;
    private final LayoutInflater mInflater;

    KTVRoomListAdapter(Context context) {
        mContext = context;
        mInflater = LayoutInflater.from(context);
    }

    @NonNull
    @Override
    public BVH<LayoutKtvRoomItemBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutKtvRoomItemBinding binding = LayoutKtvRoomItemBinding.inflate(mInflater, parent, false);
        return new BVH<>(binding.getRoot(), binding);
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<LayoutKtvRoomItemBinding> holder, int position) {
        RoomInfo item = mItems.get(position);
        holder.binding.userName.setText(mContext.getString(R.string.label_create_name_xxx, item.hostUserName));
        Glide.with(holder.binding.userAvatar)
                .load(Avatars.byUserId(item.hostUserId))
                .into(holder.binding.userAvatar);

        holder.binding.ktvAudienceCount.setText(formatAudienceCount(item.audienceCount + 1));

        holder.itemView.setOnClickListener(DebounceClickListener.create(v -> {
            RoomInfo info = mItems.get(holder.getBindingAdapterPosition());
            Bundle args = new Bundle();
            args.putParcelable(EXTRA_ROOM_INFO, info);
            args.putString(EXTRA_REFERRER, "list");

            Navigation.findNavController(v)
                    .navigate(R.id.action_ktv_room, args);
        }));
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<LayoutKtvRoomItemBinding> holder,
                                 int position,
                                 @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
        } else {
            Object payload = payloads.get(0);
            if (PAYLOAD_AUDIENCE_COUNT == payload) {
                final RoomInfo item = mItems.get(position);
                holder.binding.ktvAudienceCount.setText(formatAudienceCount(item.audienceCount + 1));
            }
        }
    }

    private static String formatAudienceCount(int count) {
        if (count <= 0) {
            return String.valueOf(0);
        } else if (count < 1000) {
            return String.valueOf(count);
        } else if (count < 1_000_000) {
            return String.format(Locale.ENGLISH, "%1$.1fK", count / 1000.F);
        } else {
            return String.format(Locale.ENGLISH, "%1$.1fM", count / 1_000_000.F);
        }
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    void updateList(@NonNull List<RoomInfo> list) {
        final List<RoomInfo> oldItems = mItems;
        final List<RoomInfo> newItems = list;
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
                final RoomInfo o = oldItems.get(oldItemPosition);
                final RoomInfo n = newItems.get(newItemPosition);
                return o.roomId.equals(n.roomId)
                        && o.hostUserId.equals(n.hostUserId)
                        && o.hostUserName.equals(n.hostUserName);
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                final RoomInfo o = oldItems.get(oldItemPosition);
                final RoomInfo n = newItems.get(newItemPosition);
                return o.audienceCount == n.audienceCount;
            }

            @Override
            public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                return PAYLOAD_AUDIENCE_COUNT;
            }
        }).dispatchUpdatesTo(this);
    }

    private static final String PAYLOAD_AUDIENCE_COUNT = "audience_count";
}
