// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room;

import static com.vertcdemo.solution.chorus.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.FragmentChorusRoomHeaderBinding;
import com.videoone.avatars.Avatars;

public class ChorusRoomHeaderFragment extends Fragment {
    public ChorusRoomHeaderFragment() {
        super(R.layout.fragment_chorus_room_header);
    }

    private ChorusRoomViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = navGraphViewModelProvider(this, R.id.chorus_room_graph).get(ChorusRoomViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        FragmentChorusRoomHeaderBinding binding = FragmentChorusRoomHeaderBinding.bind(view);

        binding.hostAvatar.setImageResource(Avatars.byUserId(mViewModel.hostUserId()));
        binding.hostUserId.setText(getString(R.string.id_prefix, mViewModel.requireRoomId()));

        mViewModel.roomName.observe(getViewLifecycleOwner(), roomName -> {
            binding.title.setText(roomName);
        });

        mViewModel.audienceCount.observe(getViewLifecycleOwner(), audienceCount -> {
            binding.audienceNum.setText(String.valueOf(audienceCount + 1));
        });

        binding.powerButton.setOnClickListener(v -> {
            ChorusRoomFragment parent = (ChorusRoomFragment) requireParentFragment();
            parent.attemptLeave();
        });
    }
}
