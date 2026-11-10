// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import android.text.TextUtils;

import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.source.Track;
import com.bytedance.vcloud.cacheModule.CacheFileManager;
import com.ss.ttvideoengine.DataLoaderHelper;
import com.ss.ttvideoengine.TTVideoEngine;

import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** SDK成功后保存实际缓存范围；HLS的下载百分比不参与字节判断。 */
final class VolcPreloadCacheSnapshot implements CacheLoader.Task.CacheSnapshot {
    private static final int MAX_CACHE_NODES = 128;
    private static final String PLAYLIST_SUFFIX = ".plc";
    private static final String PLAYLIST_INDEX_SUFFIX = ".plcnodeconf";
    private static final int MAX_PLAYLIST_URLS = 8;
    private final List<CacheLoader.Task.CacheSnapshot> ranges = new ArrayList<>();

    static CacheLoader.Task.CacheSnapshot capture(String key, File cacheDir, long startMs) {
        if (TextUtils.isEmpty(key)) return null;
        try {
            VolcPreloadCacheSnapshot snapshot = new VolcPreloadCacheSnapshot();
            if (CacheFileManager.isCacheKey(key, CacheFileManager.CacheFileType.Preload)) {
                if (!snapshot.capturePlaylist(key, cacheDir, new HashSet<>())) return null;
            } else {
                DataLoaderHelper.DataLoaderCacheInfo info = TTVideoEngine.getCacheInfo(key);
                if (info == null || !info.mIsSizeInfoTrusted || TextUtils.isEmpty(info.mLocalFilePath)) return null;
                if (startMs == 0 || info.mMediaSize > 0 && info.mCacheSizeFromZero >= info.mMediaSize) {
                    if (!snapshot.capturePrefix(key, false)) return null;
                } else {
                    // 非零起点按媒体时间检查连续缓存，不能用文件总大小替代目标范围。
                    long bytes = TTVideoEngine.getContinueCacheSize(key, Track.TRACK_TYPE_VIDEO, startMs);
                    if (bytes <= 0) return null;
                    snapshot.ranges.add(() -> TTVideoEngine.getContinueCacheSize(
                            key, Track.TRACK_TYPE_VIDEO, startMs) >= bytes);
                }
            }
            return snapshot.ranges.isEmpty() ? null : snapshot;
        } catch (RuntimeException | LinkageError error) {
            // 旧缓存格式或SDK能力缺失时继续正常预加载，不影响播放。
            return null;
        }
    }

    private boolean capturePlaylist(String key, File cacheDir, Set<String> visited) {
        if (!visited.add(key)) return true;
        if (visited.size() > MAX_CACHE_NODES || ranges.size() >= MAX_CACHE_NODES) return false;
        // 多URL缓存按_u0、_u1落盘；旧格式直接使用key。只检查有限路径，不扫描缓存目录。
        File indexFile = new File(cacheDir, key + PLAYLIST_INDEX_SUFFIX);
        if (!indexFile.isFile() || indexFile.length() <= 0) return false;
        // 后续预加载会追加分片索引；已有目标的文件仍有效时不因索引追加而失效。
        ranges.add(() -> indexFile.isFile() && indexFile.length() > 0);
        boolean hasManifest = captureFile(new File(cacheDir, key + PLAYLIST_SUFFIX));
        for (int index = 0; index < MAX_PLAYLIST_URLS; index++) {
            hasManifest |= captureFile(new File(cacheDir, key + "_u" + index + PLAYLIST_SUFFIX));
        }
        if (!hasManifest) return false;
        CacheFileManager.TsCacheNodeInfo[] nodes = CacheFileManager.getTsCacheInfos(
                key, CacheFileManager.CacheFileType.Preload);
        if (nodes == null || nodes.length == 0 || nodes.length > MAX_CACHE_NODES) return false;
        boolean hasMedia = false;
        for (CacheFileManager.TsCacheNodeInfo node : nodes) {
            if (node == null || TextUtils.isEmpty(node.fileKey) || node.version < 2) return false;
            if (node.keyType == CacheFileManager.TsCacheNodeInfo.KEY_TYPE_M3U8) {
                if (!capturePlaylist(node.fileKey, cacheDir, visited)) return false;
                hasMedia = true;
            } else if (node.keyType == CacheFileManager.TsCacheNodeInfo.KEY_TYPE_TS) {
                // 只登记成功时真正存在的分片；未请求的后续分片不属于本次目标。
                if (TTVideoEngine.getCacheFileSize(node.fileKey) > 0) {
                    if (!capturePrefix(node.fileKey, true)) return false;
                    hasMedia = true;
                }
            } else {
                return false;
            }
        }
        return hasMedia;
    }

    private boolean capturePrefix(String key, boolean requireContiguous) {
        if (ranges.size() >= MAX_CACHE_NODES) return false;
        DataLoaderHelper.DataLoaderCacheInfo info = TTVideoEngine.getCacheInfo(key);
        if (info == null || !info.mIsSizeInfoTrusted || info.mCacheSizeFromZero <= 0
                || TextUtils.isEmpty(info.mLocalFilePath)) return false;
        long bytes = info.mCacheSizeFromZero;
        // 分片中存在空洞时，头部字节不能证明时间起点附近的数据仍在。
        if (requireContiguous && TTVideoEngine.quickGetCacheFileSize(key) != bytes) return false;
        File file = new File(info.mLocalFilePath);
        ranges.add(() -> {
            DataLoaderHelper.DataLoaderCacheInfo current = TTVideoEngine.getCacheInfo(key);
            return file.isFile() && file.length() >= bytes && current != null && current.mIsSizeInfoTrusted
                    && current.mCacheSizeFromZero >= bytes
                    && TextUtils.equals(info.mLocalFilePath, current.mLocalFilePath);
        });
        return true;
    }

    private boolean captureFile(File file) {
        if (!file.isFile() || file.length() <= 0 || ranges.size() >= MAX_CACHE_NODES) return false;
        long length = file.length();
        long modified = file.lastModified();
        ranges.add(() -> file.isFile() && file.length() == length && file.lastModified() == modified);
        return true;
    }

    @Override public boolean isValid() {
        try {
            for (CacheLoader.Task.CacheSnapshot range : ranges) {
                if (!range.isValid()) return false;
            }
            return !ranges.isEmpty();
        } catch (RuntimeException | LinkageError error) {
            return false;
        }
    }
}
