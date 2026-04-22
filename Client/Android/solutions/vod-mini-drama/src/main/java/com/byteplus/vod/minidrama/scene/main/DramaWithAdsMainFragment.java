// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.main;

import android.graphics.Typeface;
import android.os.Bundle;
import android.view.View;
import com.byteplus.playerkit.utils.L;
import android.graphics.Color;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.byteplus.minidrama.databinding.VevodMiniDramaWithAdsMainFragmentBinding;
import com.byteplus.minidrama.R;
import com.byteplus.vod.minidrama.scene.recommend.DramaRecommendVideoFragment;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import com.byteplus.vod.minidrama.scene.settings.DramaSettingsFragment;
import com.byteplus.vod.minidrama.scene.theater.DramaTheaterFragment;

public class DramaWithAdsMainFragment extends Fragment {
    private WithAdsMainFragmentViewModel viewModel;

    public DramaWithAdsMainFragment() {
        super(R.layout.vevod_mini_drama_with_ads_main_fragment);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        DramaSettings.enableAds(true);
        super.onCreate(savedInstanceState);
        viewModel = new ViewModelProvider(this).get(WithAdsMainFragmentViewModel.class);
    }

    @Override
    public void onDestroyView() {
        DramaSettings.enableAds(false);
        super.onDestroyView();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodMiniDramaWithAdsMainFragmentBinding binding = VevodMiniDramaWithAdsMainFragmentBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return windowInsets;
        });

        binding.actionBar.back.setOnClickListener(v -> requireActivity().onBackPressed());

        binding.viewPager.setAdapter(new DramaScenesAdapter(this));
        binding.viewPager.setUserInputEnabled(false);

        viewModel.currentTab.observe(getViewLifecycleOwner(), tab -> {
            binding.viewPager.setCurrentItem(tab.ordinal(), false);

            Typeface bold = Typeface.defaultFromStyle(Typeface.BOLD);
            Typeface normal = Typeface.defaultFromStyle(Typeface.NORMAL);

            binding.tabHome.setSelected(tab == WithAdsMainFragmentViewModel.Tab.HOME);
            binding.tabHome.setTypeface(tab == WithAdsMainFragmentViewModel.Tab.HOME ? bold : normal);

            binding.tabSettings.setSelected(tab == WithAdsMainFragmentViewModel.Tab.SETTINGS);
            binding.tabSettings.setTypeface(tab == WithAdsMainFragmentViewModel.Tab.SETTINGS ? bold : normal);

            ConstraintSet constraints = new ConstraintSet();
            constraints.clone(binding.getRoot());
            if (tab == WithAdsMainFragmentViewModel.Tab.SETTINGS) {
                binding.actionBar.getRoot().setBackgroundColor(Color.BLACK);
                binding.actionBar.title.setTextColor(Color.WHITE);
                binding.actionBar.title.setText(R.string.vevod_mini_drama_tab_settings_title);
            } else {

                binding.actionBar.getRoot().setBackgroundColor(Color.TRANSPARENT);
                binding.actionBar.title.setText("");
            }
            constraints.connect(R.id.view_pager, ConstraintSet.TOP, R.id.action_bar, ConstraintSet.BOTTOM);
            constraints.applyTo(binding.getRoot());
        });

        binding.tabHome.setOnClickListener(v -> viewModel.currentTab.setValue(WithAdsMainFragmentViewModel.Tab.HOME));
        binding.tabSettings.setOnClickListener(v -> viewModel.currentTab.setValue(WithAdsMainFragmentViewModel.Tab.SETTINGS));

        viewModel.licenseResult.observe(getViewLifecycleOwner(), licenseResult -> {
            if (licenseResult.isEmpty()) {
                viewModel.checkLicense(requireContext().getApplicationContext());
            } else if (!licenseResult.isOk()) {
                binding.licenseTips.setText(licenseResult.message);
                binding.licenseTips.setVisibility(View.VISIBLE);
                binding.licenseTips.setOnClickListener(v -> {/*consume the click event*/});
            }
        });
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
                    return new DramaSettingsFragment();
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
