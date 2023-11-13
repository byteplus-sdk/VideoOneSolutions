// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.main;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class MainTabViewModel extends ViewModel {
    public static final int TAB_MAIN = 0;
    public static final int TAB_FEED = 1;
    public static final int TAB_CHANNEL = 2;
    public static final int TAB_SETTINGS = 3;


    public MutableLiveData<Integer> currentTab = new MutableLiveData<>(TAB_MAIN);
}
