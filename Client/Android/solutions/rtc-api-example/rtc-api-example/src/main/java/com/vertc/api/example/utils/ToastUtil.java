package com.vertc.api.example.utils;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

public class ToastUtil {

    private static final Handler mainHandler = new Handler(Looper.getMainLooper());
    private static Toast toast;

    public static void showLongToast(Context context, final String msg) {
        showToast(context, msg, Toast.LENGTH_LONG);
    }

    public static void showLongToast(Context context, final int msg) {
        showToast(context, msg, Toast.LENGTH_LONG);
    }

    public static void showToast(Context context, final String msg) {
        showToast(context, msg, Toast.LENGTH_SHORT);
    }

    public static void showToast(Context context, final int msg) {
        showToast(context, msg, Toast.LENGTH_SHORT);
    }

    public static void showToast(Context context, final String msg, int duration) {
        mainHandler.post(() -> {
            if (toast != null) {
                toast.cancel();
            }
            toast = Toast.makeText(context, msg, duration);
            toast.show();
        });
    }

    public static void showToast(Context context, final int msg, int duration) {
        mainHandler.post(() -> {
            if (toast != null) {
                toast.cancel();
            }
            toast = Toast.makeText(context, msg, duration);
            toast.show();
        });
    }
}
