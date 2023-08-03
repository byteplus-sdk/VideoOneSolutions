// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.app.Application;

import com.vertcdemo.core.net.http.AppNetworkStatusUtil;
import com.vertcdemo.core.utils.AppUtil;

public class SolutionApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        AppUtil.initApp(this);

        AppNetworkStatusUtil.registerNetworkCallback(this);
    }
}
