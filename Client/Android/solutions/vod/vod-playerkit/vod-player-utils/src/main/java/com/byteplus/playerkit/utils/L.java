// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils;

import android.util.Log;


public class L {
    private static final String TAG = "Player_Kit";
    public static boolean ENABLE_LOG = false;

    private L() {
    }

    public static void v(Object o, String method, Object... messages) {
        if (ENABLE_LOG) {
            Log.v(TAG, createLog(o, method, messages));
        }
    }

    public static void v(Object o, String method, Throwable throwable, Object... messages) {
        if (ENABLE_LOG) {
            Log.v(TAG, createLog(o, method, messages), throwable);
        }
    }

    public static void d(Object o, String method, Object... messages) {
        if (ENABLE_LOG) {
            Log.d(TAG, createLog(o, method, messages));
        }
    }

    public static void d(Object o, String method, Throwable throwable, Object... messages) {
        if (ENABLE_LOG) {
            Log.d(TAG, createLog(o, method, messages), throwable);
        }
    }

    public static void i(Object o, String method, Object... messages) {
        if (ENABLE_LOG) {
            Log.i(TAG, createLog(o, method, messages));
        }
    }

    public static void i(Object o, String method, Throwable throwable, Object... messages) {
        if (ENABLE_LOG) {
            Log.i(TAG, createLog(o, method, messages), throwable);
        }
    }

    public static void e(Object o, String method, Object... messages) {
        if (ENABLE_LOG) {
            Log.e(TAG, createLog(o, method, messages));
        }
    }

    public static void e(Object o, String method, Throwable throwable, Object... messages) {
        if (ENABLE_LOG) {
            Log.e(TAG, createLog(o, method, messages), throwable);
        }
    }

    public static void w(Object o, String method, Object... messages) {
        if (ENABLE_LOG) {
            Log.w(TAG, createLog(o, method, messages));
        }
    }

    public static void w(Object o, String method, Throwable throwable, Object... messages) {
        if (ENABLE_LOG) {
            Log.w(TAG, createLog(o, method, messages), throwable);
        }
    }

    private static String createLog(Object o, String method, Object... messages) {
        StringBuilder msg = new StringBuilder("[" + obj2String(o) + "]").append(" -> ").append(method);
        if (messages != null) {
            for (Object message : messages) {
                msg.append(" -> ").append(obj2String(message));
            }
        }
        return msg.toString();
    }

    public static String string(Object o) {
        if (o == null) return "null";
        if (ENABLE_LOG) {
            return o.toString();
        } else {
            return "";
        }
    }

    public static String obj2String(Object o) {
        if (o == null) {
            return "null";
        }
        if (o instanceof String) {
            return (String) o;
        }
        if (o instanceof Boolean) {
            return String.valueOf(o);
        }
        if (o instanceof Number) {
            return String.valueOf(o);
        }
        if (o instanceof Enum<?>) {
            return o.getClass().getSimpleName() + '.' + o;
        }
        if (o.getClass().isAnonymousClass()) {
            String s = o.toString();
            return s.substring(s.lastIndexOf('.'));
        }
        if (o instanceof Class<?>) {
            return ((Class<?>) o).getSimpleName();
        }
        return o.getClass().getSimpleName() + '@' + Integer.toHexString(o.hashCode());
    }
}
