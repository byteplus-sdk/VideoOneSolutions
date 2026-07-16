// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.vod.function.fragment;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;
import androidx.core.view.OnApplyWindowInsetsListener;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;

import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vodfunction.R;
import com.byteplus.vodfunction.databinding.VevodFragmentCastingDispatchBinding;
import com.byteplus.vodfunction.databinding.VevodLayoutCastingModeItemBinding;


public class CastingDispatchFragment extends Fragment {

    private static final int[] SCENES = {PlayScene.SCENE_SHORT, PlayScene.SCENE_LONG};

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.vevod_fragment_casting_dispatch, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        WindowCompat.getInsetsController(
                requireActivity().getWindow(), requireView()
        ).setAppearanceLightStatusBars(true);
        VevodFragmentCastingDispatchBinding binding = VevodFragmentCastingDispatchBinding.bind(view);
        ViewCompat.setOnApplyWindowInsetsListener(view, new OnApplyWindowInsetsListener() {
            @NonNull
            @Override
            public WindowInsetsCompat onApplyWindowInsets(@NonNull View v, @NonNull WindowInsetsCompat windowInsets) {
                Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                binding.guidelineTop.setGuidelineBegin(insets.top);
                return windowInsets;
            }
        });
        binding.back.setOnClickListener(v -> {
            Activity activity = getActivity();
            if (activity == null) return;
            getActivity().getOnBackPressedDispatcher().onBackPressed();
        });

        for (int scene : SCENES) {
            VevodLayoutCastingModeItemBinding itemBinding =
                    VevodLayoutCastingModeItemBinding.inflate(getLayoutInflater(), binding.settingContainer, false);
            String title = scene == PlayScene.SCENE_SHORT ? getString(R.string.vevod_short_video_mode) : getString(R.string.vevod_long_video_mode);
            itemBinding.key.setText(title);
            itemBinding.getRoot().setOnClickListener(v -> {
//                VideoActivity
            });
        }
    }
}
