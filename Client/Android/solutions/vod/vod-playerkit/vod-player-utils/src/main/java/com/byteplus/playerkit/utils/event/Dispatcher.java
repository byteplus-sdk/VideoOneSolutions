// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils.event;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import androidx.annotation.NonNull;

import java.lang.ref.WeakReference;
import java.util.concurrent.CopyOnWriteArrayList;

public class Dispatcher {

    public interface EventListener {
        void onEvent(Event event);
    }

    public static class EventListeners implements EventListener {

        private final CopyOnWriteArrayList<EventListener> mListeners = new CopyOnWriteArrayList<>();

        public final void addEventListener(EventListener listener) {
            this.mListeners.addIfAbsent(listener);
        }

        public final void removeEventListener(EventListener listener) {
            if (listener != null) {
                this.mListeners.remove(listener);
            }
        }

        public final void removeAllEventListener() {
            this.mListeners.clear();
        }

        @Override
        public void onEvent(Event event) {
            for (EventListener listener : mListeners) {
                listener.onEvent(event);
            }
        }
    }

    private final H mHandler;
    private final EventListeners mListeners = new EventListeners();

    public Dispatcher(Looper looper) {
        this.mHandler = new H(looper, this);
    }

    public <T extends Event> T obtain(Class<T> clazz, Object owner) {
        final T event = Config.EVENT_POOL_ENABLE ? Pool.acquire(clazz) : Factory.create(clazz);
        return clazz.cast(event.owner(owner).dispatcher(this));
    }

    public final void addEventListener(EventListener listener) {
        this.mListeners.addEventListener(listener);
    }

    public final void removeEventListener(EventListener listener) {
        this.mListeners.removeEventListener(listener);
    }

    public final void removeAllEventListener() {
        this.mListeners.removeAllEventListener();
    }

    public void dispatchEvent(Event event) {
        if (Thread.currentThread() != this.mHandler.getLooper().getThread()) {
            this.mHandler.obtainMessage(0, event).sendToTarget();
        } else {
            dispatch(event);
        }
    }

    public void release() {
        mHandler.post(() -> {
            mHandler.removeCallbacksAndMessages(null);
            mListeners.removeAllEventListener();
        });
    }

    private void dispatch(Event event) {
        mListeners.onEvent(event);
        if (event.dispatcher() == this) {
            if (Config.EVENT_POOL_ENABLE) {
                Pool.release(event);
            }
        }
    }

    private final static class H extends Handler {
        private final WeakReference<Dispatcher> mRef;

        H(@NonNull Looper looper, Dispatcher dispatcher) {
            super(looper);
            this.mRef = new WeakReference<>(dispatcher);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            final Dispatcher dispatcher = this.mRef.get();
            if (dispatcher == null) return;

            if (msg.what == 0) {
                dispatcher.dispatch((Event) msg.obj);
                return;
            }
            throw new IllegalArgumentException();
        }
    }
}
