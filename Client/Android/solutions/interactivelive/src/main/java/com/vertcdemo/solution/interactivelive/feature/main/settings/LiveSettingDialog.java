// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.settings;

import static com.vertcdemo.solution.interactivelive.feature.main.settings.SettingsViewModel.VIDEO_FPS_15;
import static com.vertcdemo.solution.interactivelive.feature.main.settings.SettingsViewModel.VIDEO_FPS_20;
import static com.vertcdemo.solution.interactivelive.feature.main.settings.SettingsViewModel.VIDEO_QUALITY_1080;
import static com.vertcdemo.solution.interactivelive.feature.main.settings.SettingsViewModel.VIDEO_QUALITY_540;
import static com.vertcdemo.solution.interactivelive.feature.main.settings.SettingsViewModel.VIDEO_QUALITY_720;

import android.os.Bundle;
import android.util.Range;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveVideoSettingsBinding;

public class LiveSettingDialog extends BottomSheetDialogFragment {
    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialog;
    }

    SettingsViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(SettingsViewModel.class);
        mViewModel.init();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_video_settings, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        DialogLiveVideoSettingsBinding binding = DialogLiveVideoSettingsBinding.bind(view);


        final LifecycleOwner viewLifecycleOwner = getViewLifecycleOwner();
        // region Video FPS
        mViewModel.videoFPS.observe(viewLifecycleOwner, fps -> {
            binding.fps20.setSelected(fps == VIDEO_FPS_20);
            binding.fps15.setSelected(fps == VIDEO_FPS_15);
        });
        binding.fpsToggle.setOnClickListener(v -> {
            final Integer value = mViewModel.videoFPS.getValue();
            if (value != null && value == VIDEO_FPS_20) {
                mViewModel.setVideoFPS(VIDEO_FPS_15);
            } else {
                mViewModel.setVideoFPS(VIDEO_FPS_20);
            }
        });
        // endregion

        // region Quality
        mViewModel.videoQuality.observe(viewLifecycleOwner, quality -> {
            switch (quality) {
                case VIDEO_QUALITY_1080:
                    binding.qualityValue.setText(R.string.quality_1080);
                    break;
                case VIDEO_QUALITY_720:
                    binding.qualityValue.setText(R.string.quality_720);
                    break;
                case VIDEO_QUALITY_540:
                    binding.qualityValue.setText(R.string.quality_540);
                    break;
                default:
                    throw new IllegalArgumentException("Unsupported Quality value: " + quality);
            }
            binding.quality1080.setSelected(quality == VIDEO_QUALITY_1080);
            binding.quality720.setSelected(quality == VIDEO_QUALITY_720);
            binding.quality540.setSelected(quality == VIDEO_QUALITY_540);
        });
        binding.quality1080.setOnClickListener(v -> {
            final Integer current = mViewModel.videoQuality.getValue();
            if (current == null || current != VIDEO_QUALITY_1080) {
                mViewModel.setVideoQualityAndBitrateRange(VIDEO_QUALITY_1080);
            }
            mViewModel.showQualityItem.postValue(false);
        });
        binding.quality720.setOnClickListener(v -> {
            final Integer current = mViewModel.videoQuality.getValue();
            if (current == null || current != VIDEO_QUALITY_720) {
                mViewModel.setVideoQualityAndBitrateRange(VIDEO_QUALITY_720);
            }
            mViewModel.showQualityItem.postValue(false);
        });
        binding.quality540.setOnClickListener(v -> {
            final Integer current = mViewModel.videoQuality.getValue();
            if (current == null || current != VIDEO_QUALITY_540) {
                mViewModel.setVideoQualityAndBitrateRange(VIDEO_QUALITY_540);
            }
            mViewModel.showQualityItem.postValue(false);
        });

        binding.qualityTitle.setOnClickListener(v -> mViewModel.showQualityItem.postValue(false));
        binding.layoutVideoQuality.setOnClickListener(v -> mViewModel.showQualityItem.postValue(true));
        mViewModel.showQualityItem.observe(viewLifecycleOwner, showQualityItem -> {
            binding.groupSettings.setVisibility(showQualityItem ? View.GONE : View.VISIBLE);
            binding.groupQuality.setVisibility(showQualityItem ? View.VISIBLE : View.GONE);
        });
        // endregion

        // region Video bitrate
        mViewModel.videoBitrateRange.observe(viewLifecycleOwner, range -> {
            binding.bitrateSeekbar.setMax(range.getUpper() - range.getLower());
            binding.bitrateSeekbar.setProgress(mViewModel.getVideoBitrateByProgress());
            binding.bitrateValue.setText(String.valueOf(mViewModel.currentBitrate));
        });
        Range<Integer> range = mViewModel.videoBitrateRange.getValue();
        assert range != null;
        binding.bitrateSeekbar.setMax(range.getUpper() - range.getLower());
        binding.bitrateSeekbar.setProgress(mViewModel.getVideoBitrateByProgress());
        binding.bitrateValue.setText(String.valueOf(mViewModel.currentBitrate));
        binding.bitrateSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    int bitrate = mViewModel.setVideoBitrateByProgress(progress);
                    binding.bitrateValue.setText(String.valueOf(bitrate));
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mViewModel.updateToRTCVideo();
            }
        });
        // endregion
    }
}
