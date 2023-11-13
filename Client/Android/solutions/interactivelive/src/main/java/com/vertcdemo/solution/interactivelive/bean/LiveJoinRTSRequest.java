// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.interactivelive.BuildConfig;
import com.vertcdemo.core.joinrtsparams.bean.JoinRTSRequest;
import com.vertcdemo.core.SolutionDataManager;

public class LiveJoinRTSRequest extends JoinRTSRequest {
    public static final String SOLUTION_NAME_ABBR = "live";

    @SerializedName("live_pull_domain")
    public final String livePullDomain = BuildConfig.LIVE_PULL_DOMAIN;
    @SerializedName("live_push_domain")
    public final String livePushDomain = BuildConfig.LIVE_PUSH_DOMAIN;
    @SerializedName("live_push_key")
    public final String livePushKey = BuildConfig.LIVE_PUSH_KEY;
    @SerializedName("live_app_name")
    public final String liveAppName = BuildConfig.LIVE_APP_NAME;

    public LiveJoinRTSRequest() {
        super(SOLUTION_NAME_ABBR, SolutionDataManager.ins().getToken());
    }
}
