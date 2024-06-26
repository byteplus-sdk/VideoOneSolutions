// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.rts;

import static com.ss.bytertc.engine.type.UserMessageSendResult.USER_MESSAGE_SEND_RESULT_NOT_LOGIN;
import static com.ss.bytertc.engine.type.UserMessageSendResult.USER_MESSAGE_SEND_RESULT_SUCCESS;

import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Consumer;

import com.google.gson.JsonObject;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.type.LoginErrorCode;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.event.RTSLogoutEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.ErrorTool;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class RTSBaseClient {
    private static final String TAG = "RTSClient";
    public static final int ERROR_CODE_DEFAULT = -1;

    public static final String MESSAGE_TYPE_RETURN = "return";
    public static final String MESSAGE_TYPE_INFORM = "inform";

    private static final Handler mainHandler = new Handler(Looper.getMainLooper());

    private static final String REQ_ID_RTS_LOGIN = "8be4df61-93ca-11d2-aa0d-00e098032b8c-rts-login";

    @NonNull
    private final RTCVideo mRTCVideo;
    private boolean mInitBizServerCompleted;

    @NonNull
    protected final RTSInfo mRTSInfo;
    private final Map<Long, String> mMessageIdRequestIdMap = new HashMap<>();
    private final Map<String, IRTSCallback> mRequestIdCallbackMap = new HashMap<>();
    private final Map<String, Consumer<String>> mEventListeners = new HashMap<>();

    public void registerEventListener(@NonNull String event, Consumer<String> listener) {
        mEventListeners.put(event, listener);
    }

    public void removeEventListeners() {
        mEventListeners.clear();
    }

    public RTSBaseClient(@NonNull RTCVideo engine, @NonNull RTSInfo rtsInfo) {
        mRTCVideo = engine;
        mRTSInfo = rtsInfo;
    }

    @NonNull
    protected JsonObject createCommonParams() {
        JsonObject params = new JsonObject();
        params.addProperty("app_id", mRTSInfo.appId);
        params.addProperty("user_id", SolutionDataManager.ins().getUserId());
        params.addProperty("user_name", SolutionDataManager.ins().getUserName());
        params.addProperty("device_id", SolutionDataManager.ins().getDeviceId());
        return params;
    }

    public boolean isLogin() {
        return mInitBizServerCompleted;
    }

    public void login(@NonNull String token, @NonNull LoginCallBack callback) {
        final String userId = SolutionDataManager.ins().getUserId();
        if (TextUtils.isEmpty(token) || TextUtils.isEmpty(userId)) {
            callback.onError(-1, "login failed: uid='" + userId + "'");
            return;
        }
        mRequestIdCallbackMap.put(REQ_ID_RTS_LOGIN, callback);
        Log.d(TAG, "[Base] login: uid=" + userId);
        mRTCVideo.login(token, userId);
    }

    public void onLoginResult(String uid, int code, int elapsed) {
        Log.d(TAG, "[Base] onLoginResult: uid=" + uid);
        if (TextUtils.isEmpty(mRTSInfo.serverUrl) || TextUtils.isEmpty(mRTSInfo.serverSignature)) {
            notifyLoginResult(-1, "onLoginResult failed: Info=" + mRTSInfo);
            return;
        }
        if (code == LoginErrorCode.LOGIN_ERROR_CODE_SUCCESS) {
            setServerParams(mRTSInfo.serverSignature, mRTSInfo.serverUrl);
        } else {
            notifyLoginResult(code, "onLoginResult fail because");
        }
    }

    public void logout() {
        Log.d(TAG, "[Base] logout");
        mInitBizServerCompleted = false;
        mRTCVideo.logout();
    }

    public void setServerParams(String signature, String url) {
        Log.d(TAG, "[Base] setServerParams: url=" + url);
        if (TextUtils.isEmpty(signature) || TextUtils.isEmpty(url)) {
            notifyLoginResult(-1,
                    "setServerParams failed:\n signature=" + signature + ",\n url=" + url);
            return;
        }
        mRTCVideo.setServerParams(signature, url);
    }

    public void onServerParamsSetResult(int error) {
        Log.d(TAG, "[Base] onServerParamsSetResult: error=" + error);
        if (error != 200) {
            notifyLoginResult(error, "onServerParamsSetResult fail");
            return;
        }
        mInitBizServerCompleted = true;
        notifyLoginResult(IRTSCallback.CODE_SUCCESS, "");
    }

    private long sendServerMessage(String requestId, String message, IRTSCallback callBack) {
        if (TextUtils.isEmpty(message)) {
            notifyRequestFail(ERROR_CODE_DEFAULT, "sendServerMessage: message=" + message, callBack);
            return ERROR_CODE_DEFAULT;
        }
        Log.e(TAG, "[Base] sendServerMessage message:" + message);
        long msgId = mRTCVideo.sendServerMessage(message);
        if (msgId == ERROR_CODE_DEFAULT && callBack != null) {
            notifyRequestFail(ERROR_CODE_DEFAULT, "sendServerMessage fail msgId:" + msgId, callBack);
            return ERROR_CODE_DEFAULT;
        }
        if (callBack != null) {
            mMessageIdRequestIdMap.put(msgId, requestId);
        }
        return msgId;
    }


    public void onServerMessageSendResult(long messageId, int error) {
        String requestId = mMessageIdRequestIdMap.remove(messageId);
        if (error == USER_MESSAGE_SEND_RESULT_NOT_LOGIN) {
            SolutionEventBus.post(new RTSLogoutEvent());
        } else if (requestId != null && error != USER_MESSAGE_SEND_RESULT_SUCCESS) {
            final IRTSCallback callback = mRequestIdCallbackMap.remove(requestId);
            notifyRequestFail(ERROR_CODE_DEFAULT, "sendServerMessage fail error:" + error, callback);
        }
    }


    public void sendServerMessage(String eventName, String roomId, @NonNull JsonObject content, IRTSCallback callback) {
        if (!mInitBizServerCompleted) {
            notifyRequestFail(ERROR_CODE_DEFAULT, "sendServerMessage failed caused by not initialized", callback);
            Log.e(TAG, "[Base] sendServerMessage: mInitBizServerCompleted is false");
            return;
        }
        content.addProperty("login_token", SolutionDataManager.ins().getToken());
        String requestId = String.valueOf(UUID.randomUUID());
        JsonObject message = new JsonObject();
        message.addProperty("app_id", mRTSInfo.appId);
        message.addProperty("room_id", roomId);
        message.addProperty("user_id", SolutionDataManager.ins().getUserId());
        message.addProperty("event_name", eventName);
        message.addProperty("content", content.toString());
        message.addProperty("request_id", requestId);
        message.addProperty("device_id", SolutionDataManager.ins().getDeviceId());
        long msgId = sendServerMessage(requestId, message.toString(), callback);
        if (msgId > 0) {
            mRequestIdCallbackMap.put(requestId, callback);
        } else {
            notifyRequestFail(ERROR_CODE_DEFAULT, "sendServerMessage failed: " + msgId, callback);
        }
    }

    public void onMessageReceived(String uid, String message) {
        Log.e(TAG, "[Base] onMessageReceived: message=" + message);
        try {
            JSONObject messageJson = new JSONObject(message);
            String messageType = messageJson.getString("message_type");
            if (TextUtils.equals(messageType, MESSAGE_TYPE_RETURN)) {
                String requestId = messageJson.getString("request_id");
                final IRTSCallback callback = mRequestIdCallbackMap.remove(requestId);
                if (callback == null) {
                    Log.e(TAG, "[Base] onMessageReceived callback is null");
                    return;
                }

                final int code = messageJson.optInt("code");
                if (code == 200) {
                    final String data = messageJson.optString("response");
                    mainHandler.post(() -> callback.onSuccess(data));
                } else {
                    final String msg = ErrorTool.getErrorMessageByErrorCode(code, messageJson.optString("message"));
                    notifyRequestFail(code, msg, callback);
                }
            } else if (TextUtils.equals(messageType, MESSAGE_TYPE_INFORM)) {
                String event = messageJson.getString("event");
                if (!TextUtils.isEmpty(event)) {
                    Consumer<String> eventListener = mEventListeners.get(event);
                    if (eventListener != null) {
                        String dataStr = messageJson.optString("data");
                        eventListener.accept(dataStr);
                    } else {
                        Log.w(TAG, "[Base] onMessageReceived DISCARD broadcast: event: " + event);
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "[Base] parse message failed: uid=" + uid + ", message=" + message, e);
        }
    }

    private static void notifyRequestFail(int code, String msg, @Nullable IRTSCallback callback) {
        if (callback == null) return;
        mainHandler.post(() -> callback.onError(code, msg));
    }

    private void notifyLoginResult(int code, String msg) {
        final IRTSCallback callback = mRequestIdCallbackMap.remove(REQ_ID_RTS_LOGIN);
        notifyRequestFail(code, msg, callback);
    }

    public interface LoginCallBack extends IRTSCallback {
        @Override
        default void onSuccess(@Nullable String data) {
            onError(CODE_SUCCESS, data);
        }
    }
}

