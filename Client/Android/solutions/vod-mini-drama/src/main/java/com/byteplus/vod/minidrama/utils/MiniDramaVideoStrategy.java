// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.utils;

import android.text.TextUtils;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.playback.PlayerPool;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.volcengine.VolcEngineStrategy;
import com.byteplus.playerkit.player.volcengine.VolcScene;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.model.ViewItem;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 详情和 Explore 各自持有一个实例：当前播放、下一集预渲染、再后五集预加载。
 * Each detail/Explore page owns its window: play current, prepare next, preload the following five.
 */
public final class MiniDramaVideoStrategy {
    public static final int PRELOAD_COUNT = 5;
    public static final long PRELOAD_BYTES = 500L * 1024L;
    private static final int NEXT_EPISODE_OFFSET = 1;
    private static final int PRELOAD_START_OFFSET = 2;

    private final Map<String, MediaSource> mPreloads = new LinkedHashMap<>();
    private boolean mEnabled;
    private Player mPreRenderPlayer;
    private VideoItem mPreRenderItem;
    private final Dispatcher.EventListener mPreRenderListener = event -> {
        if (event.owner(Player.class) != mPreRenderPlayer) return;
        if (event.code() == PlayerEvent.Info.VIDEO_RENDERING_START_BEFORE_START) {
            L.i(this, "detailWindow", "frameReady=" + mPreRenderItem.getVid());
        } else if (event.code() == PlayerEvent.State.PREPARED) {
            L.i(this, "detailWindow", "prepared=" + mPreRenderItem.getVid());
        } else if (event.code() == PlayerEvent.State.ERROR) {
            L.w(this, "detailWindow", "prerenderFailed");
            releasePreRender();
        }
    };

    public void resume() {
        mEnabled = true;
        // 该页面统一调度，避免 SDK 全列表自动策略再提交同一批剧集。
        // 其他场景仍由原有 VolcEngineStrategy 管理。
        // This page owns scheduling instead of also submitting the full list to the SDK.
        // Other scenes retain their existing VolcEngineStrategy lifecycle.
        VolcEngineStrategy.setEnabled(VolcScene.SCENE_SHORT_VIDEO, false);
    }

    public void beforePlay(VideoItem current) {
        if (current != null) removePreload(current.getVid());
    }

