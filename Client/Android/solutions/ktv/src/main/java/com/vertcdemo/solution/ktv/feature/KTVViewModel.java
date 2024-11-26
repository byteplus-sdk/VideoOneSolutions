// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.solution.ktv.core.KTVRTCManager;
import com.vertcdemo.solution.ktv.http.KTVService;

public class KTVViewModel extends ViewModel {

    public static final int RTC_STATUS_NONE = 0;
    public static final int RTC_STATUS_DONE = 1;

    public MutableLiveData<Integer> rtcStatus = new MutableLiveData<>(RTC_STATUS_NONE);

    public void setAppInfo(RTCAppInfo info) {
        KTVService.get().setAppId(info.appId);
        KTVRTCManager.ins().createEngine(info.appId, info.bid);
        rtcStatus.postValue(RTC_STATUS_DONE);
    }

    @Override
    protected void onCleared() {
        KTVRTCManager.ins().destroyEngine();
    }
}