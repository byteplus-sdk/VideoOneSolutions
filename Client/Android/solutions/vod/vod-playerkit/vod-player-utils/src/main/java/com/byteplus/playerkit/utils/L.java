// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils;

import android.util.Log;

import java.util.Collection;


public class L {
    private static final String TAG = "Player_Kit";
    public static boolean ENABLE_LOG = false;
    public static final int BUFFER_SIZE = 3000;

    private L() {
    }

    public static void log(Object o, String method, String s) {
        if (ENABLE_LOG) {
            final int length = s.length();
            if (length < BUFFER_SIZE) {
                L.v(o, method, s);
            } else {
                int startIndex = 0;
                while (startIndex < length) {
                    int endIndex = Math.min(length, startIndex + BUFFER_SIZE);
                    L.v(o, method, s.substring(startIndex, endIndex));
                    startIndex = endIndex;
                }
            }
        }
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

    public static void fw(Object o, String method, Throwable throwable, Object... messages) {
        Log.w(TAG, createLog(o, method, messages), throwable);
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
        } else if (o instanceof String) {
            return (String) o;
        } else if (o instanceof Boolean) {
            return String.valueOf(o);
        } else if (o instanceof Number) {
            return String.valueOf(o);
        } else if (o instanceof Collection<?>) {
            return o.getClass().getSimpleName() + '@' + Integer.toHexString(o.hashCode()) + "[" + ((Collection<?>) o).size() + "]";
        } else if (o.getClass().isAnonymousClass()) {
            String s = o.toString();
            return s.substring(s.lastIndexOf('.'));
        } else if (o instanceof Class<?>) {
            return ((Class<?>) o).getSimpleName();
        } else {
            return o.getClass().getSimpleName() + '@' + Integer.toHexString(o.hashCode());
        }
    }
}
