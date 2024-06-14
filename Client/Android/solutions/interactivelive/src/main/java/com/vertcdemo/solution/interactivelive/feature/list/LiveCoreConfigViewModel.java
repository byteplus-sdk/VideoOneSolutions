// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.solution.interactivelive.util.LiveCoreConfig;

public class LiveCoreConfigViewModel extends ViewModel {

    public MutableLiveData<Boolean> rtmPullStreaming = new MutableLiveData<>(LiveCoreConfig.getRtmPullStreaming());
    public MutableLiveData<Boolean> abr = new MutableLiveData<>(LiveCoreConfig.getABR());

    public void setRtmPullStreaming(boolean value) {
        rtmPullStreaming.postValue(value);
        LiveCoreConfig.setRtmPullStreaming(value);
        if (value) {
            setABR(false);
        }
    }

    public void setABR(boolean value) {
        abr.postValue(value);
        LiveCoreConfig.setABR(value);
        if (value) { 
            setRtmPullStreaming(false);
        }
    }
}
