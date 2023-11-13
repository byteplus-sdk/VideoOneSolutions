// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.cache;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.playerkit.player.source.Track;
import com.bytedance.playerkit.utils.MD5;


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
            return MD5.getMD5(url);
        }
    };

    String generateCacheKey(@NonNull MediaSource source, @NonNull Track track);

    String generateCacheKey(@NonNull String url);
}
