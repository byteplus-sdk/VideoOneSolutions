// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common;

import android.content.Context;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;


public class WriterPCMFile {

    private static final String TAG = "WaveAudioWriter";
    private static final int SAMPLE_RATE = 48000;
    private static final short CHANNELS = (short) 2;
    private static final short BIT_PER_SAMPLE = (short) 16;
    private static final long MAX_SIZE = 10 * 1024 * 1024;

    private File mFile;
    private ByteArrayOutputStream mByteBuffer;
    private boolean mFinished = false;

    public WriterPCMFile(int rate, int channels, int bitDepth, String filePrefix, String endian) {
        Context context = AppUtil.getApplicationContext();
        try {
            File recDir = new File(context.getExternalFilesDir("TTSDK"), "audioSource");
            if (!recDir.exists() && recDir.mkdirs()) {
                throw new IOException("failed to mkdirs: " + recDir.getAbsolutePath());
            }
            String fileName = filePrefix + "_" + System.currentTimeMillis() + "_";
            if (bitDepth == 32) {
                fileName += "f32";
            } else if (bitDepth == 16) {
                fileName += "s16";
            }
            fileName += endian; // le、be
            fileName += "_" + rate + "_" + channels;
            File file = new File(recDir, fileName + ".pcm");
            if (!file.exists() && !file.createNewFile()) {
                throw new IOException("failed to createNewFile: " + file.getAbsolutePath());
            }
            mFile = file;
            mByteBuffer = new ByteArrayOutputStream();
        } catch (IOException e) {
            Log.d(TAG, "WriterPCMFile: init failed", e);
        }
    }

    public void writeBytes(byte[] data) {
        if (mFinished) {
            return;
        }
        if (mByteBuffer == null) {
            return;
        }
        mByteBuffer.write(data, 0, data.length);
        Log.i(TAG, "write:" + data.length + ",size:" + mByteBuffer.size());
        if (mByteBuffer.size() > MAX_SIZE) {
            Log.d(TAG, "reach max size.");
            finish();
        }
    }

    public void finish() {
        Log.i(TAG, "finish");
        if (mByteBuffer == null) {
            Log.d(TAG, "Buffer is null!");
            return;
        }
        if (mFile == null) {
            Log.e(TAG, "File is null!");
            return;
        }
        try (FileOutputStream fos = new FileOutputStream(mFile)) {
            mByteBuffer.writeTo(fos);
            mFinished = true;
        } catch (IOException e) {
            Log.d(TAG, "Write to file failed: " + mFile.getAbsolutePath(), e);
        }
        mByteBuffer = null;
    }
}
