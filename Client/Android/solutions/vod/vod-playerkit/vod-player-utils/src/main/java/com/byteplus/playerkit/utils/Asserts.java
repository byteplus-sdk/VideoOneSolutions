// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils;

import android.os.Looper;

import java.util.Objects;

public class Asserts {

    public static void checkMainThread() {
        checkThread(Looper.getMainLooper());
    }

    public static void checkThread(Looper looper) {
        Asserts.checkNotNull(looper);
        if (Thread.currentThread() != looper.getThread()) {
            throw new IllegalThreadStateException(String.format("You must call this method in %s thread!", looper.getThread()));
        }
    }

    public static void checkState(Object currentState, Object... validStates) {
        for (Object s : validStates) {
            if (currentState == s) {
                return;
            }
        }
        final StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (Object s : validStates) {
            sb.append(s).append(",");
        }
        sb.replace(sb.length() - 1, sb.length() - 1, "]");
        throw new IllegalStateException(String.format("Thread:%s. Current state is %s, You can only call this method in %s",
                Thread.currentThread().getName(), currentState, sb));
    }

    public static void checkState(boolean legalState) {
        if (!legalState) {
            throw new IllegalStateException();
        }
    }

    public static void checkState(boolean legalState, String illegalMsg) {
        if (!legalState) {
            throw new IllegalStateException(illegalMsg);
        }
    }

    public static void checkArgument(boolean legalArgument) {
        if (!legalArgument) {
            throw new IllegalArgumentException();
        }
    }

    public static <T> T checkNotNull(T t) {
        if (t == null) {
            throw new NullPointerException();
        }
        return t;
    }

    public static <T> T checkNotNull(T t, String msg) {
        if (t == null) {
            throw new NullPointerException(msg);
        }
        return t;
    }

    public static <T> T checkOneOf(T o, T... ts) {
        if (ts == null) {
            throw new NullPointerException();
        }
        for (T t : ts) {
            if (Objects.equals(o, t)) {
                return o;
            }
        }
        StringBuilder sb = new StringBuilder('[');
        for (T t : ts) {
            sb.append(t).append(',');
        }
        sb.replace(sb.length() - 1, sb.length() - 1, "]");
        throw new IllegalArgumentException(o + " must be one of " + sb);
    }
}
