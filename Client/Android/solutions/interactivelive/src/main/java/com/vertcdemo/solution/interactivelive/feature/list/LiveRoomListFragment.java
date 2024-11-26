// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveViewModel.RTC_STATUS_DONE;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveViewModel.RTC_STATUS_NONE;

import android.Manifest;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.NavGraph;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveRoomsBinding;
import com.vertcdemo.solution.interactivelive.feature.InteractiveLiveViewModel;
import com.vertcdemo.ui.CenteredToast;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;


/**
 * interact room list page
 */
public class LiveRoomListFragment extends Fragment {

    LiveRoomListViewModel mViewModel;
    InteractiveLiveViewModel mLiveViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(LiveRoomListViewModel.class);
        mLiveViewModel = new ViewModelProvider(requireActivity()).get(InteractiveLiveViewModel.class);

        getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onResume(@NonNull LifecycleOwner owner) {
                WindowCompat.getInsetsController(requireActivity().getWindow(), requireView())
                        .setAppearanceLightStatusBars(true);
            }
        });
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_live_rooms, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        FragmentLiveRoomsBinding binding = FragmentLiveRoomsBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.settings.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.live_core_config);
        });

        binding.back.setOnClickListener(v -> {
            requireActivity().onBackPressed();
        });

        binding.swipeLayout.setOnRefreshListener(() -> {
            final Integer statusValue = mLiveViewModel.rtcStatus.getValue();
            assert statusValue != null;
            if (statusValue == RTC_STATUS_DONE) {
                mViewModel.requestRoomList();
            }
        });

        LiveRoomListAdapter roomListAdapter = new LiveRoomListAdapter(requireContext());
        binding.recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.recycler.addItemDecoration(new LiveRoomItemDecoration());
        binding.recycler.setAdapter(roomListAdapter);

        binding.goLive.setOnClickListener(
                DebounceClickListener.create(v -> {
                            launcher.launch(new String[]{
                                    Manifest.permission.CAMERA,
                                    Manifest.permission.RECORD_AUDIO,
                            });
                        }
                ));

        mViewModel.rooms.observe(getViewLifecycleOwner(), rooms -> {
            binding.swipeLayout.setRefreshing(false);
            final List<LiveRoomInfo> list = rooms == null ? Collections.emptyList() : rooms;
            roomListAdapter.updateList(list);
            binding.empty.setVisibility(list.isEmpty() ? View.VISIBLE : View.GONE);
        });

        mLiveViewModel.rtcStatus.observe(getViewLifecycleOwner(), status -> {
            switch (status) {
                case RTC_STATUS_NONE:
                    break;
                case RTC_STATUS_DONE:
                    binding.swipeLayout.setRefreshing(true);
                    mViewModel.requestRoomList();
                    break;
            }
        });

        mViewModel.licenseResult.observe(getViewLifecycleOwner(), licenseResult -> {
            if (licenseResult.isEmpty()) {
                mViewModel.checkLicense(requireContext().getApplicationContext());
            } else if (!licenseResult.isOk()) {
                binding.licenseTips.setText(licenseResult.message);
                binding.licenseTips.setVisibility(View.VISIBLE);
                binding.licenseTips.setOnClickListener(v -> {/*consume the click event*/});
            }
        });
    }

    final ActivityResultLauncher<String[]> launcher = registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(), results -> {
        for (Map.Entry<String, Boolean> entry : results.entrySet()) {
            if (entry.getValue() != Boolean.TRUE) {
                CenteredToast.show(R.string.go_live_need_permission);
                return;
            }
        }
        NavController navController = Navigation.findNavController(requireView());
        NavGraph graph = navController.getGraph();
        NavGraph roomGraph = Objects.requireNonNull((NavGraph) graph.findNode(R.id.room));
        roomGraph.setStartDestination(R.id.create_live_room);

        navController.navigate(R.id.create_live_room);
    });
}
