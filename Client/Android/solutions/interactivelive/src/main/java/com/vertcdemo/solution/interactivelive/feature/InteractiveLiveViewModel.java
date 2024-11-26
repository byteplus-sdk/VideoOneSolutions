// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.http.LiveService;

public class InteractiveLiveViewModel extends ViewModel {

    public static final int RTC_STATUS_NONE = 0;
    public static final int RTC_STATUS_DONE = 1;

    public MutableLiveData<Integer> rtcStatus = new MutableLiveData<>(RTC_STATUS_NONE);

    public void setAppInfo(@NonNull RTCAppInfo info) {
        LiveService.get().setAppId(info.appId);
        LiveRTCManager.ins().createEngine(info.appId, info.bid);
        rtcStatus.postValue(RTC_STATUS_DONE);
    }

    @Override
    protected void onCleared() {
        LiveRTCManager.ins().destroyEngine();
        LiveRTCManager.ins().destroyEffectDialog();
    }
}
