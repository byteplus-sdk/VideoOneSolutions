// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.list;

import static com.vertcdemo.solution.chorus.feature.ChorusViewModel.RTC_STATUS_DONE;
import static com.vertcdemo.solution.chorus.feature.ChorusViewModel.RTC_STATUS_NONE;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.FragmentChorusRoomsBinding;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.chorus.bean.RoomInfo;
import com.vertcdemo.solution.chorus.feature.ChorusViewModel;
import com.vertcdemo.ui.CenteredToast;

import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class ChorusRoomListFragment extends Fragment {
    ChorusRoomListViewModel mViewModel;
    ChorusViewModel mChorusViewModel;

    public ChorusRoomListFragment() {
        super(R.layout.fragment_chorus_rooms);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(ChorusRoomListViewModel.class);
        mChorusViewModel = new ViewModelProvider(requireActivity()).get(ChorusViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        WindowCompat.getInsetsController(requireActivity().getWindow(), view)
                .setAppearanceLightStatusBars(true);

        FragmentChorusRoomsBinding binding = FragmentChorusRoomsBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.back.setOnClickListener(v -> requireActivity().onBackPressed());

        binding.refresh.setOnClickListener(DebounceClickListener.create(v -> {
            int status = Objects.requireNonNull(mChorusViewModel.rtcStatus.getValue());
            if (status == RTC_STATUS_DONE) {
                binding.swipeLayout.setRefreshing(true);
                mViewModel.requestRoomList();
            }
        }));

        binding.swipeLayout.setOnRefreshListener(() -> {
            int status = Objects.requireNonNull(mChorusViewModel.rtcStatus.getValue());
            if (status == RTC_STATUS_DONE) {
                mViewModel.requestRoomList();
            } else {
                binding.swipeLayout.setRefreshing(false);
            }
        });

        ChorusRoomListAdapter roomListAdapter = new ChorusRoomListAdapter(requireContext());
        binding.recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.recycler.addItemDecoration(new ChorusRoomItemDecoration());
        binding.recycler.setAdapter(roomListAdapter);

        binding.createRoom.setOnClickListener(
                DebounceClickListener.create(v -> {
                            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.RECORD_AUDIO)
                                    == PackageManager.PERMISSION_GRANTED) {
                                Navigation.findNavController(v)
                                        .navigate(R.id.action_create_room);
                            } else {
                                launcher.launch(Manifest.permission.RECORD_AUDIO);
                            }
                        }
                ));

        mViewModel.rooms.observe(getViewLifecycleOwner(), rooms -> {
            binding.swipeLayout.setRefreshing(false);
            final List<RoomInfo> list = rooms == null ? Collections.emptyList() : rooms;
            roomListAdapter.updateList(list);
            binding.empty.setVisibility(list.isEmpty() ? View.VISIBLE : View.GONE);
        });

        mChorusViewModel.rtcStatus.observe(getViewLifecycleOwner(), status -> {
            switch (status) {
                case RTC_STATUS_NONE:
                    break;
                case RTC_STATUS_DONE:
                    binding.swipeLayout.setRefreshing(true);
                    mViewModel.requestRoomList();
                    break;
            }
        });
    }

    final ActivityResultLauncher<String> launcher = registerForActivityResult(new ActivityResultContracts.RequestPermission(), result -> {
        if (result != Boolean.TRUE) {
            CenteredToast.show(R.string.toast_chorus_need_permission);
            return;
        }
        Navigation.findNavController(requireView()).navigate(R.id.action_create_room);
    });
}