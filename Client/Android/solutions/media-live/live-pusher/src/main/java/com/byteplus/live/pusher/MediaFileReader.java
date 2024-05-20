// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;

import com.ss.avframework.utils.TimeUtils;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.concurrent.atomic.AtomicBoolean;

public class MediaFileReader {
    private static final String TAG = "MediaFileReader";
    private String mFilePath;
    private int mFrameSize;
    private Callback mCallback;
    private long mInterval;
    private final AtomicBoolean mEnable = new AtomicBoolean(false);
    private ByteBuffer mByteBuffer;

    public MediaFileReader() {
        mByteBuffer = ByteBuffer.allocateDirect(1920 * 1080 * 3 / 2); // I420 One Frame Size
    }

    public interface Callback {
        void onByteBuffer(ByteBuffer byteBuffer, long pts);
    }

    public void start(String path, int frameSize, int interval, Callback callback) {
        if (TextUtils.isEmpty(path) || frameSize <= 0 || interval < 0 || callback == null) {
            return;
        }
        mEnable.set(true);
        mFilePath = path;
        mFrameSize = frameSize;
        mCallback = callback;
        mInterval = interval;
        new Thread(() -> {
            while (mEnable.get()) {
                doBusiness();
            }
        }).start();
    }

    public void stop() {
        mEnable.set(false);
    }

    private void doBusiness() {
        long timeUs = TimeUtils.nanoTime() / 1000;
        byte[] data = new byte[mFrameSize];
        try (FileInputStream dis = new FileInputStream(mFilePath)) {
            while (mEnable.get()) {
                int readCount = dis.read(data);
                if (readCount < mFrameSize) {
                    break;
                }
                mByteBuffer.clear();
                mByteBuffer.put(data);
                mByteBuffer.flip();
                mCallback.onByteBuffer(mByteBuffer, timeUs);
                timeUs += mInterval * 1000;
                long waitTimeUs = timeUs - (TimeUtils.nanoTime() / 1000);
                if (waitTimeUs > 0) {
                    SystemClock.sleep(waitTimeUs / 1000);
                }
            }
        } catch (IOException e) {
            Log.d(TAG, "doBusiness: failed", e);
        }
    }
}
