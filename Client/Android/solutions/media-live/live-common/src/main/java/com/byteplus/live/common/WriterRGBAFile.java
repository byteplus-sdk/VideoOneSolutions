// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common;

import android.content.Context;
import android.util.Log;

import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

public class WriterRGBAFile implements Closeable {
    private final static String TAG = "WriterRGBAFile";

    private final int frameWidth;
    private final int frameHeight;

    private FileOutputStream outputStream;
    private boolean mFinished = false;

    public WriterRGBAFile(int width, int height) {
        this(width, height, 15);
    }

    public WriterRGBAFile(int width, int height, int fps) {
        frameWidth = width;
        frameHeight = height;
        Context context = AppUtil.getApplicationContext();
        try {
            File parent = new File(context.getExternalFilesDir("TTSDK"), "VideoSource");
            if (!parent.exists() && !parent.mkdirs()) {
                throw new IOException("mkdirs failed: " + parent);
            }
            File file = new File(parent, System.currentTimeMillis() + "_" + frameWidth + "_" + frameHeight + "_" + fps + ".rgba");
            if (!file.exists() && !file.createNewFile()) {
                throw new IOException("createNewFile failed: " + file);
            }
            outputStream = new FileOutputStream(file);
        } catch (IOException e) {
            Log.d(TAG, "WriterRGBAFile create failed", e);
        }
    }

    public void writeBytes(byte[] data) {
        if (data == null) {
            return;
        }
        if (mFinished || outputStream == null) {
            return;
        }
        try {
            outputStream.write(data);
            Log.d(TAG, "writeBytes(byte[]) length:" + data.length);
        } catch (IOException e) {
            Log.d(TAG, "writeBytes: failed", e);
        }

    }

    public void writeBytes(ByteBuffer data) {
        if (data == null) {
            return;
        }
        if (mFinished || outputStream == null) {
            return;
        }
        try {
            byte[] array = new byte[data.remaining()];
            data.get(array);
            outputStream.write(array);
            Log.d(TAG, "writeBytes length:" + array.length);
        } catch (IOException e) {
            Log.d(TAG, "writeBytes(ByteBuffer): failed", e);
        }
    }

    @Override
    public void close() throws IOException {
        mFinished = true;
        outputStream.close();
    }

    public void finish() {
        Log.d(TAG, "finish");
        try {
            close();
        } catch (IOException e) {
            Log.d(TAG, "finish error", e);
        }
    }
}
