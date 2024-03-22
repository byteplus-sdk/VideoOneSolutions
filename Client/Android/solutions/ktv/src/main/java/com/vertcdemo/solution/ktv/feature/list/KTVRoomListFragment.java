// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.list;

import static com.vertcdemo.solution.ktv.feature.KTVViewModel.RTS_STATUS_FAILED;
import static com.vertcdemo.solution.ktv.feature.KTVViewModel.RTS_STATUS_LOGGED;
import static com.vertcdemo.solution.ktv.feature.KTVViewModel.RTS_STATUS_LOGGING;
import static com.vertcdemo.solution.ktv.feature.KTVViewModel.RTS_STATUS_NONE;

import android.Manifest;
import android.os.Bundle;
import android.view.View;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.common.SolutionToast;
import com.vertcdemo.solution.ktv.databinding.FragmentKtvRoomsBinding;
import com.vertcdemo.solution.ktv.feature.KTVViewModel;

import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class KTVRoomListFragment extends Fragment {
    KTVRoomListViewModel mViewModel;
    KTVViewModel mKTVViewModel;

    public KTVRoomListFragment() {
        super(R.layout.fragment_ktv_rooms);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(KTVRoomListViewModel.class);
        mKTVViewModel = new ViewModelProvider(requireActivity()).get(KTVViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        WindowCompat.getInsetsController(requireActivity().getWindow(), view)
                .setAppearanceLightStatusBars(true);

        FragmentKtvRoomsBinding binding = FragmentKtvRoomsBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.back.setOnClickListener(v -> requireActivity().onBackPressed());

        binding.refresh.setOnClickListener(DebounceClickListener.create(v -> {
            int status = Objects.requireNonNull(mKTVViewModel.rtsStatus.getValue());
            if (status == RTS_STATUS_LOGGED) {
                binding.swipeLayout.setRefreshing(true);
                mViewModel.requestRoomList();
            }
        }));

        binding.swipeLayout.setOnRefreshListener(() -> {
            int status = Objects.requireNonNull(mKTVViewModel.rtsStatus.getValue());
            if (status == RTS_STATUS_LOGGED) {
                mViewModel.requestRoomList();
            } else {
                binding.swipeLayout.setRefreshing(false);
            }
        });

        KTVRoomListAdapter roomListAdapter = new KTVRoomListAdapter(requireContext());
        binding.recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.recycler.addItemDecoration(new KTVRoomItemDecoration());
        binding.recycler.setAdapter(roomListAdapter);
        binding.recycler.setItemAnimator(null);

        binding.createRoom.setOnClickListener(
                DebounceClickListener.create(v -> {
                            launcher.launch(Manifest.permission.RECORD_AUDIO);
                        }
                ));

        mViewModel.rooms.observe(getViewLifecycleOwner(), rooms -> {
            binding.swipeLayout.setRefreshing(false);
            final List<RoomInfo> list = rooms == null ? Collections.emptyList() : rooms;
            roomListAdapter.updateList(list);
            binding.empty.setVisibility(list.isEmpty() ? View.VISIBLE : View.GONE);
        });

        mKTVViewModel.rtsStatus.observe(getViewLifecycleOwner(), status -> {
            switch (status) {
                case RTS_STATUS_NONE:
                    break;
                case RTS_STATUS_LOGGING:
                    // show loading
                    break;
                case RTS_STATUS_LOGGED:
                    binding.swipeLayout.setRefreshing(true);
                    mViewModel.requestRoomList();
                    break;
                case RTS_STATUS_FAILED:
                    // failed
                    break;
            }
        });
    }

    final ActivityResultLauncher<String> launcher = registerForActivityResult(new ActivityResultContracts.RequestPermission(), result -> {
        if (result != Boolean.TRUE) {
            SolutionToast.show(R.string.toast_ktv_need_permission);
            return;
        }
        Navigation.findNavController(requireView()).navigate(R.id.action_create_ktv_room);
    });
}
