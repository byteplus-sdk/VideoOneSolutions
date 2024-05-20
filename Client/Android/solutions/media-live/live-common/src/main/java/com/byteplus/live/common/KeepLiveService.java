// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.core.app.NotificationManagerCompat;

public class KeepLiveService extends Service {
    private static final String TAG = "KeepLiveService";
    private static final String NOTIFICATION_CHANNEL_ID = "media_live_keep_app_live";
    private static final int NOTIFICATION_ID = 0xBABE0010;

    public class Binder extends android.os.Binder {
        public KeepLiveService getService() {
            return KeepLiveService.this;
        }
    }

    private final Binder mBinder = new Binder();


    public KeepLiveService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "onCreate()");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String notificationName = getString(R.string.notification_media_live_in_background);
            NotificationChannel channel = new NotificationChannel(NOTIFICATION_CHANNEL_ID,
                    notificationName, NotificationManager.IMPORTANCE_HIGH);
            channel.enableVibration(false);
            channel.setSound(null, null);

            NotificationManagerCompat.from(this)
                    .createNotificationChannel(channel);
        }
        startForeground(NOTIFICATION_ID, getNotification());
    }

    private Notification getNotification() {
        PackageManager packageManager = getPackageManager();
        ApplicationInfo info;
        try {
            info = packageManager.getApplicationInfo(getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            throw new RuntimeException(e);
        }
        CharSequence appName = packageManager.getApplicationLabel(info);
        Notification.Builder builder = new Notification.Builder(this)
                .setSmallIcon(R.mipmap.ic_launcher_round)
                .setContentTitle(appName)
                .setContentIntent(getIntent())
                .setContentText(getString(R.string.notification_media_live_in_background));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setChannelId(NOTIFICATION_CHANNEL_ID);
        }
        return builder.build();
    }

    private PendingIntent getIntent() {
        Intent intent = getPackageManager()
                .getLaunchIntentForPackage(getPackageName());

        return PendingIntent.getActivity(
                getApplicationContext(),
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "onDestroy()");
        stopForeground(true);
        super.onDestroy();
    }
}