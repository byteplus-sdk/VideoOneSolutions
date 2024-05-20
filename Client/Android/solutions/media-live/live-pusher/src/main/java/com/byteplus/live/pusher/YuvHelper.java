// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicYuvToRGB;
import android.renderscript.Type;

import java.nio.ByteBuffer;

public class YuvHelper {
    public static class NV21ToBitmap {
        private RenderScript rs;
        private ScriptIntrinsicYuvToRGB yuvToRgbIntrinsic;
        private Type.Builder yuvType, rgbaType;

        public NV21ToBitmap(Context context) {
            rs = RenderScript.create(context);
            yuvToRgbIntrinsic = ScriptIntrinsicYuvToRGB.create(rs, Element.U8_4(rs));
            yuvType = new Type.Builder(rs, Element.U8(rs));
            rgbaType = new Type.Builder(rs, Element.RGBA_8888(rs));
        }

        public Bitmap nv21ToBitmap(byte[] nv21, int width, int height) {
            yuvType.setX(nv21.length);
            Allocation in = Allocation.createTyped(rs, yuvType.create(), Allocation.USAGE_SCRIPT);
            in.copyFrom(nv21);

            rgbaType.setX(width).setY(height);
            Allocation out = Allocation.createTyped(rs, rgbaType.create(), Allocation.USAGE_SCRIPT);
            yuvToRgbIntrinsic.setInput(in);
            yuvToRgbIntrinsic.forEach(out);

            Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            out.copyTo(bmp);

            return bmp;
        }
    }

    public static void NV21toI420(ByteBuffer input, ByteBuffer output, final int width, final int height) {
        final int size = width * height;
        final int quarter = size / 4;
        final int v0 = size + quarter;

        System.arraycopy(input.array(), 0, output.array(), 0, size); // Y is same

        for (int u = size, v = v0, o = size; u < v0; u++, v++, o += 2) {
            output.array()[v] = input.array()[o]; // For NV21, V first
            output.array()[u] = input.array()[o + 1]; // For NV21, U second
        }
    }

    public static void NV21toNV12(ByteBuffer input, ByteBuffer output, final int width, final int height) {
        final int size = width * height;

        System.arraycopy(input.array(), 0, output.array(), 0, size); // Y is same
        for (int i = size; i < 1.5f * size; i += 2) {
            output.array()[i] = input.array()[i + 1];
            output.array()[i + 1] = input.array()[i];
        }
    }

    public static void NV12toI420(ByteBuffer input, ByteBuffer output, final int width, final int height) {
        final int size = width * height;
        final int quarter = size / 4;
        final int v0 = size + quarter;

        System.arraycopy(input.array(), 0, output.array(), 0, size); // Y is same

        for (int u = size, v = v0, o = size; u < v0; u++, v++, o += 2) {
            output.array()[v] = input.array()[o + 1]; // For NV12, U first
            output.array()[u] = input.array()[o]; // For NV12, V second
        }
    }

    public static void I420toNV21(ByteBuffer input, ByteBuffer output, final int width, final int height) {
        final int size = width * height;
        final int quarter = size / 4;
        final int v0 = size + quarter;

        System.arraycopy(input.array(), 0, output.array(), 0, size); // Y is same

        for (int u = size, v = v0, o = size; u < v0; u++, v++, o += 2) {
            output.array()[o + 1] = input.array()[v];
            output.array()[o] = input.array()[u];
        }
    }

    public static Bitmap rotateBitmap(Bitmap origin, float alpha, boolean horizontalMirror, boolean verticalMirror) {
        if (origin == null) {
            return null;
        }
        int width = origin.getWidth();
        int height = origin.getHeight();
        Matrix matrix = new Matrix();
        float sx = 1;
        float sy = 1;
        if (horizontalMirror) {
            sx = -1;
        }
        if (verticalMirror) {
            sy = -1;
        }
        matrix.postScale(sx, sy);
        matrix.postRotate(alpha);
        return Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
    }
}
