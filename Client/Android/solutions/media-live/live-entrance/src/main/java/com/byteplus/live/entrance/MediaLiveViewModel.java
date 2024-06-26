// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.entrance;

import android.content.Context;

import androidx.lifecycle.ViewModel;

import com.byteplus.live.pusher.MediaResourceMgr;

public class MediaLiveViewModel extends ViewModel {
    private boolean mIsResourceReady = false;

    public boolean isResourceReady() {
        return mIsResourceReady;
    }

    public void prepareResource(Context context) {
        if (!mIsResourceReady) {
            new Thread(() -> {
                MediaResourceMgr.prepare(context);
                prepareEffectResource();
                mIsResourceReady = true;
            }).start();
        }
    }

    private void prepareEffectResource() {
    }
}
