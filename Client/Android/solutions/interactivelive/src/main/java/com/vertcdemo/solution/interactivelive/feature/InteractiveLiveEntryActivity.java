// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.google.gson.JsonObject;
import com.vertcdemo.core.http.AppInfoManager;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.ui.SolutionLoadingActivity;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.solution.interactivelive.BuildConfig;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.ui.CenteredToast;

import java.util.Objects;

public class InteractiveLiveEntryActivity extends SolutionLoadingActivity {

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
                LiveService.get().setAppId(Objects.requireNonNull(data.appId));
                Intent intent = new Intent(AppUtil.getApplicationContext(), InteractiveLiveActivity.class);
                intent.putExtra(RTCAppInfo.KEY_APP_INFO, data);
                startActivity(intent);
                finish();
            }

            @Override
            public void onFailure(HttpException e) {
                if (isFinishing()) {
                    return;
                }
                CenteredToast.show(ErrorTool.getErrorMessage(e));
                finish();
            }
        };

        JsonObject content = new JsonObject();
        content.addProperty("scenes_name", "live");
        content.addProperty("live_pull_domain", BuildConfig.LIVE_PULL_DOMAIN);
        content.addProperty("live_push_domain", BuildConfig.LIVE_PUSH_DOMAIN);
        content.addProperty("live_push_key", BuildConfig.LIVE_PUSH_KEY);
        content.addProperty("live_app_name", BuildConfig.LIVE_APP_NAME);

        AppInfoManager.requestInfo(content, callback);
    }
}
