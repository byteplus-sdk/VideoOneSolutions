package com.vertc.api.example.utils;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

@MainThread
public class RemoteView {
    @NonNull
    public final ViewGroup parent;

    private String streamId;
    private String userId;

    public RemoteView(@NonNull ViewGroup parent) {
        this.parent = parent;
    }

    public boolean isEmpty() {
        return streamId == null;
    }

    public boolean match(@Nullable String uid) {
        if (streamId == null || TextUtils.isEmpty(uid)) {
            return false;
        }

        return TextUtils.equals(userId, uid);
    }

    public String getStreamId() {
        return streamId;
    }

    public void attach(String userId, String streamId, View view) {
        this.parent.removeAllViews();
        this.parent.addView(view);
        this.userId = userId;
        this.streamId = streamId;
    }

    public void detach() {
        this.parent.removeAllViews();
        this.userId = null;
        this.streamId = null;
    }

    public static RemoteView of(@NonNull ViewGroup parent) {
        return new RemoteView(parent);
    }
}
