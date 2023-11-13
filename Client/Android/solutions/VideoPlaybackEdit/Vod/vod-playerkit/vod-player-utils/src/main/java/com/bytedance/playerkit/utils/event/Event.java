// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.utils.event;

import android.os.SystemClock;

import androidx.annotation.CallSuper;
import androidx.annotation.Keep;

@Keep
public class Event {
    private final int code;
    private Object owner;
    private Dispatcher dispatcher;

    private long dispatchTime;

    protected Event(int code) {
        this.code = code;
    }

    public final int code() {
        return code;
    }

    public final <T> T owner(Class<T> clazz) {
        return clazz.cast(owner);
    }

    public final Event owner(Object owner) {
        this.owner = owner;
        return this;
    }

    public final Event dispatcher(Dispatcher dispatcher) {
        this.dispatcher = dispatcher;
        return this;
    }

    public final Dispatcher dispatcher() {
        return this.dispatcher;
    }

    public final void dispatch() {
        this.dispatchTime = SystemClock.uptimeMillis();
        this.dispatcher.dispatchEvent(this);
    }

    public final long dispatchTime() {
        return this.dispatchTime;
    }

    @CallSuper
    public void recycle() {
        owner = null;
        dispatcher = null;
        dispatchTime = 0;
    }

    public boolean isRecycled() {
        return dispatcher == null;
    }

    public <E> E cast(Class<E> clazz) {
        return clazz.cast(this);
    }
}
