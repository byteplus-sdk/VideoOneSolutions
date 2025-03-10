// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.main;

import android.content.Context;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.utils.LicenseChecker;
import com.vertcdemo.core.utils.LicenseResult;

public class MainFragmentViewModel extends ViewModel {
    public enum Tab {
        HOME,
        CHANNEL
    }

    public MutableLiveData<Tab> currentTab = new MutableLiveData<>(Tab.HOME);

    public final MutableLiveData<LicenseResult> licenseResult = new MutableLiveData<>(LicenseResult.empty);

    public void checkLicense(Context context) {
        AppExecutors.diskIO().execute(() -> {
            String licenseUri = com.byteplus.vodcommon.BuildConfig.VOD_LICENSE_URI;
            LicenseResult result = LicenseChecker.check(context, licenseUri);
            licenseResult.postValue(result);
        });
    }
}
