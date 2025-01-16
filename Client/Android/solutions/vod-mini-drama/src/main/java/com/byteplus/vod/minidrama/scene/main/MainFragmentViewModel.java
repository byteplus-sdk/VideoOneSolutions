// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.main;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class MainFragmentViewModel extends ViewModel {
    public enum Tab {
        HOME,
        CHANNEL
    }

    public MutableLiveData<Tab> currentTab = new MutableLiveData<>(Tab.HOME);
}
