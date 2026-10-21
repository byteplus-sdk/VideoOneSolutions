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
 * 首页只创建数据预加载任务，不创建预渲染播放器；详情页再启用原有预渲染策略。
 * 滚动不改变任务；点击或离开首页时停止任务，播放页继续使用原有场景策略。
 *
 * <p>Preloads one entry video for each of the first 9 unique dramas after the home feed loads.
 * The home page creates data preload tasks only; the detail page uses its existing pre-render policy.
 * Scrolling keeps the tasks unchanged. Tapping a drama or leaving the home page stops them.
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
        // Take 9 unique dramas in section order, deduplicating carousel and list entries.
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
                    // 仅用于 Demo 验证：当前服务端不返回入口信息，为选中的剧目逐个请求列表。
                    // 线上不要照搬此方式：9 个剧目会增加最多 9 次业务 HTTP 请求及完整列表数据。
                    // 应由首页接口批量返回 entry_episode、播放凭证和续播位置；
                    // 缺失或无效时跳过首页预加载，点击后再走正常详情加载。
                    // Demo only: the current backend does not return entry metadata, so the
                    // selected drama lists are requested individually.
                    // Do not copy this into production. Nine dramas can add up to nine business
                    // HTTP requests and full episode-list payloads.
                    // The production home API should batch-return entry_episode, playback
                    // authorization, and resume positions. If any entry is missing or invalid,
                    // skip its home preload and use the normal detail flow after the user taps.
                    mRemoteApi.getDramaList(info.dramaId, new HttpCallback<>() {
                        @Override
                        public void onSuccess(List<DramaFeed> feeds) {
                            if (generation != mGeneration) return;
                            // 按返回顺序取首条可播放集，未强制 order=1，也不还原服务端续播历史。
                            // Use the first playable entry in response order, without restoring server history.
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
            // 续播入口从媒体内的历史位置预加载，减少恢复播放后的下载等待。
            // Preload from the resume position within the media to reduce waiting on resumed playback.
            source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_START_TIMESTAMP_MS,
                    Math.max(0L, entry.resumePositionMs));
        }
        mSources.add(source);
        log("submit", index, source.getMediaId(), "preloadBytes=" + PRELOAD_BYTES);
        // 直接提交这 9 个任务，下载调度由 SDK 负责，不维护业务侧队列。
        // Submit the selected tasks directly; the SDK schedules downloads without an app-side queue.
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
        // Invalidate old list callbacks so they cannot submit home tasks after playback starts.
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
