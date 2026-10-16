// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import android.graphics.Bitmap;
import android.opengl.GLES20;
import android.opengl.GLUtils;


import android.os.Handler;
import android.os.Looper;


import java.nio.ByteBuffer;

public class TextureMgr {
    private int generateTexture() {
        int[] textures = new int[1];
        GLES20.glGenTextures(1, textures, 0);
        return textures[0];
    }
    private int texture;
    private int width;
    private int height;
    private android.content.Context mContext;
    public TextureMgr(android.content.Context context, int width, int height) {
        mContext = context;
        this.width = width;
        this.height = height;
        new Handler(Looper.getMainLooper()).post(() -> {
            if (texture <= 0) {
                texture = generateTexture();
                GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture);
                GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, width, height, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
                GLES20.glFinish();
                
            }
        });
    }

    public interface RenderListener {
        void doBusiness(int texture);
    }

    public void dealWithTexture(ByteBuffer byteBuffer, RenderListener listener) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (texture > 0) {
                    YuvHelper.NV21ToBitmap bm = new YuvHelper.NV21ToBitmap(mContext);
                    Bitmap bmp = bm.nv21ToBitmap(byteBuffer.array(), width, height);
                    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture);
                    GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0,
                            YuvHelper.rotateBitmap(bmp,0,false, true), 0);
                    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
                    GLES20.glFlush();
                    listener.doBusiness(texture);
                }
            }
        });
    }
}
