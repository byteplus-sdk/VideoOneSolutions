// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.data.remote;


import android.os.Handler;
import android.os.Looper;

import androidx.annotation.IntDef;

import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.page.Page;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

public interface RemoteApi {

    @IntDef({
            VideoType.SHORT,
            VideoType.FEED,
            VideoType.LONG,
    })
    @Retention(RetentionPolicy.SOURCE)
    public @interface VideoType {
        int SHORT = 0;
        int FEED = 1;
        int LONG = 2;
    }


    class HandlerCallback<T> implements Callback<T> {

        private static final Handler MAIN_HANDLER = new Handler(Looper.getMainLooper());

        private final Callback<T> callback;
        private final Handler handler;

        public HandlerCallback(Callback<T> callback) {
            this(callback, MAIN_HANDLER);
        }

        public HandlerCallback(RemoteApi.Callback<T> callback, Handler handler) {
            this.callback = callback;
            this.handler = handler;
        }

        @Override
        public void onSuccess(T t) {
            handler.post(() -> {
                if (callback != null) {
                    callback.onSuccess(t);
                }
            });
        }

        @Override
        public void onError(Exception e) {
            handler.post(() -> {
                if (callback != null) {
                    callback.onError(e);
                }
            });
        }
    }

    interface Callback<T> {
        void onSuccess(T t);

        void onError(Exception e);
    }

    interface GetFeedStream {
        void getFeedStream(@VideoType int videoType, String account, int pageIndex, int pageSize, Callback<Page<VideoItem>> callback);

        void cancel();
    }
}
