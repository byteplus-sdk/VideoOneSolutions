// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.vertcdemo.core.http.AppInfoManager;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.ui.SolutionLoadingActivity;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.ktv.core.ErrorCodes;
import com.vertcdemo.solution.ktv.http.KTVService;
import com.vertcdemo.ui.CenteredToast;

import java.util.Objects;

public class KTVEntryActivity extends SolutionLoadingActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        startup();
    }

    private void startup() {
        Callback<RTCAppInfo> callback = new Callback<RTCAppInfo>() {
            @Override
            public void onResponse(RTCAppInfo data) {
                if (isFinishing()) {
                    return;
                }
                if (data == null || data.isInvalid()) {
                    onFailure(HttpException.unknown("Invalid RTCAppInfo response."));
                    return;
                }
                KTVService.get().setAppId(Objects.requireNonNull(data.appId));
                Intent intent = new Intent(Intent.ACTION_MAIN);
                intent.setClass(AppUtil.getApplicationContext(), KTVActivity.class);
                intent.putExtra(RTCAppInfo.KEY_APP_INFO, data);
                startActivity(intent);
                finish();
            }

            @Override
            public void onFailure(HttpException e) {
                if (isFinishing()) {
                    return;
                }
                CenteredToast.show(ErrorCodes.prettyMessage(e));
                finish();
            }
        };

        AppInfoManager.requestInfo("ktv", callback);
    }
}
