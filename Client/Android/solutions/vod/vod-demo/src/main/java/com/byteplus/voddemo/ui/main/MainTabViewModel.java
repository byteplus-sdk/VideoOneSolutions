// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.main;

import android.content.Context;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.utils.LicenseChecker;
import com.vertcdemo.core.utils.LicenseResult;

public class MainTabViewModel extends ViewModel {
    public static final int TAB_MAIN = 0;
    public static final int TAB_FEED = 1;
    public static final int TAB_CHANNEL = 2;
    public static final int TAB_SETTINGS = 3;


    public MutableLiveData<Integer> currentTab = new MutableLiveData<>(TAB_MAIN);

    public final MutableLiveData<LicenseResult> licenseResult = new MutableLiveData<>(LicenseResult.empty);

    public void checkLicense(Context context) {
        AppExecutors.diskIO().execute(() -> {
            String licenseUri = com.byteplus.vodcommon.BuildConfig.VOD_LICENSE_URI;
            LicenseResult result = LicenseChecker.check(context, licenseUri);
            licenseResult.postValue(result);
        });
    }
}
