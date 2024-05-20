// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import android.app.AlertDialog;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.byteplus.live.pusher.utils.RawFile;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class MediaResourceMgr {
    private static final String TAG = "MediaResourceMgr";

    private static final Executor executor = Executors.newSingleThreadExecutor(
            r -> new Thread(r, "media-resource-downloader")
    );

    public enum RawVideo implements RawFile {
        /**
         * You can change the file address below, but comply with the following requirements:
         * the video file needs to be in NV21 format
         */
        NV21(480,
                800,
                15,
                "https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/videoone_480_800_15_nv21.yuv",
                75.81F,
                "video_480x800_15fps_nv21.yuv");

        public final int width;
        public final int height;
        public final int frameRate;

        public final String url;
        public final float sizeInMB;
        public final String fileName;

        RawVideo(int width, int height, int frameRate, String url, float sizeInMB, String fileName) {
            this.width = width;
            this.height = height;
            this.frameRate = frameRate;
            this.url = url;
            this.sizeInMB = sizeInMB;
            this.fileName = fileName;
        }

        @Override
        public float getSizeInMB() {
            return sizeInMB;
        }

        @NonNull
        @Override
        public String getFileName() {
            return fileName;
        }

        @NonNull
        @Override
        public String getUrl() {
            return url;
        }
    }

    public enum RawAudio implements RawFile {
        /**
         * You can change the file address below, but comply with the following requirements:
         * the audio file needs to be in PCM format, with a sampleRate 44100khz, 16bit, stereo
         */
        PCM_1(
                44100,
                16,
                2,
                "https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/videoone_44100_16bit_2ch.pcm",
                1.53F,
                "audio_44100_16bit_2ch.pcm"
        );

        public final int sampleRate;
        public final int bitDepth;
        public final int channelCount;

        public final String url;
        public final float sizeInMB;
        public final String fileName;

        RawAudio(int sampleRate, int bitDepth, int channelCount,
                 String url, float sizeInMB, String fileName) {
            this.sampleRate = sampleRate;
            this.bitDepth = bitDepth;
            this.channelCount = channelCount;
            this.url = url;
            this.sizeInMB = sizeInMB;
            this.fileName = fileName;
        }

        @Override
        public float getSizeInMB() {
            return sizeInMB;
        }

        @NonNull
        @Override
        public String getFileName() {
            return fileName;
        }

        @NonNull
        @Override
        public String getUrl() {
            return url;
        }
    }

    public static void prepare(Context context) {

    }

    public static File getLocalFile(@NonNull Context context, @NonNull RawFile file) {
        return new File(context.getFilesDir(), file.getFileName());
    }

    public static boolean isLocalFileReady(@NonNull Context context, @NonNull RawFile file) {
        return getLocalFile(context, file).exists();
    }

    public interface DownloadListener {
        default void onSuccess() {
        }

        default void onFail() {
        }
    }

    public static void downloadOnlineResource(Context context, List<RawFile> files, DownloadListener listener) {
        Handler handler = new Handler(Looper.getMainLooper());
        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(context)
                .setTitle(R.string.medialive_whether_download);
        StringBuilder message = new StringBuilder();
        for (RawFile file : files) {
            message.append(context.getString(R.string.medialive_download_filename_size, file.getFileName(), file.getSizeInMB()));
            message.append("\n");
        }
        dialogBuilder.setMessage(message.toString());
        dialogBuilder.setPositiveButton(R.string.medialive_confirm, (dialog, which) -> {
            executor.execute(() -> {
                final String[] currentFileName = new String[1];
                try {
                    for (RawFile file : files) {
                        currentFileName[0] = file.getLocalPath(context);
                        handler.post(() -> {
                            Toast.makeText(context, context.getString(R.string.medialive_xxx_downloading, file.getFileName()), Toast.LENGTH_SHORT).show();
                            listener.onSuccess();
                        });
                        downloadFile(file.getUrl(), file.getLocalPath(context));
                    }
                    handler.post(() -> {
                        Toast.makeText(context, R.string.medialive_downloaded, Toast.LENGTH_SHORT).show();
                        listener.onSuccess();
                    });
                } catch (IOException e) {
                    File file = new File(currentFileName[0]);
                    if (file.exists()) {
                        file.delete();
                    }
                    handler.post(() -> {
                        Toast.makeText(context, context.getString(R.string.medialive_xxx_download_failed_toast, currentFileName[0]), Toast.LENGTH_SHORT).show();
                        listener.onFail();
                    });
                }
            });
        });
        dialogBuilder.setNegativeButton(R.string.medialive_cancel, (dialog, which) -> {
            Toast.makeText(context, R.string.medialive_download_failed_toast, Toast.LENGTH_SHORT).show();
            listener.onFail();
        });
        dialogBuilder.show();
    }

    static void downloadFile(String url, String filePath) throws IOException {
        Log.d(TAG, "downloadFile: " + url);
        File file = new File(filePath);
        if (file.exists()) {
            return;
        }
        URL urlObj = new URL(url);
        HttpURLConnection conn = (HttpURLConnection) urlObj.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);
        conn.connect();
        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            try (InputStream is = new BufferedInputStream(conn.getInputStream());
                 OutputStream os = new FileOutputStream(filePath)) {
                int read;
                byte[] bytes = new byte[4096];
                while ((read = is.read(bytes)) != -1) {
                    os.write(bytes, 0, read);
                }
            }
        }
        conn.disconnect();
    }
}
