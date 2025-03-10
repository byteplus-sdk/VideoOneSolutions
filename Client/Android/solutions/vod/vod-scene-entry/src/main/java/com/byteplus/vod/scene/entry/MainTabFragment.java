// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scene.entry;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.core.content.res.ResourcesCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.byteplus.vod.scene.entry.databinding.VevodMainTabFragmentBinding;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.settingskit.SettingsFragment;
import com.byteplus.voddemo.ui.video.scene.feedvideo.FeedVideoFragment;
import com.byteplus.voddemo.ui.video.scene.longvideo.LongVideoFragment;
import com.byteplus.voddemo.ui.video.scene.shortvideo.ShortVideoFragment;

public class MainTabFragment extends Fragment {
    private static final String TAG = "MainTabFragment";

    private MainTabViewModel viewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        viewModel = new ViewModelProvider(this).get(MainTabViewModel.class);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.vevod_main_tab_fragment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodMainTabFragmentBinding binding = VevodMainTabFragmentBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.actionBar.getRoot().setPadding(0, insets.top, 0, 0);
            binding.bottomBar.setPadding(0, 0, 0, insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.actionBar.back.setOnClickListener(v -> requireActivity().onBackPressed());

        binding.viewPager.setAdapter(new PlaySceneAdapter(this));
        binding.viewPager.setUserInputEnabled(false);
        binding.viewPager.setOffscreenPageLimit(4);

        viewModel.currentTab.observe(getViewLifecycleOwner(), position -> {
            binding.viewPager.setCurrentItem(position, false);

            Typeface bold = Typeface.defaultFromStyle(Typeface.BOLD);
            Typeface normal = Typeface.defaultFromStyle(Typeface.NORMAL);

            binding.tabHome.setSelected(position == MainTabViewModel.TAB_MAIN);
            binding.tabHome.setTypeface(position == MainTabViewModel.TAB_MAIN ? bold : normal);

            binding.tabFeed.setSelected(position == MainTabViewModel.TAB_FEED);
            binding.tabFeed.setTypeface(position == MainTabViewModel.TAB_FEED ? bold : normal);

            binding.tabChannel.setSelected(position == MainTabViewModel.TAB_CHANNEL);
            binding.tabChannel.setTypeface(position == MainTabViewModel.TAB_CHANNEL ? bold : normal);

            binding.tabSettings.setSelected(position == MainTabViewModel.TAB_SETTINGS);
            binding.tabSettings.setTypeface(position == MainTabViewModel.TAB_SETTINGS ? bold : normal);

            WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(requireActivity().getWindow(), requireView());
            if (position == MainTabViewModel.TAB_SETTINGS || position == MainTabViewModel.TAB_CHANNEL) {
                controller.setAppearanceLightStatusBars(true);
                controller.setAppearanceLightNavigationBars(true);
            } else {
                controller.setAppearanceLightStatusBars(false);
                controller.setAppearanceLightNavigationBars(false);
            }

            if (position == MainTabViewModel.TAB_MAIN || position == MainTabViewModel.TAB_CHANNEL) {
                binding.actionBar.getRoot().setBackgroundColor(Color.TRANSPARENT);
                binding.actionBar.title.setText("");

                ConstraintSet constraints = new ConstraintSet();
                constraints.clone(binding.getRoot());
                constraints.connect(R.id.view_pager, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP);
                constraints.applyTo(binding.getRoot());
            } else if (position == MainTabViewModel.TAB_FEED) {
                binding.actionBar.getRoot().setBackgroundColor(Color.BLACK);
                binding.actionBar.title.setTextColor(Color.WHITE);
                binding.actionBar.title.setText(R.string.vevod_feed_video_title);

                ConstraintSet constraints = new ConstraintSet();
                constraints.clone(binding.getRoot());
                constraints.connect(R.id.view_pager, ConstraintSet.TOP, R.id.action_bar, ConstraintSet.BOTTOM);
                constraints.applyTo(binding.getRoot());
            } else if (position == MainTabViewModel.TAB_SETTINGS) {
                binding.actionBar.getRoot().setBackgroundColor(Color.WHITE);
                binding.actionBar.title.setTextColor(Color.BLACK);
                binding.actionBar.title.setText(R.string.vevod_settings_activity_title);

                ConstraintSet constraints = new ConstraintSet();
                constraints.clone(binding.getRoot());
                constraints.connect(R.id.view_pager, ConstraintSet.TOP, R.id.action_bar, ConstraintSet.BOTTOM);
                constraints.applyTo(binding.getRoot());
            }

            if (position == MainTabViewModel.TAB_CHANNEL || position == MainTabViewModel.TAB_SETTINGS) { // light theme
                binding.bottomBar.setBackgroundColor(Color.WHITE);

                setCompoundDrawablesTop(binding.tabHome, R.drawable.vevod_ic_tab_home_dark);
                setCompoundDrawablesTop(binding.tabFeed, R.drawable.vevod_ic_tab_feed_dark);
                setCompoundDrawablesTop(binding.tabChannel, R.drawable.vevod_ic_tab_channel_dark);
                setCompoundDrawablesTop(binding.tabSettings, R.drawable.vevod_ic_tab_settings_dark);

                ColorStateList color = ResourcesCompat.getColorStateList(getResources(), R.color.vevod_tab_text_color_dark, null);
                binding.tabHome.setTextColor(color);
                binding.tabFeed.setTextColor(color);
                binding.tabChannel.setTextColor(color);
                binding.tabSettings.setTextColor(color);

                binding.creative.setImageResource(R.drawable.vevod_ic_tab_creative_dark);
            } else {
                binding.bottomBar.setBackgroundColor(Color.BLACK);

                setCompoundDrawablesTop(binding.tabHome, R.drawable.vevod_ic_tab_home_light);
                setCompoundDrawablesTop(binding.tabFeed, R.drawable.vevod_ic_tab_feed_light);
                setCompoundDrawablesTop(binding.tabChannel, R.drawable.vevod_ic_tab_channel_light);
                setCompoundDrawablesTop(binding.tabSettings, R.drawable.vevod_ic_tab_settings_light);

                ColorStateList color = ResourcesCompat.getColorStateList(getResources(), R.color.vevod_tab_text_color_light, null);
                binding.tabHome.setTextColor(color);
                binding.tabFeed.setTextColor(color);
                binding.tabChannel.setTextColor(color);
                binding.tabSettings.setTextColor(color);

                binding.creative.setImageResource(R.drawable.vevod_ic_tab_creative_light);
            }
        });

        viewModel.licenseResult.observe(getViewLifecycleOwner(), licenseResult -> {
            if (licenseResult.isEmpty()) {
                viewModel.checkLicense(requireContext().getApplicationContext());
            } else if (!licenseResult.isOk()) {
                binding.licenseTips.setText(licenseResult.message);
                binding.licenseTips.setVisibility(View.VISIBLE);
                binding.licenseTips.setOnClickListener(v -> {/*consume the click event*/});
            }
        });

        binding.tabHome.setOnClickListener(v -> viewModel.currentTab.setValue(MainTabViewModel.TAB_MAIN));
        binding.tabFeed.setOnClickListener(v -> viewModel.currentTab.setValue(MainTabViewModel.TAB_FEED));
        binding.tabChannel.setOnClickListener(v -> viewModel.currentTab.setValue(MainTabViewModel.TAB_CHANNEL));
        binding.tabSettings.setOnClickListener(v -> viewModel.currentTab.setValue(MainTabViewModel.TAB_SETTINGS));

        binding.creative.setOnClickListener(this::startupCreative);
        binding.creative.setVisibility(View.GONE);
    }

