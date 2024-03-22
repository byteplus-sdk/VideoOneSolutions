// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.Guideline;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveSummary;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveSummaryBinding;
import com.videoone.avatars.Avatars;

import java.text.DecimalFormat;

public class LiveSummaryFragment extends Fragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_live_summary, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        FragmentLiveSummaryBinding binding = FragmentLiveSummaryBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(binding.guidelineTop, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            Guideline guideline = (Guideline) v;
            guideline.setGuidelineBegin(insets.top);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.back.setOnClickListener(v -> Navigation.findNavController(v).popBackStack());
        binding.backToHomepage.setOnClickListener(v -> Navigation.findNavController(v).popBackStack());

        final Bundle arguments = requireArguments();
        LiveSummary summary = arguments.getParcelable("summary");
        final long duration = arguments.getLong("duration");

        Glide.with(binding.userAvatar)
                .load(Avatars.byUserId(SolutionDataManager.ins().getUserId()))
                .into(binding.userAvatar);

        binding.title.setText(getString(R.string.live_show_suffix, SolutionDataManager.ins().getUserName()));
        binding.duration.setText(getString(R.string.live_show_duration_mins, duration / 1000 / 60));

        binding.viewers.setText(formatViews(summary.viewers));
        binding.likes.setText(formatKiloSeparated(summary.likes));
        binding.gifts.setText(formatKiloSeparated(summary.gifts));
    }

    private String formatViews(int viewers) {
        if (viewers < 1000) {
            return new DecimalFormat("#").format(viewers);
        } else {
            return new DecimalFormat(",###.#K").format(viewers / 1000.F);
        }
    }

    private String formatKiloSeparated(int num) {
        return new DecimalFormat(",###").format(num);
    }
}
