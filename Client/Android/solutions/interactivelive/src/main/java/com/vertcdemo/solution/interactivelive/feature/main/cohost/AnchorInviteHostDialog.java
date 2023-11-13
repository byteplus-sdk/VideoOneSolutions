// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.cohost;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.ConcatAdapter;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.vertcdemo.solution.interactivelive.feature.bottomsheet.BottomDialogFragmentX;
import com.videoone.avatars.Avatars;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveUserStatus;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveCoHostListBinding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveCoHostItemBinding;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkInviteEvent;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkReplyEvent;
import com.vertcdemo.solution.interactivelive.util.BVH;
import com.vertcdemo.core.utils.DebounceClickListener;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Collections;
import java.util.List;

public class AnchorInviteHostDialog extends BottomDialogFragmentX {
    private DialogLiveCoHostListBinding mBinding;

    private OnlineHostAdapter mOnlineHostAdapter;

    InviteHostViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(InviteHostViewModel.class);

        final Bundle arguments = requireArguments();
        mViewModel.roomInfo = (LiveRoomInfo) arguments.getSerializable("roomInfo");
    }

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialogTheme;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_co_host_list, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mBinding = DialogLiveCoHostListBinding.bind(view);

        LinearLayoutManager manager = new LinearLayoutManager(getContext());
        mBinding.recycler.setLayoutManager(manager);
        mOnlineHostAdapter = new OnlineHostAdapter();
        mBinding.recycler.setAdapter(new ConcatAdapter(new CoHostHeaderAdapter(), mOnlineHostAdapter));

        SolutionEventBus.register(this);

        mViewModel.users.observe(getViewLifecycleOwner(), users -> {
            if (users == null || users.size() == 0) {
                mBinding.empty.setVisibility(View.VISIBLE);
                mBinding.recycler.setVisibility(View.GONE);
            } else {
                mBinding.empty.setVisibility(View.GONE);
                mBinding.recycler.setVisibility(View.VISIBLE);
                mOnlineHostAdapter.setData(users);
            }
        });

        mViewModel.requestActiveHostList();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAnchorLinkInviteEvent(AnchorLinkInviteEvent event) {
        dismiss();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAnchorLinkReplyEvent(AnchorLinkReplyEvent event) {
        dismiss();
    }

    private static class CoHostHeaderAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.layout_live_co_host_header, parent, false);
            return new RecyclerView.ViewHolder(view) {
            };
        }

        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {

        }

        @Override
        public int getItemCount() {
            return 1;
        }
    }

    class OnlineHostAdapter extends RecyclerView.Adapter<BVH<LayoutLiveCoHostItemBinding>> {

        @NonNull
        private List<LiveUserInfo> mData = Collections.emptyList();

        @NonNull
        @Override
        public BVH<LayoutLiveCoHostItemBinding> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            LayoutLiveCoHostItemBinding binding = LayoutLiveCoHostItemBinding.inflate(
                    LayoutInflater.from(parent.getContext()),
                    parent,
                    false);
            return new BVH<>(binding.getRoot(), binding);
        }

        @SuppressLint("SetTextI18n")
        @Override
        public void onBindViewHolder(@NonNull BVH<LayoutLiveCoHostItemBinding> holder, int position) {
            final LiveUserInfo info = mData.get(position);

            final LayoutLiveCoHostItemBinding binding = holder.binding;
            binding.position.setText(Integer.toString(position + 1));

            Glide.with(binding.avatar).load(Avatars.byUserId(info.userId)).circleCrop().into(binding.avatar);

            binding.name.setText(info.userName);

            switch (info.status) {
                case LiveUserStatus.HOST_INVITING:
                    binding.ok.setText(R.string.Initiate_send);
                    break;

                case LiveUserStatus.CO_HOSTING:
                    binding.ok.setText(R.string.connecting);
                    break;

                case LiveUserStatus.AUDIENCE_INTERACTING:
                case LiveUserStatus.AUDIENCE_INVITING:
                case LiveUserStatus.OTHER:
                default:
                    binding.ok.setText(R.string.invite);
                    break;
            }

            binding.ok.setOnClickListener(DebounceClickListener.create(v -> {
                mViewModel.inviteHostByHost(info);
                dismiss();
            }));
        }

        @Override
        public int getItemCount() {
            return mData.size();
        }

        public void setData(List<LiveUserInfo> info) {
            List<LiveUserInfo> oldList = mData;
            List<LiveUserInfo> newList = info == null ? Collections.emptyList() : info;
            mData = newList;

            DiffUtil.calculateDiff(new DiffUtil.Callback() {
                @Override
                public int getOldListSize() {
                    return oldList.size();
                }

                @Override
                public int getNewListSize() {
                    return newList.size();
                }

                @Override
                public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                    return oldList.get(oldItemPosition) == newList.get(newItemPosition);
                }

                @Override
                public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                    final LiveUserInfo oldInfo = oldList.get(oldItemPosition);
                    final LiveUserInfo newInfo = newList.get(newItemPosition);
                    return oldInfo.status == newInfo.status && TextUtils.equals(oldInfo.userName, newInfo.userName);
                }
            }).dispatchUpdatesTo(this);
        }
    }
}