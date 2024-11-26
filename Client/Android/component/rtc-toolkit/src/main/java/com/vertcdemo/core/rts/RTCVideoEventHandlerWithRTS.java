// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.rts;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.ss.bytertc.engine.handler.IRTCVideoEventHandler;

public class RTCVideoEventHandlerWithRTS extends IRTCVideoEventHandler {
    @NonNull
    private final IMessageHandler mHandler;

    public RTCVideoEventHandlerWithRTS(@NonNull IMessageHandler handler) {
        mHandler = handler;
    }

    @CallSuper
    @Override
    public void onUserMessageReceivedOutsideRoom(String uid, String message) {
        if (IMessageHandler.UID_SERVER.equals(uid)) {
            mHandler.onMessageReceived(uid, message);
        }
    }
}
