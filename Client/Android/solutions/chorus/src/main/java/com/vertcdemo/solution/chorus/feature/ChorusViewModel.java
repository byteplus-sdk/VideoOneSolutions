// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature;

import android.util.Log;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.rts.IRTSCallback;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;
import com.vertcdemo.solution.chorus.core.ChorusRTSClient;

public class ChorusViewModel extends ViewModel {
    private static final String TAG = "ChorusViewModel";

    public static final int RTS_STATUS_NONE = 0;
    public static final int RTS_STATUS_LOGGING = 1;
    public static final int RTS_STATUS_LOGGED = 2;
    public static final int RTS_STATUS_FAILED = 3;

    private RTSInfo rtsInfo;

    public MutableLiveData<Integer> rtsStatus = new MutableLiveData<>(RTS_STATUS_NONE);

    public void setRTSInfo(RTSInfo rtsInfo) {
        this.rtsInfo = rtsInfo;
        ChorusRTCManager.ins().initEngine(rtsInfo);
    }

    public void loginRTS() {
        rtsStatus.postValue(RTS_STATUS_LOGGING);
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        rtsClient.login(rtsInfo.rtsToken, (resultCode, message) -> {
            Log.d(TAG, "RTS Login: " + resultCode);
            if (resultCode == IRTSCallback.CODE_SUCCESS) {
                rtsStatus.postValue(RTS_STATUS_LOGGED);
            } else {
                rtsStatus.postValue(RTS_STATUS_FAILED);
            }
        });
    }

    @Override
    protected void onCleared() {
        ChorusRTCManager.ins().destroyEngine();
    }
}
