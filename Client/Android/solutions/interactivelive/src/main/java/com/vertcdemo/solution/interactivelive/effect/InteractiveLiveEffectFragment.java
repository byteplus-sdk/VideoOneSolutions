// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.effect;

import android.os.Bundle;

import androidx.annotation.IdRes;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.viewmodel.MutableCreationExtras;
import androidx.navigation.NavBackStackEntry;
import androidx.navigation.NavController;
import androidx.navigation.fragment.NavHostFragment;

import com.vertcdemo.effect.ui.EffectFragment;
import com.vertcdemo.effect.ui.EffectViewModel;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;

public class InteractiveLiveEffectFragment extends EffectFragment {
    public static final String EXTRA_NAVIGATION_ID = "navigation_id";

    @MainThread
    @NonNull
    public EffectViewModel getEffectViewModel() {
        int navigationId = getNavigationId();

        NavController navController = NavHostFragment.findNavController(this);
        NavBackStackEntry backStackEntry = navController.getBackStackEntry(navigationId);

        LiveRTCManager.ins().getVideoEffectInterface();
        MutableCreationExtras extras = new MutableCreationExtras();
        extras.set(EffectViewModel.KEY_EFFECT, new RTCVideoEffect(LiveRTCManager.ins().getVideoEffectInterface()));
        return new ViewModelProvider(
                backStackEntry.getViewModelStore(),
                ViewModelProvider.Factory.from(EffectViewModel.getInitializer()),
                extras
        ).get(EffectViewModel.class);
    }

    @IdRes
    private int getNavigationId() {
        Bundle arguments = getArguments();
        if (arguments == null) {
            return R.id.room_host;
        }
        return arguments.getInt(EXTRA_NAVIGATION_ID, R.id.room_host);
    }
}
