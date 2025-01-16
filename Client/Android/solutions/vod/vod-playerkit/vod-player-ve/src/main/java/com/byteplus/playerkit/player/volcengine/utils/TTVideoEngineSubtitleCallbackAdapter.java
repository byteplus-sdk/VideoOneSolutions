// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine.utils;

import com.ss.ttvideoengine.SubInfoCallBack;
import com.ss.ttvideoengine.SubInfoSimpleCallBack;
import com.ss.ttvideoengine.utils.Error;

public class TTVideoEngineSubtitleCallbackAdapter extends SubInfoSimpleCallBack {
    private final SubInfoCallBack mCallback;

    public TTVideoEngineSubtitleCallbackAdapter(SubInfoCallBack callBack) {
        mCallback = callBack;
    }

    @Override
    public void onSubPathInfo(String subPathInfo, Error error) {
        mCallback.onSubPathInfo(subPathInfo, error);
    }

    @Override
    public void onSubInfoCallback(int code, String info) {
        mCallback.onSubInfoCallback(code, info);
    }

    @Override
    public void onSubSwitchCompleted(int success, int subId) {
        mCallback.onSubSwitchCompleted(success, subId);
    }

    @Override
    public void onSubLoadFinished(int success) {
        mCallback.onSubLoadFinished(success);
    }

    @Override
    public void onSubLoadFinished2(int success, String info) {
        mCallback.onSubLoadFinished2(success, info);
    }
}
