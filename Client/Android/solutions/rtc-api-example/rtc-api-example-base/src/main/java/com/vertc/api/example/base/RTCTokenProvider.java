package com.vertc.api.example.base;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.concurrent.Future;

public interface RTCTokenProvider {
    @Nullable
    String getAppId();

    @NonNull
    String getBusinessId(String bid);

    @NonNull
    Future<String> getToken(@NonNull String roomId, @NonNull String userId);
}
