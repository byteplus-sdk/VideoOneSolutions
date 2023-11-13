// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.rts;

import android.text.TextUtils;

import androidx.annotation.CallSuper;

import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;

import java.nio.ByteBuffer;

public class RTCVideoEventHandlerWithRTS extends IRTCVideoEventHandler {

    public static final String UID_BIZ_SERVER = "server";
    private RTSBaseClient mBaseClient;

    public void setBaseClient(RTSBaseClient baseClient) {
        this.mBaseClient = baseClient;
    }

    @CallSuper
    @Override
    public void onLoginResult(String uid, int errorCode, int elapsed) {
        if (mBaseClient != null) {
            mBaseClient.onLoginResult(uid, errorCode, elapsed);
        }
    }

    @CallSuper
    @Override
    public void onServerParamsSetResult(int error) {
        if (mBaseClient != null) {
            mBaseClient.onServerParamsSetResult(error);
        }
    }

    @CallSuper
    @Override
    public void onServerMessageSendResult(long msgId, int error, ByteBuffer message) {
        if (mBaseClient != null) {
            mBaseClient.onServerMessageSendResult(msgId, error);
        }
    }

    @CallSuper
    @Override
    public void onUserMessageReceivedOutsideRoom(String uid, String message) {
        if (TextUtils.equals(UID_BIZ_SERVER, uid)) {
            if (mBaseClient != null) {
                mBaseClient.onMessageReceived(uid, message);
            }
        }
    }
}
