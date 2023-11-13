// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import android.annotation.SuppressLint;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveLinkedAudienceItemBinding;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkStatusEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;
import com.videoone.avatars.Avatars;
import com.vertcdemo.solution.interactivelive.util.BVH;
import com.vertcdemo.core.utils.DebounceClickListener;

import java.util.ArrayList;
import java.util.List;

public class LinkedAudiencesAdapter extends RecyclerView.Adapter<BVH<LayoutLiveLinkedAudienceItemBinding>> {

    public interface OnItemClickedListener2 {
        int BUTTON_MICROPHONE = 1;
        int BUTTON_CAMERA = 2;
        int BUTTON_HANGUP = 3;

        void onClick(LinkedAudienceItem item, int button);
    }

    private List<LinkedAudienceItem> mItems;

    private final OnItemClickedListener2 mListener;

    public LinkedAudiencesAdapter(List<LiveUserInfo> users, OnItemClickedListener2 listener) {
        this.mItems = map(users);
        this.mListener = listener;
    }

    @NonNull
    @Override
    public BVH<LayoutLiveLinkedAudienceItemBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        final LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        LayoutLiveLinkedAudienceItemBinding binding = LayoutLiveLinkedAudienceItemBinding.inflate(inflater, parent, false);
        return new BVH<>(binding.getRoot(), binding);
    }

    @SuppressLint("SetTextI18n")
    @Override
    public void onBindViewHolder(@NonNull BVH<LayoutLiveLinkedAudienceItemBinding> holder, int position) {
        final LinkedAudienceItem item = mItems.get(position);
        final LiveUserInfo info = item.info;

        final LayoutLiveLinkedAudienceItemBinding binding = holder.binding;
        binding.position.setText(Integer.toString(position + 1));

        Glide.with(binding.avatar)
                .load(Avatars.byUserId(info.userId))
                .circleCrop()
                .into(binding.avatar);

        binding.name.setText(info.userName);

        binding.camera.setSelected(item.cameraOn);
        binding.camera.setEnabled(item.cameraOn); // Can ONLY close audience camera
        binding.microphone.setSelected(item.microphoneOn);
        binding.microphone.setEnabled(item.microphoneOn);  // Can ONLY close audience microphone

        binding.microphone.setOnClickListener(DebounceClickListener.create(v -> {
            mListener.onClick(item, OnItemClickedListener2.BUTTON_MICROPHONE);
        }));
        binding.camera.setOnClickListener(DebounceClickListener.create(v -> {
            mListener.onClick(item, OnItemClickedListener2.BUTTON_CAMERA);
        }));
        binding.hangup.setOnClickListener(DebounceClickListener.create(v -> {
            mListener.onClick(item, OnItemClickedListener2.BUTTON_HANGUP);
        }));
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void updateItem(AudienceLinkStatusEvent event) {
        final List<LinkedAudienceItem> oldItems = mItems;
        final List<LinkedAudienceItem> newItems = map(event.userList);

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
                return false;
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                return oldItems.get(oldItemPosition).areContentsTheSame(newItems.get(newItemPosition));
            }
        }).dispatchUpdatesTo(this);
    }

    public void clear() {
        int count = mItems.size();
        if (count == 0) {
            return;
        }
        mItems.clear();
        notifyItemRangeRemoved(0, count);
    }

    void onAudienceMediaUpdateEvent(UserMediaChangedEvent event) {
        for (int i = 0; i < mItems.size(); i++) {
            LinkedAudienceItem item = mItems.get(i);
            if (event.userId.equals(item.info.userId)) {
                item.updateMediaStatus(event);
                notifyItemChanged(i);
                break;
            }
        }
    }

    static List<LinkedAudienceItem> map(List<LiveUserInfo> users) {
        final ArrayList<LinkedAudienceItem> items = new ArrayList<>();
        final String myUserId = SolutionDataManager.ins().getUserId(); // filter out self
        for (LiveUserInfo user : users) {
            if (myUserId.equals(user.userId)) {
                continue;
            }
            items.add(new LinkedAudienceItem(user));
        }
        return items;
    }
}
