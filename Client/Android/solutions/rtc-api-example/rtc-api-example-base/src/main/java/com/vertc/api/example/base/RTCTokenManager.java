package com.vertc.api.example.base;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.concurrent.Future;

public class RTCTokenManager implements RTCTokenProvider {

    private static final RTCTokenManager sInstance = new RTCTokenManager();

    public static RTCTokenManager getInstance() {
        return sInstance;
    }

    @Nullable
    private RTCTokenProvider mRemoteProvider;

    private final RTCTokenProvider mLocalProvider = new LocalRTCTokenProvider();

    @Nullable
    @Override
    public String getAppId() {
        if (mRemoteProvider != null) {
            return mRemoteProvider.getAppId();
        } else {
            return mLocalProvider.getAppId();
        }
    }

    @NonNull
    @Override
    public Future<String> getToken(@NonNull String roomId, @NonNull String userId) {
        if (mRemoteProvider != null) {
            return mRemoteProvider.getToken(roomId, userId);
        } else {
            return mLocalProvider.getToken(roomId, userId);
        }
    }

    public void setRemoteProvider(@Nullable RTCTokenProvider provider) {
        this.mRemoteProvider = provider;
    }
}
