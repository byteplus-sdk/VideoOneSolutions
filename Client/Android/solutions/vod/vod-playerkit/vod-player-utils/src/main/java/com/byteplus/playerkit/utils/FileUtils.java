// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;

import androidx.annotation.Nullable;

import java.io.File;
import java.util.List;

public class FileUtils {

    public static void deleteFile(File file, @Nullable List<String> suffixes) {
        if (file == null) return;
        if (file.isDirectory()) {
            File[] files = file.listFiles();
            if (files != null) {
                for (File f : files) {
                    deleteFile(f, suffixes);
                }
            }
        } else {
            if (suffixes != null) {
                String name = file.getName();
                String suffix = name.substring(name.lastIndexOf("."));
                if (suffixes.contains(suffix)) {
                    file.delete();
                }
            } else {
                file.delete();
            }
        }
    }

    public static long getFileSize(File file) {
        return getFileSize(file, null);
    }

    public static long getFileSize(File file, @Nullable List<String> suffixes) {
        long size = 0;
        if (file == null) return size;
        if (file.isDirectory()) {
            File[] files = file.listFiles();
            if (files != null) {
                for (File f : files) {
                    size += getFileSize(f, suffixes);
                }
            }
        } else {
            if (suffixes != null) {
                String name = file.getName();
                int index = name.lastIndexOf(".");
                if (index >= 0) {
                    String suffix = name.substring(index);
                    if (suffixes.contains(suffix)) {
                        size += file.length();
                    }
                }
            } else {
                size += file.length();
            }
        }
        return size;
    }

    public static String formatSize(long bytes) {
        if (bytes <= 0) {
            return "0";
        } else if (bytes < 1024) {
            return bytes + "B";
        } else if (bytes < 1024 * 1024) {
            return (bytes / 1024) + "KB";
        } else if (bytes < 1024 * 1024 * 1024) {
            return (bytes / 1024 / 1024) + "MB";
        } else {
            return (bytes / 1024 / 1024 / 1024) + "GB";
        }
    }
}
