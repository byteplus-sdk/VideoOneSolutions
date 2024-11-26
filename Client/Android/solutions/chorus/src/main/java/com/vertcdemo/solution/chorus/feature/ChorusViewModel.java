// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;
import com.vertcdemo.solution.chorus.http.ChorusService;

public class ChorusViewModel extends ViewModel {
    public static final int RTC_STATUS_NONE = 0;
    public static final int RTC_STATUS_DONE = 2;

    public MutableLiveData<Integer> rtcStatus = new MutableLiveData<>(RTC_STATUS_NONE);

    public void setAppInfo(@NonNull RTCAppInfo info) {
        ChorusService.get().setAppId(info.appId);
        ChorusRTCManager.ins().createEngine(info.appId, info.bid);

        rtcStatus.postValue(RTC_STATUS_DONE);
    }

    @Override
    protected void onCleared() {
        ChorusRTCManager.ins().destroyEngine();
    }
}
