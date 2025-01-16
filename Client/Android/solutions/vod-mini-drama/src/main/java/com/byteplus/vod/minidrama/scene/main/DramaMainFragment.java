// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.main;

import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.byteplus.vod.minidrama.scene.recommend.DramaRecommendVideoFragment;
import com.byteplus.vod.minidrama.scene.theater.DramaTheaterFragment;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaMainFragmentBinding;

public class DramaMainFragment extends Fragment {
    private MainFragmentViewModel viewModel;

    public DramaMainFragment() {
        super(R.layout.vevod_mini_drama_main_fragment);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        viewModel = new ViewModelProvider(this).get(MainFragmentViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodMiniDramaMainFragmentBinding binding = VevodMiniDramaMainFragmentBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.statusBars());
            binding.actionBar.getRoot().setPadding(0, insets.top, 0, 0);
            return windowInsets;
        });

        binding.actionBar.back.setOnClickListener(v -> requireActivity().onBackPressed());

        binding.viewPager.setAdapter(new DramaScenesAdapter(this));
        binding.viewPager.setUserInputEnabled(false);

        viewModel.currentTab.observe(getViewLifecycleOwner(), tab -> {
            binding.viewPager.setCurrentItem(tab.ordinal(), false);

            Typeface bold = Typeface.defaultFromStyle(Typeface.BOLD);
            Typeface normal = Typeface.defaultFromStyle(Typeface.NORMAL);

            binding.tabHome.setSelected(tab == MainFragmentViewModel.Tab.HOME);
            binding.tabHome.setTypeface(tab == MainFragmentViewModel.Tab.HOME ? bold : normal);

            binding.tabChannel.setSelected(tab == MainFragmentViewModel.Tab.CHANNEL);
            binding.tabChannel.setTypeface(tab == MainFragmentViewModel.Tab.CHANNEL ? bold : normal);

            if (tab == MainFragmentViewModel.Tab.HOME) {
                binding.actionBar.getRoot().setBackgroundColor(Color.BLACK);

                ConstraintSet constraints = new ConstraintSet();
                constraints.clone(binding.getRoot());

                constraints.connect(R.id.view_pager, ConstraintSet.TOP, R.id.action_bar, ConstraintSet.BOTTOM);
                constraints.applyTo(binding.getRoot());
            } else {
                binding.actionBar.getRoot().setBackgroundColor(Color.TRANSPARENT);

                ConstraintSet constraints = new ConstraintSet();
                constraints.clone(binding.getRoot());
                constraints.connect(R.id.view_pager, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP);
                constraints.applyTo(binding.getRoot());
            }
        });

        binding.tabHome.setOnClickListener(v -> viewModel.currentTab.setValue(MainFragmentViewModel.Tab.HOME));
        binding.tabChannel.setOnClickListener(v -> viewModel.currentTab.setValue(MainFragmentViewModel.Tab.CHANNEL));
    }

    static class DramaScenesAdapter extends FragmentStateAdapter {
        public DramaScenesAdapter(@NonNull Fragment fragment) {
            super(fragment);
        }

        @NonNull
        @Override
        public Fragment createFragment(int position) {
            switch (position) {
                case 0:
                    return new DramaTheaterFragment();
                case 1:
                    return new DramaRecommendVideoFragment();
                default:
                    throw new IndexOutOfBoundsException("Index out of range: " + position);
            }
        }

        @Override
        public int getItemCount() {
            return 2;
        }
    }
}
