// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.audience;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserStatus;
import com.vertcdemo.solution.ktv.databinding.ItemKtvManageAudienceBinding;
import com.videoone.avatars.Avatars;

import java.util.Collections;
import java.util.List;

public class ManageAudienceAdapter extends RecyclerView.Adapter<ManageAudienceAdapter.AudienceManageViewHolder> {

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
    public ManageAudienceAdapter.AudienceManageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_ktv_manage_audience, parent, false);
        return new ManageAudienceAdapter.AudienceManageViewHolder(view, mIsApplyView);
    }

    @Override
    public void onBindViewHolder(@NonNull ManageAudienceAdapter.AudienceManageViewHolder holder, int position) {
        UserInfo userInfo = mItems.get(position);
        holder.bind(position, userInfo, mListener);
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
                return oldItem == newItem;
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                UserInfo oldItem = oldItems.get(oldItemPosition);
                UserInfo newItem = users.get(newItemPosition);
                return TextUtils.equals(oldItem.userId, newItem.userId)
                        && oldItem.userStatus == newItem.userStatus;
            }
        }).dispatchUpdatesTo(this);
    }

    public static class AudienceManageViewHolder extends RecyclerView.ViewHolder {
        private final ItemKtvManageAudienceBinding mBinding;

        private final boolean mIsApplyView;

        public AudienceManageViewHolder(@NonNull View itemView, boolean isApplyView) {
            super(itemView);
            mBinding = ItemKtvManageAudienceBinding.bind(itemView);
            mIsApplyView = isApplyView;
            if (mIsApplyView) {
                mBinding.cancel.setVisibility(View.GONE);
                mBinding.cancel.setText(R.string.button_alert_reject);
                mBinding.ok.setText(R.string.button_alert_accept);
            } else {
                mBinding.cancel.setVisibility(View.GONE);
            }
        }

        void bind(int position, UserInfo userInfo, OnOptionSelected listener) {
            mBinding.position.setText(String.valueOf(position + 1));
            Glide.with(mBinding.avatar)
                    .load(Avatars.byUserId(userInfo.userId))
                    .into(mBinding.avatar);
            mBinding.name.setText(userInfo.userName);

            if (mIsApplyView) {
                mBinding.cancel.setOnClickListener(v -> listener.onOption(OnOptionSelected.ACTION_CANCEL, userInfo));
                mBinding.ok.setOnClickListener(v -> listener.onOption(OnOptionSelected.ACTION_OK, userInfo));
            } else {
                int status = userInfo.userStatus;
                if (status == UserStatus.INTERACT) {
                    mBinding.ok.setText(R.string.button_user_list_guest);
                    mBinding.ok.setSelected(true);
                } else if (status == UserStatus.INVITING) {
                    mBinding.ok.setText(R.string.button_user_list_invited);
                    mBinding.ok.setSelected(true);
                } else if (status == UserStatus.APPLYING) {
                    mBinding.ok.setText(R.string.button_user_list_accept);
                    mBinding.ok.setSelected(false);
                } else {
                    mBinding.ok.setText(R.string.button_user_list_invited_guest);
                    mBinding.ok.setSelected(false);
                }

                mBinding.ok.setOnClickListener(v -> listener.onOption(OnOptionSelected.ACTION_OK, userInfo));
            }
        }
    }
}