    public void update(List<ViewItem> pageItems, int position, Player currentPlayer) {
        if (!mEnabled) return;
        VideoItem current = position >= 0 && position < pageItems.size()
                ? VideoItemHelper.findVideoItem(pageItems.get(position)) : null;
        if (!playable(current)) {
            clearWindow();
            return;
        }
        // 在实际播放器被 PlaybackController 接管后才移交，页面退出不会遗留孤立实例。
        // Transfer ownership only after PlaybackController acquires the same player.
        if (currentPlayer != null && currentPlayer == mPreRenderPlayer) {
            L.i(this, "detailWindow", "handoff=" + current.getVid());
            mPreRenderPlayer.removePlayerListener(mPreRenderListener);
            mPreRenderPlayer = null;
            mPreRenderItem = null;
        }
        List<VideoItem> episodes = VideoItemHelper.findVideoItems(pageItems);
        int currentIndex = episodes.indexOf(current);
        if (currentIndex < 0) {
            clearWindow();
            return;
        }
        VideoItem next = at(episodes, currentIndex + NEXT_EPISODE_OFFSET);
        Map<String, VideoItem> desired = new LinkedHashMap<>();
        for (int offset = PRELOAD_START_OFFSET; offset < PRELOAD_START_OFFSET + PRELOAD_COUNT; offset++) {
            VideoItem item = at(episodes, currentIndex + offset);
            // 不把锁定集过滤后重新编号，也不为了凑五个而越过这个窗口。
            // Preserve episode positions; skip locked entries without extending the five-item window.
            if (playable(item) && !TextUtils.equals(item.getVid(), current.getVid())
                    && (next == null || !TextUtils.equals(item.getVid(), next.getVid()))) {
                desired.putIfAbsent(item.getVid(), item);
            }
        }
        for (String id : new ArrayList<>(mPreloads.keySet())) {
            if (!desired.containsKey(id) || VideoItem.get(mPreloads.get(id)) != desired.get(id)) {
                removePreload(id);
            }
        }
        // 先取消下一集的数据任务，再 prepare，两个集合始终互斥。
        // Cancel the next episode's data task before prepare to keep both sets disjoint.
        prepareNext(playable(next) && !TextUtils.equals(next.getVid(), current.getVid()) ? next : null);
        CacheLoader loader = CacheLoader.Default.get();
        if (loader != null) {
            for (VideoItem item : desired.values()) {
                if (mPreloads.containsKey(item.getVid())) continue;
                MediaSource source = VideoItem.toMediaSource(item);
                source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_SIZE_IN_BYTES, PRELOAD_BYTES);
                mPreloads.put(item.getVid(), source);
                L.i(this, "detailWindow", "preload=" + item.getVid() + " bytes=" + PRELOAD_BYTES);
                loader.preload(source, new CacheLoader.Task.Listener.Adapter() {
                    @Override
                    public void onError(CacheLoader.Task task, IOException error) {
                        if (mPreloads.get(item.getVid()) == source) {
                            L.w(MiniDramaVideoStrategy.this, "detailWindow", "preloadFailed=" + item.getVid());
                        }
                    }
                });
            }
        }
        L.i(this, "detailWindow", "current=" + current.getVid()
                + " next=" + (mPreRenderItem == null ? "none" : mPreRenderItem.getVid())
                + " preloads=" + mPreloads.keySet() + " bytes=" + PRELOAD_BYTES);
    }

    private void prepareNext(VideoItem next) {
        if (next == mPreRenderItem && mPreRenderPlayer != null
                && !mPreRenderPlayer.isReleased() && !mPreRenderPlayer.isError()) return;
        releasePreRender();
        if (next == null) return;
        MediaSource source = VideoItem.toMediaSource(next);
        // 不接管其他页面或小窗已经持有的播放器。
        // Do not take ownership of a player already held by another page or mini-player.
        if (PlayerPool.DEFAULT.get(source) != null) return;
        mPreRenderItem = next;
        mPreRenderPlayer = PlayerPool.DEFAULT.acquire(source, Player.Factory.Default.get());
        mPreRenderPlayer.addPlayerListener(mPreRenderListener);
        mPreRenderPlayer.setStartWhenPrepared(false);
        L.i(this, "detailWindow", "prepare=" + next.getVid());
        try {
            // 默认 TextureRender 提供离屏输出。prepare 的流量不受 500 KiB 限制。
            // Default TextureRender supports offscreen output; prepare is not limited to 500 KiB.
            mPreRenderPlayer.prepare(source);
        } catch (IllegalStateException error) {
            releasePreRender();
            L.w(this, "detailWindow", "prepareFailed");
        }
    }

    private static VideoItem at(List<VideoItem> items, int index) {
        return index >= 0 && index < items.size() ? items.get(index) : null;
    }

    private static boolean playable(VideoItem item) {
        return item != null && item.getSourceType() != VideoItem.SOURCE_TYPE_EMPTY
                && item.playable() && !DramaFeed.isLocked(item) && !TextUtils.isEmpty(item.getVid());
    }

    private void removePreload(String id) {
        MediaSource source = mPreloads.remove(id);
        CacheLoader loader = CacheLoader.Default.get();
        if (source != null && loader != null) {
            loader.stopTask(source);
            L.i(this, "detailWindow", "remove=" + id);
        }
    }

    private void releasePreRender() {
        Player player = mPreRenderPlayer;
        mPreRenderPlayer = null;
        mPreRenderItem = null;
        if (player != null) {
            player.removePlayerListener(mPreRenderListener);
            PlayerPool.DEFAULT.recycle(player);
        }
    }

    private void clearWindow() {
        for (String id : new ArrayList<>(mPreloads.keySet())) removePreload(id);
        releasePreRender();
    }

    public void pause() {
        mEnabled = false;
        clearWindow();
    }
}
