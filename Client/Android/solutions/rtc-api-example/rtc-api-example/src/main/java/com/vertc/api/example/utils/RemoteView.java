package com.vertc.api.example.utils;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.ss.bytertc.engine.data.RemoteStreamKey;

@MainThread
public class RemoteView {
    @NonNull
    public final ViewGroup parent;

    private RemoteStreamKey streamKey;

    public RemoteView(@NonNull ViewGroup parent) {
        this.parent = parent;
    }

    public boolean isEmpty() {
        return streamKey == null;
    }

    public boolean match(@Nullable String uid) {
        if (streamKey == null || TextUtils.isEmpty(uid)) {
            return false;
        }

        return TextUtils.equals(streamKey.userId, uid);
    }

    public RemoteStreamKey getStreamKey() {
        return streamKey;
    }

    public void attach(RemoteStreamKey streamKey, View view) {
        this.parent.removeAllViews();
        this.parent.addView(view);
        this.streamKey = streamKey;
    }

    public void detach() {
        this.parent.removeAllViews();
        this.streamKey = null;
    }

    public static RemoteView of(@NonNull ViewGroup parent) {
        return new RemoteView(parent);
    }
}
