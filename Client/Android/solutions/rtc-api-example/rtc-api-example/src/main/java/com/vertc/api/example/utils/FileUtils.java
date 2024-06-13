package com.vertc.api.example.utils;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.Closeable;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class FileUtils {
    @NonNull
    public static InputStream openFile(@NonNull Context context, @NonNull String filePath) throws IOException {
        if (filePath.startsWith("/assets/")) { // Assets File
            String assetName = filePath.substring(8); // remove the '/assets/' prefix
            return context.getAssets().open(assetName);
        } else { // Local file
            return new FileInputStream(filePath);
        }
    }

    public static void closeQuietly(@Nullable Closeable closeable) {
        if (closeable == null) return;

        try {
            closeable.close();
        } catch (IOException ignored) {

        }
    }
}
