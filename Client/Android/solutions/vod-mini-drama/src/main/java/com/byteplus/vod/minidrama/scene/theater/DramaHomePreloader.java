// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.text.TextUtils;
import android.os.SystemClock;

import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaEntryEpisode;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import com.byteplus.vod.minidrama.scene.settings.HomePreloadConfig;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Predicate;

/**
 * 可见项优先，前方一排准备、后方一排保留；取消不清磁盘缓存。
 */
final class DramaHomePreloader {
    static final int MAX_ENTRIES = 9;
    static final int BASIC_MAX_ENTRIES = 2;
    static final long PRELOAD_BYTES = 300L * 1024L;
    static final int MAX_COMPLETED = 64;

    private final CacheLoader mCacheLoader;
    private final Map<String, Entry> mEntries = new LinkedHashMap<>();
    private final Predicate<String> mCanStart;
    private final Predicate<DramaInfo> mBeforeSubmit;
    private final Runnable mTaskCompleted;
    private final Map<List<Object>, CacheLoader.Task.CacheSnapshot> mCompleted =
            new LinkedHashMap<>(MAX_COMPLETED, 0.75f, true);

    private static final class Entry {
        DramaInfo info;
        final GetDramas request = new GetDramas();
        MediaSource source;
        List<Object> key;
        boolean finished;
        boolean unavailable;
        final long admittedAtMs = SystemClock.uptimeMillis();
        long submittedAtMs;

        Entry(DramaInfo info) {
            this.info = info;
        }
    }

    DramaHomePreloader(CacheLoader cacheLoader) {
        this(cacheLoader, id -> true);
    }

    DramaHomePreloader(CacheLoader cacheLoader, Predicate<String> canStart) {
        this(cacheLoader, canStart, info -> false);
    }

    DramaHomePreloader(CacheLoader cacheLoader, Predicate<String> canStart,
                       Predicate<DramaInfo> beforeSubmit) {
        this(cacheLoader, canStart, beforeSubmit, () -> {});
    }

    DramaHomePreloader(CacheLoader cacheLoader, Predicate<String> canStart,
                       Predicate<DramaInfo> beforeSubmit, Runnable taskCompleted) {
        mCacheLoader = cacheLoader;
        mCanStart = canStart;
        mBeforeSubmit = beforeSubmit;
        mTaskCompleted = taskCompleted;
    }

    void updateVisible(List<DramaInfo> visible) {
        if (mCacheLoader == null || !DramaSettings.isTheaterEntryPreloadEnabled()) {
            stop();
            return;
        }
        boolean enhanced = DramaSettings.getHomePreloadConfig().enhancedWindowEnabled;
        int limit = enhanced ? MAX_ENTRIES : BASIC_MAX_ENTRIES;
        Map<String, DramaInfo> desired = new LinkedHashMap<>();
        for (DramaInfo info : visible) {
            addDesired(desired, info);
            // 关闭增强时固定两项，完成后不继续扩张同一个静止窗口。
            // Basic mode counts completed entries too, so completion cannot expand this window.
            if (!enhanced && desired.size() >= limit) break;
        }
        if (enhanced && visible instanceof HomePreloadWindow window) {
            for (DramaInfo info : window.forward) addDesired(desired, info);
            // 后方只保留已有任务，不能新查入口或补发下载。
            for (DramaInfo info : window.backward) {
                if (info != null && mEntries.containsKey(info.dramaId)) addDesired(desired, info);
            }
        }
        // 先规划额度、取消低优先级任务，再启动新任务，避免切窗时瞬间超过9个。
        Map<String, DramaInfo> planned = new LinkedHashMap<>();
        int reserved = 0;
        for (DramaInfo info : desired.values()) {
            Entry entry = mEntries.get(info.dramaId);
            if (entry != null && entry.unavailable && createSource(info) == null) {
                planned.put(info.dramaId, info);
            } else if (entry != null && entry.finished
                    && Objects.equals(entry.key, sourceKey(info, createSource(info)))) {
                planned.put(info.dramaId, info);
            } else if (reserved < limit) {
                planned.put(info.dramaId, info);
                reserved++;
            }
        }
        for (String id : new ArrayList<>(mEntries.keySet())) {
            if (!planned.containsKey(id)) remove(id);
        }
        int pending = 0;
        for (DramaInfo info : planned.values()) {
            Entry existing = mEntries.get(info.dramaId);
            if (existing != null && existing.finished) {
                // 原Feed被原地修改也要重建任务；不能只按剧目ID复用。
                if (Objects.equals(existing.key, sourceKey(info, createSource(info)))) {
                    existing.info = info;
                    if (mCanStart.test(info.dramaId)) mBeforeSubmit.test(info);
                    continue;
                }
                remove(info.dramaId);
                existing = null;
            }
            if (pending >= limit) {
                if (existing != null) remove(info.dramaId);
                continue;
            }
            if (existing == null) {
                if (!mCanStart.test(info.dramaId)) continue;
                existing = new Entry(info);
                mEntries.put(info.dramaId, existing);
                resolveEntry(existing);
            } else {
                existing.info = info;
                submit(existing);
            }
            if (!existing.finished && !existing.unavailable) pending++;
        }
        L.i(this, "homeWindow", "count=" + mEntries.size()
                + " pending=" + pending + " limit=" + limit + " bytes=" + PRELOAD_BYTES
                + " enhanced=" + enhanced);
    }

