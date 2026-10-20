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
import com.byteplus.vod.minidrama.remote.model.drama.DramaTheaterEntity;
import com.byteplus.vod.minidrama.remote.model.drama.DramaTheaterType;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 首页数据返回后，为前 9 个不同剧目各预加载一个入口视频。
 * 滚动不改变任务；点击或离开首页时停止任务，播放页继续使用原有场景策略。
 */
final class DramaHomePreloader {
    private static final int HOME_VIDEO_COUNT = 9;
    private static final long PRELOAD_BYTES = 200L * 1024L;

    private final CacheLoader mCacheLoader;
    private final GetDramas mRemoteApi = new GetDramas();
    private final List<MediaSource> mSources = new ArrayList<>();
    private int mGeneration;

    DramaHomePreloader(CacheLoader cacheLoader) {
        mCacheLoader = cacheLoader;
    }

    void preload(DramaTheaterEntity home) {
        stop();
        if (mCacheLoader == null || !DramaSettings.isTheaterEntryPreloadEnabled()) return;

        final int generation = mGeneration;
        Set<String> dramaIds = new HashSet<>();
        // 按首页分区顺序取 9 个不同剧目，轮播和列表中的重复剧目只取一次。
        for (DramaTheaterType type : DramaTheaterType.values()) {
            for (DramaInfo info : home.getInfos(type)) {
                if (dramaIds.size() >= HOME_VIDEO_COUNT) break;
                if (info == null || TextUtils.isEmpty(info.dramaId)
                        || !dramaIds.add(info.dramaId)) continue;
                final int index = dramaIds.size();
                DramaEntryEpisode entry = info.entryEpisode;
                if (entry != null && entry.isUsable(System.currentTimeMillis())
                        && !TextUtils.isEmpty(entry.getMediaId())) {
                    preloadEntry(info, index, generation);
                } else {
                    // 兼容尚未返回 entry_episode 的 Demo 服务端；客户接入建议批量返回入口数据。
                    mRemoteApi.getDramaList(info.dramaId, new HttpCallback<>() {
                        @Override
                        public void onSuccess(List<DramaFeed> feeds) {
                            if (generation != mGeneration) return;
                            for (DramaFeed feed : feeds) {
                                if (feed == null || feed.isLocked()
                                        || TextUtils.isEmpty(feed.vid) || feed.episodeNumber <= 0) continue;
                                DramaEntryEpisode entry = new DramaEntryEpisode();
                                entry.reason = DramaEntryEpisode.REASON_FIRST_PLAY;
                                entry.feed = feed;
                                info.entryEpisode = entry;
                                preloadEntry(info, index, generation);
                                return;
                            }
                            log("skip", index, info.dramaId, "no playable entry");
                        }

                        @Override
                        public void onError(Throwable error) {
                            if (generation == mGeneration) {
                                log("error", index, info.dramaId, "entry request failed");
                            }
                        }
                    });
                }
            }
        }
        L.i(this, "homePreload", "event=batch selected=" + dramaIds.size()
                + " target=" + HOME_VIDEO_COUNT + " preloadBytes=" + PRELOAD_BYTES);
    }

    private void preloadEntry(DramaInfo info, int index, int generation) {
        if (generation != mGeneration) return;
        DramaEntryEpisode entry = info.entryEpisode;
        if (!entry.isUsable(System.currentTimeMillis())) {
            log("skip", index, info.dramaId, "entry expired");
            return;
        }
        if (TextUtils.isEmpty(entry.feed.dramaId)) {
            entry.feed.dramaId = info.dramaId;
        }
        VideoItem item = entry.feed.toVideoItem();
        VideoItem.playScene(item, PlayScene.SCENE_SHORT);
        MediaSource source = VideoItem.toMediaSource(item);
        source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_SIZE_IN_BYTES, PRELOAD_BYTES);
        if (DramaSettings.isTheaterResumePointPreloadEnabled()) {
            source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_START_TIMESTAMP_MS,
                    Math.max(0L, entry.resumePositionMs));
        }
        mSources.add(source);
        log("submit", index, source.getMediaId(), "preloadBytes=" + PRELOAD_BYTES);
        // 直接提交这 9 个任务，下载调度由 SDK 负责，不维护业务侧队列。
        mCacheLoader.preload(source, new CacheLoader.Task.Listener.Adapter() {
            @Override
            public void onFinished(CacheLoader.Task task) {
                log("finished", index, source.getMediaId(), "preloadBytes=" + PRELOAD_BYTES);
            }

            @Override
            public void onStopped(CacheLoader.Task task) {
                log("stopped", index, source.getMediaId(), "");
            }

            @Override
            public void onError(CacheLoader.Task task, IOException error) {
                log("error", index, source.getMediaId(), "preload failed");
            }
        });
    }

    void stop() {
        // 失效旧的异步列表回调，防止点击播放后又补交首页任务。
        mGeneration++;
        mRemoteApi.cancel();
        for (MediaSource source : mSources) {
            mCacheLoader.stopTask(source);
        }
        mSources.clear();
    }

    private void log(String event, int index, String mediaId, String detail) {
        L.i(this, "homePreload", "event=" + event + " index=" + index
                + " mediaId=" + mediaId + " " + detail);
    }
}
