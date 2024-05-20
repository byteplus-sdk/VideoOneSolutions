// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Objects;

public class FileUtils {
    public static boolean saveBitmap(Bitmap bitmap, @NonNull File target) {
        File path = Objects.requireNonNull(target.getParentFile());
        if (!path.exists() && !path.mkdirs()) {
            return false;
        }
        try (FileOutputStream fos = new FileOutputStream(target)) {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static void updateToAlbum(Context context, File file) {
        Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file));
        context.sendBroadcast(intent);
    }
}
