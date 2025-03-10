// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.vod.function.fragment;

import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.MutableLiveData;

import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.utils.LicenseChecker;
import com.vertcdemo.core.utils.LicenseResult;

public class PlaybackFunctionViewModel extends AndroidViewModel {

    public final MutableLiveData<LicenseResult> licenseResult = new MutableLiveData<>(LicenseResult.empty);

    public PlaybackFunctionViewModel(@NonNull Application application) {
        super(application);
    }

    public void checkLicense() {
        Context context = getApplication();
        AppExecutors.diskIO().execute(() -> {
            String licenseUri = com.byteplus.vodcommon.BuildConfig.VOD_LICENSE_URI;
            LicenseResult result = LicenseChecker.check(context, licenseUri);
            licenseResult.postValue(result);
        });
    }
}
