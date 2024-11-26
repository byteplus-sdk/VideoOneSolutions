// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import static com.vertcdemo.solution.interactivelive.feature.main.audiencelink.IndexedItem.mapIndexed;

import android.annotation.SuppressLint;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.annotation.LivePermitType;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveCoHostItemBinding;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkApplyEvent;
import com.vertcdemo.solution.interactivelive.util.BVH;
import com.videoone.avatars.Avatars;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ApplicationAdapter extends RecyclerView.Adapter<BVH<LayoutLiveCoHostItemBinding>> {
    public static final int MAX_LINK_COUNT = 6;

    @FunctionalInterface
    public interface OnItemClickedListener2 {
        void onClick(AudienceLinkApplyEvent event, @LivePermitType int permitType);
    }

    @NonNull
    private List<IndexedItem<AudienceLinkRequest>> mItems;
    @NonNull
    private final List<AudienceLinkRequest> mRequests;

    @NonNull
    private final OnItemClickedListener2 mListener;

    private int mLinkedCount = 0;

    public ApplicationAdapter(@NonNull List<AudienceLinkRequest> items, @NonNull OnItemClickedListener2 listener) {
        mRequests = new ArrayList<>(items);
        mItems = mapIndexed(items);
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
        IndexedItem<AudienceLinkRequest> item = mItems.get(position);
        final AudienceLinkRequest request = item.data;
        final LiveUserInfo info = request.event.applicant;

        final LayoutLiveCoHostItemBinding binding = holder.binding;
        binding.position.setText(Integer.toString(item.index + 1));

        Glide.with(binding.avatar)
                .load(Avatars.byUserId(info.userId))
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
        Iterator<AudienceLinkRequest> iterator = mRequests.iterator();
        while (iterator.hasNext()) {
            final AudienceLinkRequest request = iterator.next();
            if (request.sameUser(event.applicant.userId)) {
                iterator.remove();
                break;
            }
        }
        mRequests.add(new AudienceLinkRequest(event));

        updateItems(mapIndexed(mRequests));
    }

    public void removeItem(String userId) {
        boolean updated = false;
        Iterator<AudienceLinkRequest> iterator = mRequests.iterator();
        while (iterator.hasNext()) {
            final AudienceLinkRequest request = iterator.next();
            if (request.sameUser(userId)) {
                iterator.remove();
                updated = true;
                break;
            }
        }

        if (updated) {
            updateItems(mapIndexed(mRequests));
        }
    }

    private void updateItems(List<IndexedItem<AudienceLinkRequest>> newItems) {
        List<IndexedItem<AudienceLinkRequest>> oldItems = mItems;
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
                IndexedItem<AudienceLinkRequest> oldItem = oldItems.get(oldItemPosition);
                IndexedItem<AudienceLinkRequest> newItem = newItems.get(newItemPosition);
                return oldItem.index == newItem.index && oldItem.data == newItem.data;
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                IndexedItem<AudienceLinkRequest> oldItem = oldItems.get(oldItemPosition);
                IndexedItem<AudienceLinkRequest> newItem = newItems.get(newItemPosition);

                AudienceLinkRequest oldData = oldItem.data;
                AudienceLinkRequest newData = newItem.data;
                return oldItem.index == newItem.index
                        && oldData == newData
                        && TextUtils.equals(oldData.event.linkerId, newData.event.linkerId)
                        && TextUtils.equals(oldData.event.applicant.userId, oldData.event.applicant.userId);
            }
        }).dispatchUpdatesTo(this);
    }
}

