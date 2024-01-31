// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer.dialog;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.text.TextUtils;

import java.lang.ref.WeakReference;

public class VolumeReceiver extends BroadcastReceiver {

    interface SyncVolumeHandler {
        void syncVolume();
    }

    public static String VOLUME_CHANGED_ACTION = "android.media.VOLUME_CHANGED_ACTION";
    public static String EXTRA_VOLUME_STREAM_TYPE = "android.media.EXTRA_VOLUME_STREAM_TYPE";

    private final WeakReference<SyncVolumeHandler> mRef;

    private boolean mRegistered;

    void register(Context context) {
        if (mRegistered) return;

        mRegistered = true;
        IntentFilter filter = new IntentFilter();
        filter.addAction(VOLUME_CHANGED_ACTION);
        context.getApplicationContext().registerReceiver(this, filter);
    }

    void unregister(Context context) {
        if (!mRegistered) return;
        mRegistered = false;
        context.getApplicationContext().unregisterReceiver(this);
    }

    VolumeReceiver(SyncVolumeHandler layer) {
        mRef = new WeakReference<>(layer);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        final String action = intent.getAction();
        final int volumeStreamType = intent.getIntExtra(EXTRA_VOLUME_STREAM_TYPE, -1);
        if (TextUtils.equals(action, VOLUME_CHANGED_ACTION) && volumeStreamType == AudioManager.STREAM_MUSIC) {
            SyncVolumeHandler layer = mRef.get();
            if (layer != null) {
                layer.syncVolume();
            } else {
                context.getApplicationContext().unregisterReceiver(this);
            }
        }
    }
}

