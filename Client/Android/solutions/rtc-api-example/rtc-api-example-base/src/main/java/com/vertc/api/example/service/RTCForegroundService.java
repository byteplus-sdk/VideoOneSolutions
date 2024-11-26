package com.vertc.api.example.service;


import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.ServiceCompat;
import androidx.core.content.ContextCompat;

import com.vertc.api.example.base.R;

public class RTCForegroundService extends Service {
    private static final String TAG = "RTCForegroundService";

    public static final String CHANNEL_ID_FOREGROUND = "rtc_api_example_foreground";

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand: ");
        startForeground();
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy: ");
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE);
    }

    private void startForeground() {
        Log.d(TAG, "startForeground: ");
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.e(TAG, "startForeground: missing one or more permission(s): [CAMERA, RECORD_AUDIO]!");
            stopSelf();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                    != PackageManager.PERMISSION_GRANTED) {
                Log.w(TAG, "startForeground: missing permission [POST_NOTIFICATIONS]!");
            }
        }

        try {
            Notification notification = createNotification();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                int foregroundServiceType;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    foregroundServiceType = ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE | ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA;
                } else {
                    foregroundServiceType = ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST;
                }
                startForeground(R.id.rtc_foreground_notification_id, notification, foregroundServiceType);
            } else {
                startForeground(R.id.rtc_foreground_notification_id, notification);
            }
            Log.d(TAG, "startForeground: OK");
        } catch (
                Exception e) {
            Log.d(TAG, "startForeground: ", e);
        }
    }

    private Notification createNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelName = getString(R.string.rtc_foreground_channel_name);
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID_FOREGROUND, channelName, NotificationManager.IMPORTANCE_DEFAULT);
            channel.setDescription(getString(R.string.rtc_foreground_channel_description));

            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID_FOREGROUND)
                .setSmallIcon(R.drawable.rtc_notification_icon)
                .setContentTitle(getString(R.string.rtc_foreground_notification_title))
                .setContentText(getString(R.string.rtc_foreground_notification_content))
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setOngoing(true);

        return builder.build();
    }
}
