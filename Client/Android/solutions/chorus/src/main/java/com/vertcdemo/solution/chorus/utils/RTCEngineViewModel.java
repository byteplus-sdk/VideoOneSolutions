// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.utils;

import static com.vertcdemo.core.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.viewmodel.CreationExtras;
import androidx.lifecycle.viewmodel.MutableCreationExtras;
import androidx.lifecycle.viewmodel.ViewModelInitializer;

import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;

import java.util.Objects;

public class RTCEngineViewModel extends ViewModel {

    public static final CreationExtras.Key<RTCAppInfo> RTC_INFO = new CreationExtras.Key<>() {
    };

    public RTCEngineViewModel(@NonNull RTCAppInfo info) {
        ChorusRTCManager.ins().createEngine(info.appId, info.bid);
    }

    @Override
    protected void onCleared() {
        ChorusRTCManager.ins().destroyEngine();
    }

    public static void inject(@NonNull Fragment fragment,
                              @IdRes int destinationId,
                              @NonNull RTCAppInfo rtcAppInfo) {
        MutableCreationExtras extras = new MutableCreationExtras();
        extras.set(RTCEngineViewModel.RTC_INFO, rtcAppInfo);
        navGraphViewModelProvider(
                fragment,
                destinationId,
                ViewModelProvider.Factory.from(RTCEngineViewModel.initializer),
                extras
        ).get(RTCEngineViewModel.class);
    }

    public static final ViewModelInitializer<RTCEngineViewModel> initializer = new ViewModelInitializer<>(
            RTCEngineViewModel.class,
            creationExtras -> {
                RTCAppInfo info = Objects.requireNonNull(creationExtras.get(RTC_INFO));
                return new RTCEngineViewModel(info);
            }
    );
}
