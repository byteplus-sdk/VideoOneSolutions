// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room;

import static com.vertcdemo.solution.chorus.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.DialogChorusTuningBinding;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.ss.bytertc.engine.type.VoiceReverbType;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.ui.BottomDialogFragmentX;
import com.vertcdemo.solution.chorus.bean.FinishSingInform;
import com.vertcdemo.solution.chorus.common.SolutionToast;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class ChorusTuningDialog extends BottomDialogFragmentX {
    @Override
    public int getTheme() {
        return R.style.ChorusBottomSheetDialogTheme;
    }

    private ChorusRoomViewModel mRoomViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRoomViewModel = navGraphViewModelProvider(this, R.id.chorus_room_graph).get(ChorusRoomViewModel.class);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_chorus_tuning, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        ((BottomSheetDialog) requireDialog()).getBehavior().setDraggable(false);

        DialogChorusTuningBinding binding = DialogChorusTuningBinding.bind(view);
        binding.earMonitorSwitch.setOnClickListener(v -> {
            if (!ChorusRTCManager.ins().canOpenEarMonitor()) {
                SolutionToast.show(v.getContext().getString(R.string.label_monitor_mix_tip));
                return;
            }
            boolean newValue = !v.isSelected();
            mRoomViewModel.setEarMonitorSwitch(newValue);
        });

        binding.earMonitor.title.setText(R.string.label_monitor_mix_title);
        binding.musicVolume.title.setText(R.string.label_music_volume_title);
        binding.vocalVolume.title.setText(R.string.label_vocal_volume_title);

        binding.earMonitor.seekbar.setOnSeekBarChangeListener(new MyOnSeekBarChangeAdapter() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                binding.earMonitor.value.setText(String.valueOf(progress));
                if (fromUser) {
                    mRoomViewModel.setEarMonitorVolume(progress);
                }
            }
        });

        binding.musicVolume.seekbar.setOnSeekBarChangeListener(new MyOnSeekBarChangeAdapter() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                binding.musicVolume.value.setText(String.valueOf(progress));
                if (fromUser) {
                    mRoomViewModel.setMusicVolume(progress);
                }
            }
        });

        binding.vocalVolume.seekbar.setOnSeekBarChangeListener(new MyOnSeekBarChangeAdapter() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                binding.vocalVolume.value.setText(String.valueOf(progress));
                if (fromUser) {
                    mRoomViewModel.setVocalVolume(progress);
                }
            }
        });

        binding.audioEffect.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == R.id.audio_effect_original) {
                mRoomViewModel.setAudioEffect(VoiceReverbType.VOICE_REVERB_ORIGINAL);
            } else if (checkedId == R.id.audio_effect_echo) {
                mRoomViewModel.setAudioEffect(VoiceReverbType.VOICE_REVERB_ECHO);
            } else if (checkedId == R.id.audio_effect_concert) {
                mRoomViewModel.setAudioEffect(VoiceReverbType.VOICE_REVERB_CONCERT);
            } else if (checkedId == R.id.audio_effect_ethereal) {
                mRoomViewModel.setAudioEffect(VoiceReverbType.VOICE_REVERB_ETHEREAL);
            } else if (checkedId == R.id.audio_effect_ktv) {
                mRoomViewModel.setAudioEffect(VoiceReverbType.VOICE_REVERB_KTV);
            } else if (checkedId == R.id.audio_effect_record_studio) {
                mRoomViewModel.setAudioEffect(VoiceReverbType.VOICE_REVERB_STUDIO);
            }
        });

        VoiceReverbType reverbType = mRoomViewModel.getVoiceReverbType();
        switch (reverbType) {
            case VOICE_REVERB_ECHO:
                binding.audioEffect.check(R.id.audio_effect_echo);
                break;
            case VOICE_REVERB_CONCERT:
                binding.audioEffect.check(R.id.audio_effect_concert);
                break;
            case VOICE_REVERB_ETHEREAL:
                binding.audioEffect.check(R.id.audio_effect_ethereal);
                break;
            case VOICE_REVERB_KTV:
                binding.audioEffect.check(R.id.audio_effect_ktv);
                break;
            case VOICE_REVERB_STUDIO:
                binding.audioEffect.check(R.id.audio_effect_record_studio);
                break;
            case VOICE_REVERB_ORIGINAL:
            default:
                binding.audioEffect.check(R.id.audio_effect_original);
                break;
        }
        { // Ear monitor volume
            int volume = mRoomViewModel.getEarMonitorVolume();
            binding.earMonitor.value.setText(String.valueOf(volume));
            binding.earMonitor.seekbar.setProgress(volume);
            binding.earMonitor.seekbar.setMax(100);
        }

        { // Music Volume
            int volume = mRoomViewModel.getMusicVolume();
            binding.musicVolume.value.setText(String.valueOf(volume));
            binding.musicVolume.seekbar.setProgress(volume);
            binding.musicVolume.seekbar.setMax(100);
        }

        { // Vocal volume
            int volume = mRoomViewModel.getVocalVolume();
            binding.vocalVolume.value.setText(String.valueOf(volume));
            binding.vocalVolume.seekbar.setProgress(volume);
            binding.vocalVolume.seekbar.setMax(100);
        }

        mRoomViewModel.earMonitorSwitch.observe(getViewLifecycleOwner(), on -> {
            binding.earMonitorSwitch.setSelected(on);
            if (on) {
                binding.earMonitor.getRoot().setVisibility(View.VISIBLE);
            } else {
                binding.earMonitor.getRoot().setVisibility(View.GONE);
            }
        });


        SolutionEventBus.register(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onFinishSingBroadcast(FinishSingInform event) {
        dismiss();
    }

    @Override
    public void onDestroyView() {
        SolutionEventBus.unregister(this);
        super.onDestroyView();
    }
}