    private static void addDesired(Map<String, DramaInfo> desired, DramaInfo info) {
        if (info == null || TextUtils.isEmpty(info.dramaId)) return;
        if (DramaSettings.getHomePreloadConfig().entrySource == HomePreloadConfig.EntrySource.FEED_ONLY) {
            DramaEntryEpisode episode = info.entryEpisode;
            if (episode == null || episode.demoFallback || !episode.isUsable(System.currentTimeMillis())) return;
        }
        desired.putIfAbsent(info.dramaId, info);
    }

    private boolean isCurrent(Entry entry) {
        // 使用对象身份防止“离屏后又返回同一剧目”的旧回调复活。
        // Match the entry instance so stale callbacks cannot revive an item that left and re-entered.
        return mEntries.get(entry.info.dramaId) == entry;
    }

    private void resolveEntry(Entry entry) {
        DramaEntryEpisode episode = entry.info.entryEpisode;
        boolean feedOnly = DramaSettings.getHomePreloadConfig().entrySource
                == HomePreloadConfig.EntrySource.FEED_ONLY;
        if (episode != null && (!feedOnly || !episode.demoFallback)
                && episode.isUsable(System.currentTimeMillis())) {
            submit(entry);
            return;
        }
        if (feedOnly) {
            L.i(this, "homeWindow", "skip=missingFeedEntry");
            return;
        }
        // 仅供 Demo 模拟：每部剧单独请求完整列表，取第一个可播项；满窗口最多补9次。
        // Demo simulation only: one full-list request per drama, up to nine in a full window.
        // 线上改为 Feed 内嵌入口或客户实现的聚合接口；这里不是批量接口，也不查询真实续播。
        // Production needs embedded feed entries or a customer batch API; this is neither batch nor resume lookup.
        L.i(this, "homeWindow", "demoFallback=requestDramaList");
        entry.request.getDramaList(entry.info.dramaId, new HttpCallback<>() {
            @Override
            public void onSuccess(List<DramaFeed> feeds) {
                if (!isCurrent(entry)) return;
                if (feeds != null) {
                    for (DramaFeed feed : feeds) {
                        if (feed == null || feed.isLocked() || TextUtils.isEmpty(feed.vid)
                                || TextUtils.isEmpty(feed.playAuthToken) || feed.episodeNumber <= 0) continue;
                        DramaEntryEpisode episode = new DramaEntryEpisode();
                        episode.reason = DramaEntryEpisode.REASON_FIRST_PLAY;
                        episode.feed = feed;
                        episode.demoFallback = true;
                        entry.info.entryEpisode = episode;
                        submit(entry);
                        return;
                    }
                }
                entry.unavailable = true;
                L.i(DramaHomePreloader.this, "homeWindow", "skip=noPlayableEntry");
                mTaskCompleted.run();
            }

            @Override
            public void onError(Throwable error) {
                if (isCurrent(entry)) {
                    entry.unavailable = true;
                    L.w(DramaHomePreloader.this, "homeWindow", "skip=entryRequestFailed");
                    mTaskCompleted.run();
                }
            }
        });
    }

