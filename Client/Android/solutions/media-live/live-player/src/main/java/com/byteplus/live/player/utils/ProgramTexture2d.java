// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.utils;

import android.opengl.GLES20;

import com.byteplus.live.player.utils.core.Drawable2d;
import com.byteplus.live.player.utils.core.GlUtil;
import com.byteplus.live.player.utils.core.Program;


public class ProgramTexture2d extends Program {

    // Simple vertex shader, used for all programs.
    private static final String VERTEX_SHADER = "uniform mat4 uSTMatrix;\n"
            + "attribute vec4 aPosition;\n"
            + "attribute vec4 aTextureCoord;\n"
            + "varying vec2 vTextureCoord;\n"
            + "void main() {\n"
            + "  gl_Position = aPosition;\n"
            + "  vTextureCoord = (aTextureCoord).xy;\n" + "}\n";
    private static final String FRAGMENT_SHADER_2D = "precision mediump float;\n"
        + "varying vec2 vTextureCoord;\n"
        + "uniform sampler2D sTexture;\n"
        + "void main() {\n"
        + "  gl_FragColor = texture2D(sTexture, vTextureCoord);\n"
        + "}\n";

    private int muMVPMatrixLoc;
    private int muTexMatrixLoc;
    private int maPositionLoc;
    private int maTextureCoordLoc;
    protected int mInputTextureHandle;

    public ProgramTexture2d() {
        super(VERTEX_SHADER, FRAGMENT_SHADER_2D);
    }

    @Override
    protected Drawable2d getDrawable2d() {
        return new Drawable2dFull();
    }

    @Override
    protected void getLocations() {
        maPositionLoc = GLES20.glGetAttribLocation(mProgramHandle, "aPosition");
        GlUtil.checkLocation(maPositionLoc, "aPosition");
        maTextureCoordLoc = GLES20.glGetAttribLocation(mProgramHandle, "aTextureCoord");
        GlUtil.checkLocation(maTextureCoordLoc, "aTextureCoord");
        mInputTextureHandle = GLES20.glGetUniformLocation(mProgramHandle, "sTexture");
//        muMVPMatrixLoc = GLES20.glGetUniformLocation(mProgramHandle, "uMVPMatrix");
//        GlUtil.checkLocation(muMVPMatrixLoc, "uMVPMatrix");
//        muTexMatrixLoc = GLES20.glGetUniformLocation(mProgramHandle, "uTexMatrix");
//        GlUtil.checkLocation(muTexMatrixLoc, "uTexMatrix");
    }

    @Override
    public void drawFrame(int textureId, float[] texMatrix, float[] mvpMatrix) {
        GlUtil.checkGlError("draw start");

        // Select the program.
        GLES20.glUseProgram(mProgramHandle);

        GlUtil.checkGlError("glUseProgram");

        // Set the texture.
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
//        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);
        GLES20.glUniform1i(mInputTextureHandle, 0);
        // Copy the model / view / projection matrix over.
//        GLES20.glUniformMatrix4fv(muMVPMatrixLoc, 1, false, mvpMatrix, 0);
//        GlUtil.checkGlError("glUniformMatrix4fv");

        // Copy the texture transformation matrix over.
//        GLES20.glUniformMatrix4fv(muTexMatrixLoc, 1, false, texMatrix, 0);
//        GlUtil.checkGlError("glUniformMatrix4fv");

        // Enable the "aPosition" vertex attribute.
        GLES20.glEnableVertexAttribArray(maPositionLoc);
        GlUtil.checkGlError("glEnableVertexAttribArray");

        // Connect vertexBuffer to "aPosition".
        GLES20.glVertexAttribPointer(maPositionLoc, Drawable2d.COORDS_PER_VERTEX,
                GLES20.GL_FLOAT, false, Drawable2d.VERTEXTURE_STRIDE, mDrawable2d.vertexArray());
        GlUtil.checkGlError("glVertexAttribPointer");

        // Enable the "aTextureCoord" vertex attribute.
        GLES20.glEnableVertexAttribArray(maTextureCoordLoc);
        GlUtil.checkGlError("glEnableVertexAttribArray");



        // Connect texBuffer to "aTextureCoord".
        GLES20.glVertexAttribPointer(maTextureCoordLoc, 2,
                GLES20.GL_FLOAT, false, Drawable2d.TEXTURE_COORD_STRIDE, mDrawable2d.texCoordArray());
        GlUtil.checkGlError("glVertexAttribPointer");

        // Draw the rect.
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, mDrawable2d.vertexCount());
        GlUtil.checkGlError("glDrawArrays");

        // Done -- disable vertex array, texture, and program.
        GLES20.glDisableVertexAttribArray(maPositionLoc);
        GLES20.glDisableVertexAttribArray(maTextureCoordLoc);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
        GLES20.glUseProgram(0);
        GLES20.glFinish();
    }

}
