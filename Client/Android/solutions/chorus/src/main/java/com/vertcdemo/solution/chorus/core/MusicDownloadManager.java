// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.core;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.chorus.core.rts.annotation.DownloadType;
import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.chorus.event.DownloadStatusChanged;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.HashSet;

public class MusicDownloadManager {
    private static final String TAG = "MusicDownloadManager";

    private static final MusicDownloadManager sInstance = new MusicDownloadManager();

    public static MusicDownloadManager ins() {
        return sInstance;
    }

    private final HashMap<String, HashSet<String>> mDownloadToken = new HashMap<>();

    private MusicDownloadManager() {
    }

    private boolean enqueueDownload(String token, String roomId) {
        synchronized (mDownloadToken) {
            HashSet<String> roomIds = mDownloadToken.get(token);
            if (roomIds == null) {
                roomIds = new HashSet<>();
                roomIds.add(roomId);
                mDownloadToken.put(token, roomIds);
                return true;
            } else {
                roomIds.add(roomId);
                return false;
            }
        }
    }

    private HashSet<String> removeToken(String token) {
        synchronized (mDownloadToken) {
            return mDownloadToken.remove(token);
        }
    }

    public void downloadLrc(@NonNull String songId, @NonNull String roomId, String lrcUrl) {
        download(songId, roomId, null, lrcUrl);
    }

    public void download(@NonNull String songId, @NonNull String roomId, @Nullable String mp3Url, @Nullable String lrcUrl) {
        Log.d(TAG, "download: id=" + songId + "; mp3=" + mp3Url + "; lrc=" + lrcUrl);
        boolean isNeedDownloadMusic = mp3Url != null;
        boolean isNeedDownloadLrc = lrcUrl != null;
        if (isNeedDownloadMusic) {
            File mp3File = mp3File(songId);
            if (mp3File.exists()) {
                // Downloaded
                SolutionEventBus.post(new DownloadStatusChanged(roomId, songId, DownloadType.MUSIC));
            } else {
                String token = songId + ".mp3";
                if (enqueueDownload(token, roomId)) {
                    SolutionEventBus.post(new DownloadStatusChanged(roomId, songId, DownloadType.MUSIC, SongStatus.DOWNLOADING));
                    AppExecutors.networkIO().execute(() -> {
                        boolean success = downloadFile(mp3Url, mp3File);
                        Log.d(TAG, "download: token=" + token + "; success=" + success);
                        HashSet<String> roomIds = removeToken(token);
                        if (roomIds != null) {
                            SolutionEventBus.post(new DownloadStatusChanged(roomIds, songId, DownloadType.MUSIC,
                                    success ? SongStatus.DOWNLOADED : SongStatus.NOT_DOWNLOAD));
                        }
                    });
                }
            }
        }

        if (isNeedDownloadLrc) {
            File lrcFile = lrcFile(songId);
            if (lrcFile.exists()) {
                // Downloaded
                SolutionEventBus.post(new DownloadStatusChanged(roomId, songId, DownloadType.LRC));
            } else {
                String token = songId + ".lrc";
                if (enqueueDownload(token, roomId)) {
                    AppExecutors.networkIO().execute(() -> {
                        boolean success = downloadFile(lrcUrl, lrcFile);
                        Log.d(TAG, "download: token=" + token + "; success=" + success);
                        HashSet<String> roomIds = removeToken(token);
                        if (roomIds != null) {
                            SolutionEventBus.post(new DownloadStatusChanged(roomIds, songId, DownloadType.LRC,
                                    success ? SongStatus.DOWNLOADED : SongStatus.NOT_DOWNLOAD));
                        }
                    });
                }
            }
        }
    }

    static boolean downloadFile(@NonNull String url, @NonNull File target) {
        File parent = target.getParentFile();
        assert parent != null;
        if (!parent.exists() && !parent.mkdirs()) {
            Log.e(TAG, "downloadFile: failed to create Folder");
            return false;
        }

        HttpURLConnection connection = null;
        try {
            File tempFile = File.createTempFile("karaoke-cache-", ".tmp", parent);
            connection = (HttpURLConnection) new URL(url).openConnection();
            connection.connect();
            int statusCode = connection.getResponseCode();
            if (statusCode != HttpURLConnection.HTTP_OK) {
                return false;
            }
            try (InputStream input = new BufferedInputStream(connection.getInputStream());
                 OutputStream output = new BufferedOutputStream(new FileOutputStream(tempFile))) {
                byte[] data = new byte[4096];
                int count;
                while ((count = input.read(data)) != -1) {
                    output.write(data, 0, count);
                }
            }
            return tempFile.renameTo(target);
        } catch (Exception e) {
            Log.d(TAG, "downloadFile: ", e);
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
        return false;
    }

    public static File lrcFile(String songId) {
        Context context = AppUtil.getApplicationContext();
        return new File(context.getExternalFilesDir(null), "karaoke_resources/" + songId + ".lrc");
    }

    public static File mp3File(String songId) {
        Context context = AppUtil.getApplicationContext();
        return new File(context.getExternalFilesDir(null), "karaoke_resources/" + songId + ".mp3");
    }
}
