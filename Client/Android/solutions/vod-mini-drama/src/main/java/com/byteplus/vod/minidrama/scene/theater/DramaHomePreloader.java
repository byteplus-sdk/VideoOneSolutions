// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.text.TextUtils;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.playback.PlayerPool;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.utils.ProgressRecorder;
import com.byteplus.playerkit.utils.event.Dispatcher;
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
 * 默认额外 prepare 首个候选，仅演示单候选预渲染的用法，不代表业务推荐策略。
 * 业务可根据播放历史选择最可能被点击的入口；不推荐同时预渲染多个，以控制内存和解码器开销。
 * 预渲染的下载量不受 200 KiB 数据预加载预算限制，收益取决于用户是否点击同一入口。
 * 本示例依赖 VideoOne 默认开启的 TextureRender 提供内部离屏输出，首帧就绪以 frameReady 为准。
 * 滚动不改变任务；点击或离开首页时停止任务，播放页继续使用原有场景策略。
 *
 * <p>Preloads one entry video for each of the first 9 unique dramas after the home feed loads.
 * Also prepares the first candidate by default, solely to demonstrate single-candidate pre-rendering.
 * Apps should choose the likely entry using playback history. Preparing multiple candidates is
 * not recommended because it consumes additional memory and decoder resources.
 * Preparation downloads are not capped by the 200 KiB data preload budget; the benefit depends
 * on the user tapping the same entry.
 * This example relies on VideoOne's default TextureRender for internal offscreen output.
 * Check frameReady to confirm the first frame is ready; prepared alone is not sufficient.
 * Scrolling keeps the tasks unchanged. Tapping a drama or leaving the home page stops them.
 */
final class DramaHomePreloader {
    private static final int HOME_VIDEO_COUNT = 9;
    private static final int PRE_RENDER_CANDIDATE_INDEX = 1;
    private static final long PRELOAD_BYTES = 200L * 1024L;

    private final CacheLoader mCacheLoader;
    private final GetDramas mRemoteApi = new GetDramas();
    private final List<MediaSource> mSources = new ArrayList<>();
    private Player mPreRenderPlayer;
    private MediaSource mPreRenderSource;
    private final Dispatcher.EventListener mPreRenderListener = event -> {
        // 忽略已释放候选的延迟事件，防止旧回调影响刷新后的实例。
        // Ignore delayed events from a released candidate so they cannot affect its replacement.
        if (event.owner(Player.class) != mPreRenderPlayer) return;
        if (event.code() == PlayerEvent.State.PREPARED) {
            L.i(this, "homePreRender", "event=prepared", mPreRenderPlayer);
        } else if (event.code() == PlayerEvent.Info.VIDEO_RENDERING_START_BEFORE_START) {
            L.i(this, "homePreRender", "event=frameReady", mPreRenderPlayer);
        } else if (event.code() == PlayerEvent.State.ERROR) {
            L.w(this, "homePreRender", "event=error", mPreRenderPlayer);
            releasePreRender();
        }
    };
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
        if (index == PRE_RENDER_CANDIDATE_INDEX) {
            prepareEntry(entry);
        }
    }

    private void prepareEntry(DramaEntryEpisode entry) {
        if (!DramaSettings.isTheaterEntryPreRenderEnabled() || DramaSettings.isAdsEnabled()) return;
        VideoItem item = entry.feed.toVideoItem();
        VideoItem.playScene(item, PlayScene.SCENE_SHORT);
        VideoItem.syncProgress(item, true);
        MediaSource source = VideoItem.toMediaSource(item);
        // 与详情页使用同一续播位置；仅在没有本地进度时补充服务端进度。
        // Use the detail page's resume position, filling server progress only when none is local.
        if (ProgressRecorder.getProgress(source.getSyncProgressId()) <= 0 && entry.resumePositionMs > 0) {
            ProgressRecorder.recordProgress(source.getSyncProgressId(), entry.resumePositionMs);
        }
        // 不接管已经在其他页面使用的播放器；本示例最多持有一个首页播放器。
        // Do not take over a player used by another page. This example holds at most one home player.
        if (PlayerPool.DEFAULT.get(source) != null) return;
        mPreRenderSource = source;
        mPreRenderPlayer = PlayerPool.DEFAULT.acquire(source, Player.Factory.Default.get());
        mPreRenderPlayer.addPlayerListener(mPreRenderListener);
        mPreRenderPlayer.setStartWhenPrepared(false);
        L.i(this, "homePreRender", "event=prepare mediaId=" + source.getMediaId(), mPreRenderPlayer);
        try {
            // 底层调用 TTVideoEngine.prepare()，TextureRender 提供离屏输出；首页不播放。
            // 点击命中后，详情页再绑定显示 Surface。直接接 SDK 时需确保有可用的渲染输出。
            // Calls TTVideoEngine.prepare() with TextureRender's offscreen output, without playback.
            // The detail page attaches its display Surface on a hit. Direct SDK integration must
            // provide an available render output, through TextureRender or a suitable Surface.
            mPreRenderPlayer.prepare(source);
        } catch (IllegalStateException error) {
            L.w(this, "homePreRender", error, "event=prepareFailed");
            releasePreRender();
        }
    }

    void onDramaSelected(DramaInfo info) {
        DramaEntryEpisode entry = info.entryEpisode;
        if (mPreRenderPlayer != null && entry != null && entry.isUsable(System.currentTimeMillis())
                && TextUtils.equals(entry.getMediaId(), mPreRenderSource.getMediaId())
                && (mPreRenderPlayer.isPreparing() || mPreRenderPlayer.isPrepared())) {
            // 命中时移交给默认播放器池，详情页按相同 mediaId 复用并负责释放。
            // Hand the matching player to the default pool; the detail page reuses it by mediaId
            // and owns its release. Remove the home listener to avoid retaining the home page.
            L.i(this, "homePreRender", "event=handoff mediaId=" + entry.getMediaId(), mPreRenderPlayer);
            mPreRenderPlayer.removePlayerListener(mPreRenderListener);
            mPreRenderPlayer = null;
            mPreRenderSource = null;
        }
        stop();
    }

    private void releasePreRender() {
        if (mPreRenderPlayer == null) return;
        L.i(this, "homePreRender", "event=release", mPreRenderPlayer);
        mPreRenderPlayer.removePlayerListener(mPreRenderListener);
        PlayerPool.DEFAULT.recycle(mPreRenderPlayer);
        mPreRenderPlayer = null;
        mPreRenderSource = null;
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
        // 刷新、离开首页或点击其他剧目时释放未命中的预渲染实例。
        // Release an unused prepared player on refresh, leaving home, or tapping another drama.
        releasePreRender();
    }

    private void log(String event, int index, String mediaId, String detail) {
        L.i(this, "homePreload", "event=" + event + " index=" + index
                + " mediaId=" + mediaId + " " + detail);
    }
}
