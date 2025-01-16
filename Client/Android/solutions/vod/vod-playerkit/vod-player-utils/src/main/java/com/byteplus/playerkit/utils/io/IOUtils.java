// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils.io;

import android.os.Build;

import androidx.annotation.Nullable;

import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;


public class IOUtils {

    public static Charset charset() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            return StandardCharsets.UTF_8;
        }
        return Charset.forName("UTF-8");
    }

    public static void closeQuietly(Closeable closeable) {
        try {
            if (closeable != null) closeable.close();
        } catch (IOException e) { /* ignored */ }
    }

    @Nullable
    public static String headerValue(Map<String, List<String>> headers, String name) {
        if (headers == null) return null;
        List<String> values = headers.get(name);
        if (values != null && !values.isEmpty()) {
            return values.get(values.size() - 1);
        }
        return null;
    }

    public static long parseLong(String input) {
        try {
            return Long.parseLong(input);
        } catch (NumberFormatException e) { /* ignore */ }
        return -1;
    }

    @Nullable
    public static String inputStream2String(InputStream inputStream) {
        if (inputStream == null) return null;
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int read;
        try {
            while ((read = inputStream.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            return out.toString(charset().name());
        } catch (IOException e) {
            return null;
        }
    }
}
