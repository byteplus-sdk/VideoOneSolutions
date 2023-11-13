// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.app.Application;
import android.text.TextUtils;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.login.utils.AgreementManager;
import com.videoone.app.protocol.InitializeManager;

public class SolutionApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        AppUtil.initApp(this);
        String token = SolutionDataManager.ins().getToken();
        if (!TextUtils.isEmpty(token) || AgreementManager.getAgreementStatus(this)) {
            InitializeManager.initialize(this);
        }
    }
}
