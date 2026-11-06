// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.text.TextUtils;

import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaEntryEpisode;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 首页停止滚动后更新可见窗口；保留重合任务，取消离屏任务，不清除磁盘缓存。
 * Update the visible window when home scrolling stops; retain overlaps and cached data.
 */
final class DramaHomePreloader {
    static final int MAX_ENTRIES = 9;
    static final long PRELOAD_BYTES = 300L * 1024L;

    private final CacheLoader mCacheLoader;
    private final Map<String, Entry> mEntries = new LinkedHashMap<>();

    private static final class Entry {
        final DramaInfo info;
        final GetDramas request = new GetDramas();
        MediaSource source;

        Entry(DramaInfo info) {
            this.info = info;
        }
    }

    DramaHomePreloader(CacheLoader cacheLoader) {
        mCacheLoader = cacheLoader;
    }

    void updateVisible(List<DramaInfo> visible) {
        if (mCacheLoader == null || !DramaSettings.isTheaterEntryPreloadEnabled()) {
            stop();
            return;
        }
        Map<String, DramaInfo> desired = new LinkedHashMap<>();
        for (DramaInfo info : visible) {
            if (desired.size() == MAX_ENTRIES) break;
            if (info != null && !TextUtils.isEmpty(info.dramaId)) {
                desired.putIfAbsent(info.dramaId, info);
            }
        }
        // 先移除再添加：请求入口信息的候选也计入九个上限。
        // Remove before adding; pending entry requests also count toward the nine-item limit.
        for (String id : new ArrayList<>(mEntries.keySet())) {
            if (!desired.containsKey(id)) remove(id);
        }
        for (DramaInfo info : desired.values()) {
            if (mEntries.containsKey(info.dramaId)) continue;
            Entry entry = new Entry(info);
            mEntries.put(info.dramaId, entry);
            resolveEntry(entry);
        }
        L.i(this, "homeWindow", "count=" + mEntries.size()
                + " limit=" + MAX_ENTRIES + " bytes=" + PRELOAD_BYTES);
    }

    private boolean isCurrent(Entry entry) {
        // 使用对象身份防止“离屏后又返回同一剧目”的旧回调复活。
        // Match the entry instance so stale callbacks cannot revive an item that left and re-entered.
        return mEntries.get(entry.info.dramaId) == entry;
    }

    private void resolveEntry(Entry entry) {
        DramaEntryEpisode episode = entry.info.entryEpisode;
        if (episode != null && episode.isUsable(System.currentTimeMillis())) {
            submit(entry);
            return;
        }
        // Demo 后端缺少入口字段，才逐剧补取列表。生产首页应批量返回
        // entry_episode、凭证及续播位置，避免额外的完整列表请求。
        // Fetch a drama list only when the demo response lacks entry metadata.
        // Production feeds should batch entry episodes, credentials and resume positions.
        entry.request.getDramaList(entry.info.dramaId, new HttpCallback<>() {
            @Override
            public void onSuccess(List<DramaFeed> feeds) {
                if (!isCurrent(entry)) return;
                if (feeds != null) {
                    for (DramaFeed feed : feeds) {
                        if (feed == null || feed.isLocked() || TextUtils.isEmpty(feed.vid)
                                || feed.episodeNumber <= 0) continue;
                        DramaEntryEpisode episode = new DramaEntryEpisode();
                        episode.reason = DramaEntryEpisode.REASON_FIRST_PLAY;
                        episode.feed = feed;
                        entry.info.entryEpisode = episode;
                        submit(entry);
                        return;
                    }
                }
                L.i(DramaHomePreloader.this, "homeWindow", "skip=noPlayableEntry");
            }

            @Override
            public void onError(Throwable error) {
                if (isCurrent(entry)) {
                    L.w(DramaHomePreloader.this, "homeWindow", "skip=entryRequestFailed");
                }
            }
        });
    }

    private void submit(Entry entry) {
        if (!isCurrent(entry) || entry.source != null) return;
        DramaEntryEpisode episode = entry.info.entryEpisode;
        if (episode == null || !episode.isUsable(System.currentTimeMillis())
                || TextUtils.isEmpty(episode.getMediaId())) return;
        if (TextUtils.isEmpty(episode.feed.dramaId)) {
            episode.feed.dramaId = entry.info.dramaId;
        }
        VideoItem item = episode.feed.toVideoItem();
        VideoItem.playScene(item, PlayScene.SCENE_SHORT);
        MediaSource source = VideoItem.toMediaSource(item);
        source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_SIZE_IN_BYTES, PRELOAD_BYTES);
        if (DramaSettings.isTheaterResumePointPreloadEnabled()) {
            source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_START_TIMESTAMP_MS,
                    Math.max(0L, episode.resumePositionMs));
        }
        entry.source = source;
        L.i(this, "homeWindow", "submit=" + source.getMediaId() + " bytes=" + PRELOAD_BYTES);
        mCacheLoader.preload(source, new CacheLoader.Task.Listener.Adapter() {
            @Override
            public void onFinished(CacheLoader.Task task) {
                if (isCurrent(entry)) {
                    L.i(DramaHomePreloader.this, "homeWindow", "finished=" + source.getMediaId());
                }
            }

            @Override
            public void onError(CacheLoader.Task task, IOException error) {
                if (isCurrent(entry)) {
                    L.w(DramaHomePreloader.this, "homeWindow", "failed=" + source.getMediaId());
                }
            }
        });
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
