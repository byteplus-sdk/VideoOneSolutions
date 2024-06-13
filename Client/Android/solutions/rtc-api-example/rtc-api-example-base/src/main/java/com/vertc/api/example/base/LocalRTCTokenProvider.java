package com.vertc.api.example.base;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertc.api.example.token.AccessToken;
import com.vertc.api.example.token.Utils;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class LocalRTCTokenProvider implements RTCTokenProvider {
    @Nullable
    @Override
    public String getAppId() {
        return BuildConfig.APP_ID;
    }

    @NonNull
    @Override
    public Future<String> getToken(@NonNull String roomId, @NonNull String userId) {
        return new ImmediatelyFuture() {
            @Override
            public String get() throws ExecutionException {
                if (TextUtils.isEmpty(BuildConfig.APP_ID)) {
                    throw new ExecutionException("No [RTC AppId] provided!", null);
                } else if (TextUtils.isEmpty(BuildConfig.APP_KEY)) {
                    throw new ExecutionException("No [RTC AppKey] provided!", null);
                } else {
                    AccessToken token = new AccessToken(BuildConfig.APP_ID, BuildConfig.APP_KEY, roomId, userId);
                    token.ExpireTime(Utils.getTimestamp() + 3600);
                    token.AddPrivilege(AccessToken.Privileges.SubscribeStream, 0);
                    token.AddPrivilege(AccessToken.Privileges.PublishStream, Utils.getTimestamp() + 3600);

                    return token.serialize();
                }
            }
        };
    }

    static abstract class ImmediatelyFuture implements Future<String> {
        @Override
        public boolean cancel(boolean mayInterruptIfRunning) {
            return false;
        }

        @Override
        public boolean isCancelled() {
            return false;
        }

        @Override
        public boolean isDone() {
            return true;
        }

        @Override
        public String get(long timeout, TimeUnit unit) throws ExecutionException, InterruptedException {
            return get();
        }
    }
}
