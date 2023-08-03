// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import android.annotation.SuppressLint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.annotation.LivePermitType;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveCoHostItemBinding;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkApplyEvent;
import com.videoone.avatars.Avatars;
import com.vertcdemo.solution.interactivelive.util.BVH;
import com.vertcdemo.core.utils.DebounceClickListener;

import java.util.ArrayList;
import java.util.List;

public class ApplicationAdapter extends RecyclerView.Adapter<BVH<LayoutLiveCoHostItemBinding>> {
    public static final int MAX_LINK_COUNT = 6;

    @FunctionalInterface
    public interface OnItemClickedListener2 {
        void onClick(AudienceLinkApplyEvent event, @LivePermitType int permitType);
    }

    @NonNull
    private final List<AudienceLinkRequest> mItems;

    @NonNull
    private final OnItemClickedListener2 mListener;

    private int mLinkedCount = 0;

    public ApplicationAdapter(List<AudienceLinkRequest> items, @NonNull OnItemClickedListener2 listener) {
        mItems = new ArrayList<>(items);
        mListener = listener;
    }

    public void setLinkedCount(int count) {
        boolean needNotifyChanged = (mLinkedCount >= MAX_LINK_COUNT && count < MAX_LINK_COUNT) || (mLinkedCount < MAX_LINK_COUNT && count >= MAX_LINK_COUNT);
        mLinkedCount = count;
        if (needNotifyChanged) {
            notifyItemRangeChanged(0, mItems.size());
        }
    }

    @NonNull
    @Override
    public BVH<LayoutLiveCoHostItemBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        final LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        LayoutLiveCoHostItemBinding binding = LayoutLiveCoHostItemBinding.inflate(inflater, parent, false);

        return new BVH<>(binding.getRoot(), binding);
    }

    @SuppressLint("SetTextI18n")
    @Override
    public void onBindViewHolder(@NonNull BVH<LayoutLiveCoHostItemBinding> holder, int position) {
        final AudienceLinkRequest request = mItems.get(position);
        final LiveUserInfo info = request.event.applicant;

        final LayoutLiveCoHostItemBinding binding = holder.binding;
        binding.position.setText(Integer.toString(position + 1));

        Glide.with(binding.avatar)
                .load(Avatars.byUserId(info.userId))
                .circleCrop()
                .into(binding.avatar);

        binding.name.setText(info.userName);

        binding.cancel.setText(R.string.reject_audience_link);
        binding.cancel.setVisibility(View.VISIBLE);
        binding.cancel.setOnClickListener(DebounceClickListener.create(v -> mListener.onClick(request.event, LivePermitType.REJECT)));

        binding.ok.setText(R.string.agree_audience_link);
        binding.ok.setOnClickListener(DebounceClickListener.create(v -> mListener.onClick(request.event, LivePermitType.ACCEPT)));
        binding.ok.setEnabled(mLinkedCount < MAX_LINK_COUNT);
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void addItem(AudienceLinkApplyEvent event) {
        int oldPosition = -1;
        for (int i = 0; i < mItems.size(); i++) {
            final AudienceLinkRequest request = mItems.get(i);
            if (request.sameUser(event.applicant.userId)) {
                mItems.remove(i);
                oldPosition = i;
                break;
            }
        }
        mItems.add(new AudienceLinkRequest(event));
        if (oldPosition == -1) {
            notifyItemInserted(mItems.size() - 1);
        } else {
            notifyItemMoved(oldPosition, mItems.size() - 1);
        }
    }

    public void removeItem(String userId) {
        for (int i = 0; i < mItems.size(); i++) {
            final AudienceLinkRequest request = mItems.get(i);
            if (request.sameUser(userId)) {
                mItems.remove(i);
                notifyItemRemoved(i);
                return;
            }
        }
    }
}

