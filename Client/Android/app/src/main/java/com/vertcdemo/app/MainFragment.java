// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.graphics.Typeface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.WindowCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.vertcdemo.app.databinding.FragmentMainBinding;
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class MainFragment extends Fragment {

    private MainViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(MainViewModel.class);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_main, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        FragmentMainBinding binding = FragmentMainBinding.bind(view);

        binding.tabContent.setAdapter(new TabAdapter(this));
        binding.tabContent.setUserInputEnabled(false);

        binding.tabScenes.setOnClickListener(v -> mViewModel.currentTab.setValue(0));
        binding.tabProfile.setOnClickListener(v -> mViewModel.currentTab.setValue(1));

        mViewModel.currentTab.observe(getViewLifecycleOwner(), position -> {
            binding.tabContent.setCurrentItem(position, false);

            binding.tabScenes.setSelected(position == 0);
            binding.tabProfile.setSelected(position == 1);

            WindowCompat.getInsetsController(requireActivity().getWindow(), requireView())
                    .setAppearanceLightStatusBars(position == 1);

            if (position == 0) {
                binding.tabScenes.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                binding.tabProfile.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            } else {
                binding.tabProfile.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                binding.tabScenes.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            }
        });

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        mViewModel.currentTab.setValue(0);
    }
}

class TabAdapter extends FragmentStateAdapter {

    public TabAdapter(@NonNull Fragment fragment) {
        super(fragment);
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        if (position == 0) {
            return new SceneEntryFragment();
        } else if (position == 1) {
            return new ProfileFragment();
        }
        throw new IndexOutOfBoundsException("Index out of range: " + position);
    }

    @Override
    public int getItemCount() {
        return 2;
    }
}
