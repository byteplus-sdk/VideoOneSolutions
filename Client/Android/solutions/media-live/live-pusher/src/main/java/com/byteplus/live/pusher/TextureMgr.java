// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import android.graphics.Bitmap;
import android.opengl.GLES20;
import android.opengl.GLUtils;

import com.pandora.common.env.Env;
import com.ss.avframework.opengl.GLThreadManager;
import com.ss.avframework.opengl.GlUtil;

import java.nio.ByteBuffer;

public class TextureMgr {
    private int texture;
    private int width;
    private int height;
    public TextureMgr(int width, int height) {
        this.width = width;
        this.height = height;
        GLThreadManager.getMainGlHandle().post(() -> {
            if (texture <= 0) {
                texture = GlUtil.generateTexture(GLES20.GL_TEXTURE_2D);
                GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture);
                GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, width, height, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
                GLES20.glFinish();
                GlUtil.checkNoGLES2Error("clearBackgroundTex");
            }
        });
    }

    public interface RenderListener {
        void doBusiness(int texture);
    }

    public void dealWithTexture(ByteBuffer byteBuffer, RenderListener listener) {
        GLThreadManager.getMainGlHandle().post(new Runnable() {
            @Override
            public void run() {
                if (texture > 0) {
                    YuvHelper.NV21ToBitmap bm = new YuvHelper.NV21ToBitmap(Env.getApplicationContext());
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
