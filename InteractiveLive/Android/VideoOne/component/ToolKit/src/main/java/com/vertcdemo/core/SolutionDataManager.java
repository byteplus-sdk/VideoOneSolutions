// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core;


import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.vertcdemo.core.utils.AppUtil;

import java.util.UUID;

public class SolutionDataManager {

    private static final String PREFS_NAME = "solution_data_manager";
    private static final String KEY_USER_ID = "user_id";
    private static final String KEY_USER_NAME = "user_name";
    private static final String KEY_TOKEN = "token";
    private static final String KEY_DEVICE_ID = "device_id";

    private static final SolutionDataManager sInstance = new SolutionDataManager();

    public static SolutionDataManager ins() {
        return sInstance;
    }

    public void setUserId(String userId) {
        getPrefs().edit()
                .putString(KEY_USER_ID, userId)
                .apply();
    }

    @NonNull
    public String getUserId() {
        return getPrefs().getString(KEY_USER_ID, "");
    }

    public void setUserName(String userName) {
        getPrefs().edit().putString(KEY_USER_NAME, userName).apply();
    }

    @NonNull
    public String getUserName() {
        return getPrefs().getString(KEY_USER_NAME, "");
    }

    public void setToken(String token) {
        getPrefs().edit().putString(KEY_TOKEN, token).apply();
    }

    @NonNull
    public String getToken() {
        return getPrefs().getString(KEY_TOKEN, "");
    }

    @NonNull
    public synchronized String getDeviceId() {
        String did = getPrefs().getString(KEY_DEVICE_ID, "");
        if (TextUtils.isEmpty(did)) {
            final UUID uuid = UUID.randomUUID();
            did = String.valueOf(Math.abs(uuid.hashCode()));
            getPrefs().edit().putString(KEY_DEVICE_ID, did).apply();
        }
        return did;
    }

    public void logout() {
        getPrefs().edit()
                .remove(KEY_USER_ID)
                .remove(KEY_USER_NAME)
                .remove(KEY_TOKEN)
                .apply();
    }

    private static SharedPreferences getPrefs() {
        final Context context = AppUtil.getApplicationContext();
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }
}
