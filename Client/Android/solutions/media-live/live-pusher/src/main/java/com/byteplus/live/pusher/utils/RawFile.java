// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.pusher.utils;

import android.content.Context;

import androidx.annotation.NonNull;

import com.byteplus.live.pusher.MediaResourceMgr;

public interface RawFile {
    float getSizeInMB();

    @NonNull
    String getFileName();

    @NonNull
    String getUrl();

    default String getLocalPath(@NonNull Context context) {
        return MediaResourceMgr.getLocalFile(context, this).getAbsolutePath();
    }
}