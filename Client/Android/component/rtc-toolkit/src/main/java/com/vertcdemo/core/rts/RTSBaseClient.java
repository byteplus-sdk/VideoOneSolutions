// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.rts;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.eventbus.SolutionEventBus;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class RTSBaseClient implements IMessageHandler {
    private static final String TAG = "RTSBaseClient";

    public static final String MESSAGE_TYPE_INFORM = "inform";

    private final Map<String, Class<?>> mEventTypes = new HashMap<>();

    protected void registerEventType(@NonNull String event, @NonNull Class<?> type) {
        mEventTypes.put(event, type);
    }

    public void onMessageReceived(String uid, String message) {
        Log.e(TAG, "[Base] onMessageReceived: message=" + message);
        try {
            JSONObject messageJson = new JSONObject(message);
            String messageType = messageJson.optString("message_type");
            if (MESSAGE_TYPE_INFORM.equals(messageType)) {
                String event = messageJson.optString("event");
                String data = messageJson.optString("data");

                if (TextUtils.isEmpty(event) || TextUtils.isEmpty(data)) {
                    return;
                }

                handleMessage(event, data);

            } else {
                Log.w(TAG, "[Base] onMessageReceived DISCARD message: type: " + messageType);
            }
        } catch (Exception e) {
            Log.e(TAG, "[Base] parse message failed: uid=" + uid + ", message=" + message, e);
        }
    }

    private void handleMessage(@NonNull String eventKey, @NonNull String eventData) {
        Class<?> eventType = mEventTypes.get(eventKey);
        if (eventType != null) {
            Object event = GsonUtils.gson().fromJson(eventData, eventType);
            SolutionEventBus.post(event);
        } else {
            Log.w(TAG, "[Base] onMessageReceived DISCARD broadcast: event: " + eventKey);
        }
    }
}

