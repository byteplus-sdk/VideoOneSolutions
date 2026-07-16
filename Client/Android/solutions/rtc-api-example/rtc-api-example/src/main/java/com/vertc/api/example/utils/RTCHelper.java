package com.vertc.api.example.utils;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.ss.bytertc.engine.RTCEngine;
import com.ss.bytertc.engine.data.EngineConfig;
import com.ss.bytertc.engine.handler.IRTCEngineEventHandler;
import com.vertc.api.example.base.RTCTokenManager;

import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RTCHelper {
    @NonNull
    public static RTCEngine createRTCVideo(Context context, IRTCEngineEventHandler videoEventHandler, String bid) {
        String appId = Objects.requireNonNull(RTCTokenManager.getInstance().getAppId(), "AppId not provided");
        EngineConfig config = new EngineConfig();
        config.context = context.getApplicationContext();
        config.appID = appId;

        RTCEngine engine = Objects.requireNonNull(RTCEngine.createRTCEngine(config, videoEventHandler), "Failed to createRTCEngine()");
        engine.setBusinessId(RTCTokenManager.getInstance().getBusinessId(bid));
        return engine;
    }

    private static final Pattern pattern = Pattern.compile("^[a-zA-Z0-9@._-]{1,128}$");

    /**
     * Check if RoomId or UserId is valid.
     * Valid ids contain 1 to 128 characters, allowing alphanumeric characters and @, ., _, and -.
     *
     * @param input rtc user id or room id
     * @return true if valid, false otherwise
     */
    public static boolean checkValid(@Nullable String input) {
        if (TextUtils.isEmpty(input)) {
            return false;
        }

        final Matcher matcher = pattern.matcher(input);
        return matcher.matches();
    }
}
