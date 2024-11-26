// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.audience;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserStatus;
import com.vertcdemo.solution.ktv.databinding.ItemKtvManageAudienceBinding;
import com.vertcdemo.solution.ktv.utils.BVH;
import com.videoone.avatars.Avatars;

import java.util.Collections;
import java.util.List;

public class ManageAudienceAdapter extends RecyclerView.Adapter<BVH<ItemKtvManageAudienceBinding>> {

    private List<UserInfo> mItems = Collections.emptyList();
    private final OnOptionSelected mListener;

    private final boolean mIsApplyView;

    public ManageAudienceAdapter(OnOptionSelected listener) {
        this(listener, false);
    }

    public ManageAudienceAdapter(OnOptionSelected listener, boolean isApplyView) {
        mListener = listener;
        mIsApplyView = isApplyView;
    }

    @NonNull
    @Override
    public BVH<ItemKtvManageAudienceBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ItemKtvManageAudienceBinding binding = ItemKtvManageAudienceBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        if (mIsApplyView) {
            binding.cancel.setVisibility(View.GONE);
            binding.cancel.setText(R.string.button_alert_reject);
            binding.ok.setText(R.string.button_alert_accept);
        } else {
            binding.cancel.setVisibility(View.GONE);
        }
        return new BVH<>(binding.getRoot(), binding);
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<ItemKtvManageAudienceBinding> holder, int position) {
        UserInfo item = mItems.get(position);
        holder.binding.position.setText(String.valueOf(position + 1));
        Glide.with(holder.binding.avatar)
                .load(Avatars.byUserId(item.userId))
                .into(holder.binding.avatar);
        holder.binding.name.setText(item.userName);

        if (mIsApplyView) {
            holder.binding.cancel.setOnClickListener(v -> {
                UserInfo info = mItems.get(holder.getBindingAdapterPosition());
                mListener.onOption(OnOptionSelected.ACTION_CANCEL, info);
            });
            holder.binding.ok.setOnClickListener(v -> {
                UserInfo info = mItems.get(holder.getBindingAdapterPosition());
                mListener.onOption(OnOptionSelected.ACTION_OK, info);
            });
        } else {
            updateStatus(holder, item);

            holder.binding.ok.setOnClickListener(v -> {
                UserInfo info = mItems.get(holder.getBindingAdapterPosition());
                mListener.onOption(OnOptionSelected.ACTION_OK, info);
            });
        }
    }

    @Override
    public void onBindViewHolder(@NonNull BVH<ItemKtvManageAudienceBinding> holder, int position, @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
        } else {
            Object payload = payloads.get(0);
            if (PAYLOAD_STATUS == payload) {
                if (!mIsApplyView) {
                    UserInfo item = mItems.get(position);
                    updateStatus(holder, item);
                }
            }
        }
    }

    private void updateStatus(BVH<ItemKtvManageAudienceBinding> holder, UserInfo item) {
        int status = item.userStatus;
        if (status == UserStatus.INTERACT) {
            holder.binding.ok.setText(R.string.button_user_list_guest);
            holder.binding.ok.setSelected(true);
        } else if (status == UserStatus.INVITING) {
            holder.binding.ok.setText(R.string.button_user_list_invited);
            holder.binding.ok.setSelected(true);
        } else if (status == UserStatus.APPLYING) {
            holder.binding.ok.setText(R.string.button_user_list_accept);
            holder.binding.ok.setSelected(false);
        } else {
            holder.binding.ok.setText(R.string.button_user_list_invited_guest);
            holder.binding.ok.setSelected(false);
        }
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void setList(@NonNull List<UserInfo> users) {
        List<UserInfo> oldItems = mItems;
        mItems = users;
        DiffUtil.calculateDiff(new DiffUtil.Callback() {
            @Override
            public int getOldListSize() {
                return oldItems.size();
            }

            @Override
            public int getNewListSize() {
                return users.size();
            }

            @Override
            public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                UserInfo oldItem = oldItems.get(oldItemPosition);
                UserInfo newItem = users.get(newItemPosition);
                return TextUtils.equals(oldItem.userId, newItem.userId);
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                UserInfo oldItem = oldItems.get(oldItemPosition);
                UserInfo newItem = users.get(newItemPosition);
                return oldItem.userStatus == newItem.userStatus;
            }

            @Override
            public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                return PAYLOAD_STATUS;
            }
        }).dispatchUpdatesTo(this);
    }

    private static final String PAYLOAD_STATUS = "status";
}
