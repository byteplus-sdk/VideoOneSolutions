// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
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

    @NonNull
    public static File getAppPicturesDir(@NonNull Context context, @NonNull String relativePath) {
        File base = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        if (base == null) {
            base = context.getFilesDir();
        }
        File dir = new File(base, relativePath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    public static boolean exportImageToGallery(@NonNull Context context, @NonNull File source, @NonNull String displayName) {
        return exportToGallery(context, source, displayName, "image/jpeg", Environment.DIRECTORY_PICTURES + File.separator + "VideoOne");
    }

    public static boolean exportVideoToGallery(@NonNull Context context, @NonNull File source, @NonNull String displayName) {
        return exportToGallery(context, source, displayName, "video/mp4", Environment.DIRECTORY_MOVIES + File.separator + "VideoOne");
    }

    private static boolean exportToGallery(
            @NonNull Context context,
            @NonNull File source,
            @NonNull String displayName,
            @NonNull String mimeType,
            @NonNull String relativePath
    ) {
        if (!source.exists()) {
            return false;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContentResolver resolver = context.getContentResolver();
            Uri collection = mimeType.startsWith("video/")
                    ? MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                    : MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);

            ContentValues values = new ContentValues();
            values.put(MediaStore.MediaColumns.DISPLAY_NAME, displayName);
            values.put(MediaStore.MediaColumns.MIME_TYPE, mimeType);
            values.put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath);
            values.put(MediaStore.MediaColumns.IS_PENDING, 1);

            Uri uri = resolver.insert(collection, values);
            if (uri == null) {
                return false;
            }
            try (OutputStream out = resolver.openOutputStream(uri);
                 InputStream in = new FileInputStream(source)) {
                if (out == null) {
                    resolver.delete(uri, null, null);
                    return false;
                }
                copy(in, out);
            } catch (Exception e) {
                resolver.delete(uri, null, null);
                return false;
            }

            ContentValues done = new ContentValues();
            done.put(MediaStore.MediaColumns.IS_PENDING, 0);
            resolver.update(uri, done, null, null);
            return true;
        }

        File publicBase = Environment.getExternalStoragePublicDirectory(
                mimeType.startsWith("video/") ? Environment.DIRECTORY_MOVIES : Environment.DIRECTORY_PICTURES
        );
        File targetDir = new File(publicBase, "VideoOne");
        if (!targetDir.exists() && !targetDir.mkdirs()) {
            return false;
        }
        File target = new File(targetDir, displayName);
        try (InputStream in = new FileInputStream(source);
             OutputStream out = new FileOutputStream(target)) {
            copy(in, out);
        } catch (Exception e) {
            return false;
        }
        updateToAlbum(context, target);
        return true;
    }

    private static void copy(@NonNull InputStream in, @NonNull OutputStream out) throws Exception {
        byte[] buffer = new byte[8192];
        int read;
        while ((read = in.read(buffer)) >= 0) {
            out.write(buffer, 0, read);
        }
        out.flush();
    }
}
