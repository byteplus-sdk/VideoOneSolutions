package com.byteplus.live.pusher.effect;

import androidx.annotation.NonNull;

import com.vertcdemo.effect.ui.EffectViewModelProvider;
import com.vertcdemo.effect.ui.EffectFragment;
import com.vertcdemo.effect.ui.EffectViewModel;

public class LiveEffectFragment extends EffectFragment {
    @NonNull
    @Override
    public EffectViewModel getEffectViewModel() {
        return ((EffectViewModelProvider) requireActivity()).getEffectViewModel();
    }
}
