// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.room;

import static com.vertcdemo.solution.ktv.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.databinding.FragmentKtvRoomHeaderBinding;
import com.vertcdemo.solution.ktv.event.AudioStatsEvent;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class KTVRoomHeaderFragment extends Fragment {
    private static final boolean SHOW_LOST_RATE = false;

    public KTVRoomHeaderFragment() {
        super(R.layout.fragment_ktv_room_header);
    }

    private FragmentKtvRoomHeaderBinding binding;

    private KTVRoomViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        binding = FragmentKtvRoomHeaderBinding.bind(view);

        mViewModel.roomName.observe(getViewLifecycleOwner(), roomName -> {
            binding.title.setText(roomName);
        });

        mViewModel.audienceCount.observe(getViewLifecycleOwner(), audienceCount -> {
            binding.audienceNum.setText(String.valueOf(audienceCount + 1));
        });

        binding.powerButton.setOnClickListener(v -> {
            KTVRoomFragment parent = (KTVRoomFragment) requireParentFragment();
            parent.attemptLeave();
        });


        binding.rttValue.setText(getString(R.string.label_rtt_value_xxx, 0));

        if (SHOW_LOST_RATE) {
            binding.packageDownLostRate.setVisibility(View.VISIBLE);
            binding.packageUpLostRate.setVisibility(View.VISIBLE);
            binding.packageDownLostRateValue.setText(getString(R.string.ktv_plr_value_percent, 0.f));
            binding.packageUpLostRateValue.setText(getString(R.string.ktv_plr_value_percent, 0.f));
        } else {
            binding.packageDownLostRate.setVisibility(View.GONE);
            binding.packageUpLostRate.setVisibility(View.GONE);
        }

        SolutionEventBus.register(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudioStatsEvent(AudioStatsEvent event) {
        binding.rttValue.setText(getString(R.string.label_rtt_value_xxx, event.rtt));
        if (SHOW_LOST_RATE) {
            binding.packageDownLostRateValue.setText(getString(R.string.ktv_plr_value_percent, event.download * 100));
            binding.packageUpLostRateValue.setText(getString(R.string.ktv_plr_value_percent, event.upload * 100));
        }
    }

    @Override
    public void onDestroyView() {
        SolutionEventBus.unregister(this);
        super.onDestroyView();
    }
}
