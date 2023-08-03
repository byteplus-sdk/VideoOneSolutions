// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.rts;

import android.text.TextUtils;

import androidx.annotation.CallSuper;

import com.ss.bytertc.engine.type.ErrorCode;
import com.vertcdemo.core.RTCRoomEventHandlerAdapter;
import com.vertcdemo.core.eventbus.RTCReconnectToRoomEvent;
import com.vertcdemo.core.eventbus.RTSLogoutEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;

import org.json.JSONObject;

public class RTCRoomEventHandlerWithRTS extends RTCRoomEventHandlerAdapter {

    public static final String UID_BIZ_SERVER = "server";

    private RTSBaseClient mBaseClient;

    private final boolean mNotifyReconnect;

    public RTCRoomEventHandlerWithRTS() {
        this(false);
    }

    public RTCRoomEventHandlerWithRTS(boolean notifyReconnect) {
        mNotifyReconnect = notifyReconnect;
    }

    public void setBaseClient(RTSBaseClient baseClient) {
        this.mBaseClient = baseClient;
    }

    protected final boolean isFirstJoinRoomSuccess(int state, String extraInfo) {
        return joinRoomType(extraInfo) == 0 && state == 0;
    }

    protected final boolean isReconnectSuccess(int state, String extraInfo) {
        return joinRoomType(extraInfo) == 1 && state == 0;
    }

    protected final int joinRoomType(String extraInfo) {
        int joinType = -1;
        try {
            JSONObject json = new JSONObject(extraInfo);
            joinType = json.optInt("join_type", -1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return joinType;
    }

    private void onMessageReceived(String fromUid, String message) {
        if (TextUtils.equals(UID_BIZ_SERVER, fromUid)) {
            if (mBaseClient != null) {
                mBaseClient.onMessageReceived(fromUid, message);
            }
        }
    }

    @CallSuper
    @Override
    public void onRoomMessageReceived(String uid, String message) {
        onMessageReceived(uid, message);
    }

    @CallSuper
    @Override
    public void onUserMessageReceived(String uid, String message) {
        onMessageReceived(uid, message);
    }

    @CallSuper
    @Override
    public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
        if (state == ErrorCode.ERROR_CODE_DUPLICATE_LOGIN) {
            SolutionEventBus.post(new RTSLogoutEvent());
        }
        if (mNotifyReconnect && isReconnectSuccess(state, extraInfo)) {
            SolutionEventBus.post(new RTCReconnectToRoomEvent(roomId, uid, state, extraInfo));
        }
    }
}