    private void submit(Entry entry) {
        if (!isCurrent(entry) || !mCanStart.test(entry.info.dramaId)) return;
        DramaEntryEpisode episode = entry.info.entryEpisode;
        if (episode != null && episode.demoFallback
                && DramaSettings.getHomePreloadConfig().entrySource
                == HomePreloadConfig.EntrySource.FEED_ONLY) return;
        if (episode == null || !episode.isUsable(System.currentTimeMillis())
                || TextUtils.isEmpty(episode.getMediaId())) return;
        if (TextUtils.isEmpty(episode.feed.dramaId)) {
            episode.feed.dramaId = entry.info.dramaId;
        }
        // 单次预热期间延后媒体预加载，复用已解析入口，不额外补查详情。
        // Defer media preloads during the one-shot warmup, reusing the resolved entry.
        if (mBeforeSubmit.test(entry.info)) return;
        MediaSource source = createSource(entry.info);
        List<Object> key = sourceKey(entry.info, source);
        if (entry.source != null && Objects.equals(entry.key, key)) return;
        if (entry.source != null) {
            MediaSource previous = entry.source;
            entry.source = null;
            mCacheLoader.stopTask(previous);
        }
        entry.key = key;
        CacheLoader.Task.CacheSnapshot cached = mCompleted.get(key);
        if (cached != null) {
            if (cached.isValid()) {
                entry.finished = true;
                L.i(this, "homeWindow", "reuse=" + source.getMediaId());
                return;
            }
            mCompleted.remove(key);
        }
        entry.finished = false;
        entry.unavailable = false;
        entry.source = source;
        entry.submittedAtMs = SystemClock.uptimeMillis();
        L.i(this, "homeWindow", "submit=" + source.getMediaId() + " bytes=" + PRELOAD_BYTES);
        mCacheLoader.preload(source, new CacheLoader.Task.Listener.Adapter() {
            @Override
            public void onFinished(CacheLoader.Task task) {
                if (isCurrent(entry) && entry.source == source) {
                    // 先记录回调时刻，磁盘快照检查不计入 SDK 下载耗时。
                    // Capture callback time before disk snapshot work.
                    long finishedAtMs = SystemClock.uptimeMillis();
                    entry.finished = true;
                    CacheLoader.Task.CacheSnapshot snapshot = task.getCacheSnapshot();
                    if (snapshot != null) {
                        mCompleted.put(key, snapshot);
                        while (mCompleted.size() > MAX_COMPLETED) {
                            mCompleted.remove(mCompleted.keySet().iterator().next());
                        }
                    }
                    L.i(DramaHomePreloader.this, "homeWindow", "finished=" + source.getMediaId()
                            + " downloadMs=" + (finishedAtMs - entry.submittedAtMs)
                            + " entryWaitMs=" + (entry.submittedAtMs - entry.admittedAtMs)
                            + " totalMs=" + (finishedAtMs - entry.admittedAtMs));
                    mTaskCompleted.run();
                }
            }

            @Override
            public void onError(CacheLoader.Task task, IOException error) {
                if (isCurrent(entry) && entry.source == source) {
                    entry.source = null;
                    L.w(DramaHomePreloader.this, "homeWindow", "failed=" + source.getMediaId());
                }
            }

            @Override
            public void onStopped(CacheLoader.Task task) {
                if (isCurrent(entry) && entry.source == source) entry.source = null;
            }
        });
    }

    private static MediaSource createSource(DramaInfo info) {
        DramaEntryEpisode episode = info.entryEpisode;
        if (episode == null || !episode.isUsable(System.currentTimeMillis())) return null;
        VideoItem item = episode.feed.toVideoItem();
        VideoItem.playScene(item, PlayScene.SCENE_SHORT);
        MediaSource source = VideoItem.toMediaSource(item);
        source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_SIZE_IN_BYTES, PRELOAD_BYTES);
        source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_CACHE_SNAPSHOT, true);
        if (DramaSettings.isTheaterResumePointPreloadEnabled()) {
            source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_START_TIMESTAMP_MS,
                    Math.max(0L, episode.resumePositionMs));
        }
        return source;
    }

    private static List<Object> sourceKey(DramaInfo info, MediaSource source) {
        if (source == null) return null;
        List<Object> key = new ArrayList<>();
        key.add(info.dramaId);
        key.add(info.entryEpisode.feed.episodeNumber);
        key.add(info.entryEpisode.historyUpdatedAtMs);
        key.add(source.getSourceType());
        key.add(source.getMediaId());
        key.add(source.getPlayAuthToken());
        key.add(source.getModelJson());
        key.add(source.getExtra(CacheLoader.Task.EXTRA_PRELOAD_START_TIMESTAMP_MS, Long.class));
        key.add(PRELOAD_BYTES);
        if (source.getTracks() != null) {
            for (Track track : source.getTracks()) {
                key.add(track.getUrl());
                key.add(track.getFileHash());
                key.add(track.getFileId());
                key.add(track.getFormat());
                key.add(track.getQuality());
                key.add(track.getEncryptedKey());
                key.add(track.getEncryptedKeyId());
                key.add(track.getTrackType());
                key.add(track.getPreloadSize());
                key.add(track.getBackupUrls() == null ? null : new ArrayList<>(track.getBackupUrls()));
                key.add(track.getHeaders() == null ? null : new LinkedHashMap<>(track.getHeaders()));
            }
        }
        return key;
    }

    void pauseMediaPreloads() {
        // 保留入口解析结果，停止本页媒体任务；预热结束后按当前窗口恢复。
        // Retain resolved entries while stopping this page's tasks; resume the current window afterward.
        for (Entry entry : mEntries.values()) {
            MediaSource source = entry.source;
            entry.source = null;
            if (entry.finished) continue;
            entry.finished = false;
            if (source != null) mCacheLoader.stopTask(source);
        }
    }

    private void remove(String id) {
        Entry entry = mEntries.remove(id);
        if (entry == null) return;
        entry.request.cancel();
        if (entry.source != null) mCacheLoader.stopTask(entry.source);
        L.i(this, "homeWindow", "remove=" + id);
    }

    void stop() {
        for (String id : new ArrayList<>(mEntries.keySet())) remove(id);
    }
}
