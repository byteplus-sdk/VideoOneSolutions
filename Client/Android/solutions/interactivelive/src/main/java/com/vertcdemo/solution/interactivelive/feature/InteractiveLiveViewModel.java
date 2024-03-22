// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.rts.IRTSCallback;
import com.vertcdemo.core.net.rts.RTSBaseClient;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;

public class InteractiveLiveViewModel extends ViewModel {

    public static final int RTS_STATUS_NONE = 0;
    public static final int RTS_STATUS_LOGGING = 1;
    public static final int RTS_STATUS_LOGGED = 2;
    public static final int RTS_STATUS_FAILED = 3;

    private RTSInfo rtsInfo;

    public MutableLiveData<Integer> rtsStatus = new MutableLiveData<>(RTS_STATUS_NONE);

    public void setRTSInfo(RTSInfo rtsInfo) {
        this.rtsInfo = rtsInfo;
        LiveRTCManager.ins().rtcConnect(rtsInfo);
    }

    public void loginRTS() {
        rtsStatus.postValue(RTS_STATUS_LOGGING);
        LiveRTCManager.ins().getRTSClient().login(rtsInfo.rtsToken, (resultCode, message) -> {
            if (resultCode == IRTSCallback.CODE_SUCCESS) {
                rtsStatus.postValue(RTS_STATUS_LOGGED);
            } else {
                rtsStatus.postValue(RTS_STATUS_FAILED);
            }
        });
    }

    @Override
    protected void onCleared() {
        LiveRTCManager.ins().destroyEngine();
        LiveRTCManager.ins().destroyEffectDialog();
    }
}