    void startupCreative(View v) {
        try {
            Context context = requireContext();
            Intent intent = new Intent(context.getPackageName() + ".action.CREATIVE");
            intent.setPackage(context.getPackageName());
            startActivity(intent);
        } catch (ActivityNotFoundException anfe) {
            Toast.makeText(requireContext(), R.string.vevod_not_support_ck_error, Toast.LENGTH_LONG).show();
            Log.d(TAG, "Failed to startup CREATIVE", anfe);
        }
    }

    static class PlaySceneAdapter extends FragmentStateAdapter {

        public PlaySceneAdapter(@NonNull Fragment fragment) {
            super(fragment);
        }

        @NonNull
        @Override
        public Fragment createFragment(int position) {
            switch (position) {
                case MainTabViewModel.TAB_MAIN:
                    return ShortVideoFragment.newInstance();
                case MainTabViewModel.TAB_FEED:
                    return FeedVideoFragment.newInstance();
                case MainTabViewModel.TAB_CHANNEL:
                    return LongVideoFragment.newInstance();
                case MainTabViewModel.TAB_SETTINGS:
                    return SettingsFragment.newInstance(VideoSettings.KEY);
                default:
                    throw new IndexOutOfBoundsException("Index out of range: " + position);
            }
        }

        @Override
        public int getItemCount() {
            return 4;
        }
    }

    private static void setCompoundDrawablesTop(TextView view, int drawableTop) {
        view.setCompoundDrawablesRelativeWithIntrinsicBounds(
                ResourcesCompat.ID_NULL,
                drawableTop,
                ResourcesCompat.ID_NULL,
                ResourcesCompat.ID_NULL
        );
    }
}
