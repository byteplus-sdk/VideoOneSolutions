// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcommon.data.remote;


import androidx.annotation.IntDef;
import androidx.annotation.NonNull;

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
    @interface VideoType {
        int SHORT = 0;
        int FEED = 1;
        int LONG = 2;
    }

    interface Callback<T> {
        void onSuccess(T t);

        void onError(Exception e);
    }

    interface GetFeedStream {
        void getFeedStream(@VideoType int videoType,
                           String account,
                           int pageIndex,
                           int pageSize,
                           @NonNull Callback<Page<VideoItem>> callback
        );

        void cancel();
    }
}
