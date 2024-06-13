// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.Guideline;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;

import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveCoreConfigBinding;

public class LiveCoreConfigFragment extends Fragment {

    LiveCoreConfigViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(LiveCoreConfigViewModel.class);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_live_core_config, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        WindowCompat.getInsetsController(requireActivity().getWindow(), view)
                .setAppearanceLightStatusBars(true);

        FragmentLiveCoreConfigBinding binding = FragmentLiveCoreConfigBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(binding.guidelineTop, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            Guideline guideline = (Guideline) v;
            guideline.setGuidelineBegin(insets.top);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.back.setOnClickListener(v -> Navigation.findNavController(v).popBackStack());

        mViewModel.rtmPullStreaming.observe(getViewLifecycleOwner(), binding.rtmPullStreaming::setSelected);
        binding.rtmPullStreaming.setOnClickListener(v -> mViewModel.setRtmPullStreaming(!v.isSelected()));

        mViewModel.abr.observe(getViewLifecycleOwner(), binding.abr::setSelected);
        binding.abr.setOnClickListener(v -> mViewModel.setABR(!v.isSelected()));
    }
}
