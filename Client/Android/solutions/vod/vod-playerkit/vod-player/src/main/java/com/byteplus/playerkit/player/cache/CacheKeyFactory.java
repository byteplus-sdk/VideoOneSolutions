// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.cache;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.utils.MD5;

import java.net.MalformedURLException;
import java.net.URL;


public interface CacheKeyFactory {

    CacheKeyFactory DEFAULT = new CacheKeyFactory() {
        @Override
        public String generateCacheKey(@NonNull MediaSource source, @NonNull Track track) {
            if (!TextUtils.isEmpty(track.getFileHash())) {
                return track.getFileHash();
            }
            if (!TextUtils.isEmpty(track.getFileId())) {
                return track.getFileId();
            }
            String fileHash = generateCacheKey(track.getUrl());
            track.setFileHash(fileHash);
            return fileHash;
        }

        @Override
        public String generateCacheKey(@NonNull String url) {
            String path;
            try {
                URL u = new URL(url);
                path = u.getPath();
            } catch (MalformedURLException e) {
                path = url;
            }
            return MD5.getMD5(path);
        }
    };

    String generateCacheKey(@NonNull MediaSource source, @NonNull Track track);

    String generateCacheKey(@NonNull String url);
}
