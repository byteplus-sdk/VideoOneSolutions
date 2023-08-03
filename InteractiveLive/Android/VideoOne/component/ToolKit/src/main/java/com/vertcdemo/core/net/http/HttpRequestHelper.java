// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.http;

import android.content.Context;
import android.util.Log;

import androidx.annotation.AnyThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.WorkerThread;

import com.google.gson.JsonSyntaxException;
import com.vertcdemo.core.BuildConfig;
import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.core.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

import okhttp3.Call;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class HttpRequestHelper {
    private static final String TAG = "HttpRequestHelper";
    private static final String LOGIN_URL = BuildConfig.SERVER_URL + "/login";

    public static final OkHttpClient DEFAULT_OKHTTP_CLIENT = new OkHttpClient.Builder()
            .build();

    @AnyThread
    public static <T> void sendPost(JSONObject params,
                                    Class<T> resultClass,
                                    @NonNull IRequestCallback<ServerResponse<T>> callBack) {
        AppExecutors.networkIO().execute(() -> sendPost(LOGIN_URL, params, resultClass, callBack));
    }

    @WorkerThread
    public static <T> void sendPost(@NonNull String url,
                                    JSONObject params,
                                    @Nullable Class<T> resultClass,
                                    @NonNull IRequestCallback<ServerResponse<T>> callBack) {
        try {
            Context context = AppUtil.getApplicationContext();
            String language = context.getString(R.string.language_code);
            params.put("language", language);
        } catch (JSONException ignored) {

        }
        RequestBody body = RequestBody.create(MediaType.get("application/json; charset=utf-8"), params.toString());

        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .build();
        Call call = DEFAULT_OKHTTP_CLIENT.newCall(request);

        try (final Response response = call.execute()) {
            Log.d(TAG, "Request: " + params);
            if (!response.isSuccessful()) {
                throw new IOException("http code = " + response.code());
            }

            final ResponseBody responseBody = response.body();
            if (responseBody == null) {
                throw new IOException("ResponseBody is null");
            }

            JSONObject json = new JSONObject(responseBody.string());
            Log.d(TAG, "Response: " + json);

            final int code = json.optInt("code");
            final String message = json.optString("message");

            if (code != 200) {
                if (code == ErrorTool.ERROR_CODE_TOKEN_EXPIRED || code == ErrorTool.ERROR_CODE_TOKEN_EMPTY) {
                    SolutionDataManager.ins().setToken("");
                    SolutionEventBus.post(new AppTokenExpiredEvent());
                }
                AppExecutors.mainThread().execute(() -> callBack.onError(code, message));
                return;
            }

            Object responseObject = json.opt("response");

            T data;
            if (responseObject == null
                    || resultClass == null
                    || resultClass == Void.class) {
                data = null;
            } else {
                data = GsonUtils.gson().fromJson(responseObject.toString(), resultClass);
            }

            final ServerResponse<T> sr = ServerResponse.create(code, message, data);
            AppExecutors.mainThread().execute(() -> callBack.onSuccess(sr));
        } catch (IOException | JsonSyntaxException | JSONException e) {
            Log.d(TAG, "post fail url:" + url, e);
            AppExecutors.mainThread().execute(() -> callBack.onError(ErrorTool.ERROR_CODE_UNKNOWN, e.getMessage()));
        }
    }
}
