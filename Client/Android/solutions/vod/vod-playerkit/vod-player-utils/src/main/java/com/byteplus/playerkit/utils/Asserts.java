// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils;

import android.os.Looper;

import java.util.Objects;

public class Asserts {

    public static boolean DEBUG = false;

    public static void throwIfDebug(RuntimeException e) {
        if (DEBUG) {
            throw e;
        } else {
            L.fw(Asserts.class, "throwIfDebug", e);
        }
    }

    public static void checkMainThread() {
        checkThread(Looper.getMainLooper());
    }

    public static void checkThread(Looper looper) {
        Asserts.checkNotNull(looper);
        if (Thread.currentThread() != looper.getThread()) {
            throwIfDebug(new IllegalThreadStateException(String.format("You must call this method in %s thread!", looper.getThread())));
        }
    }

    public static void checkState(Object currentState, Object... validStates) {
        for (Object s : validStates) {
            if (Objects.equals(s, currentState)) {
                return;
            }
        }
        final StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (Object s : validStates) {
            sb.append(s).append(",");
        }
        sb.replace(sb.length() - 1, sb.length() - 1, "]");

        throwIfDebug(new IllegalStateException(String.format("Thread:%s. Current state is %s, You can only call this method in %s",
                Thread.currentThread().getName(), currentState, sb)));
    }

    public static void checkState(boolean legalState) {
        if (!DEBUG) return;

        if (!legalState) {
            throwIfDebug(new IllegalStateException());
        }
    }

    public static void checkState(boolean legalState, String illegalMsg) {
        if (!DEBUG) return;

        if (!legalState) {
            throwIfDebug(new IllegalStateException(illegalMsg));
        }
    }

    public static void checkArgument(boolean legalArgument) {
        if (!DEBUG) return;

        if (!legalArgument) {
            throwIfDebug(new IllegalArgumentException());
        }
    }

    public static <T> T checkNotNull(T t) {
        if (t == null) {
            throwIfDebug(new NullPointerException());
        }
        return t;
    }

    public static <T> T checkNotNull(T t, String msg) {
        if (t == null) {
            throwIfDebug(new NullPointerException(msg));
        }
        return t;
    }

    public static void checkOneOf(Object o, Object... os) {
        if (DEBUG) return;

        if (os == null) {
            throwIfDebug(new NullPointerException());
        }
        for (Object obj : os) {
            if (Objects.equals(o, obj)) {
                return;
            }
        }
        StringBuilder sb = new StringBuilder('[');
        for (Object obj : os) {
            sb.append(obj).append(',');
        }
        sb.replace(sb.length() - 1, sb.length() - 1, "]");
        throwIfDebug(new IllegalArgumentException(o + " must be one of " + sb));
    }
}
