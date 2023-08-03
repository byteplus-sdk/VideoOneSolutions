// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.graphics.Typeface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.WindowCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.vertcdemo.app.R;
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class MainFragment extends Fragment {

    private TextView mTabScenes;
    private TextView mTabProfile;

    private static final String TAG_SCENES = "fragment_tag_scenes";
    private static final String TAG_PROFILE = "fragment_tag_profile";

    private Fragment mFragmentScenes;
    private Fragment mFragmentProfile;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_main, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        mTabScenes = view.findViewById(R.id.tab_scenes);
        mTabScenes.setOnClickListener(v -> switchMainLayout(true));

        mTabProfile = view.findViewById(R.id.tab_profile);
        mTabProfile.setOnClickListener(v -> switchMainLayout(false));

        initFragments();

        switchMainLayout(true);

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    private void initFragments() {
        final FragmentManager fragmentManager = getChildFragmentManager();
        Fragment tabScene = fragmentManager.findFragmentByTag(TAG_SCENES);
        if (tabScene == null) {
            tabScene = new SceneEntryFragment();
            fragmentManager
                    .beginTransaction()
                    .add(R.id.tab_content, tabScene, TAG_SCENES)
                    .commit();
        }

        mFragmentScenes = tabScene;

        Fragment tabProfile = fragmentManager.findFragmentByTag(TAG_PROFILE);
        if (tabProfile == null) {
            tabProfile = new ProfileFragment();
            fragmentManager
                    .beginTransaction()
                    .add(R.id.tab_content, tabProfile, TAG_PROFILE)
                    .commit();
        }
        mFragmentProfile = tabProfile;
    }

    private void switchMainLayout(boolean isEntrance) {
        mTabScenes.setSelected(isEntrance);
        mTabProfile.setSelected(!isEntrance);

        WindowCompat.getInsetsController(requireActivity().getWindow(), requireView())
                .setAppearanceLightStatusBars(!isEntrance);

        if (isEntrance) {
            mTabScenes.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
            mTabProfile.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            getChildFragmentManager()
                    .beginTransaction()
                    .hide(mFragmentProfile)
                    .show(mFragmentScenes)
                    .commit();
        } else {
            mTabProfile.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
            mTabScenes.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            getChildFragmentManager()
                    .beginTransaction()
                    .hide(mFragmentScenes)
                    .show(mFragmentProfile)
                    .commit();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        switchMainLayout(true);
    }
}
