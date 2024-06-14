// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.strategy;

import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;

import androidx.annotation.AnyThread;
import androidx.annotation.Nullable;
import androidx.annotation.WorkerThread;
import androidx.core.math.MathUtils;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.ve.VEPlayerInit;
import com.byteplus.playerkit.player.ve.VEPlayerStatic;
import com.byteplus.playerkit.utils.Asserts;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoStrategy;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.ShortVideoStrategy;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Using {@link ShortVideoStrategy}
 * and {@link  FeedVideoStrategy} is
 * recommended. If you want to write your own Preload Strategy, you can using this class.
 */
public class VideoPreload implements Dispatcher.EventListener {
    private static HandlerThread sHandlerThread;
    private final Handler mH;
    private final Config mConfig;
    private final List<MediaSource> mSources = new ArrayList<>();
    private boolean mPreloading;

    @AnyThread
    public void setItems(List<MediaSource> sources) {
        run(() -> {
            mSources.clear();
            mSources.addAll(sources);
        });
    }

    @AnyThread
    public void appendItems(List<MediaSource> sources) {
        run(() -> mSources.addAll(sources));
    }

    public enum Direction {
        UP, DOWN, IDLE
    }

    public static class Config {
        public int scene;
        public int preloadCount = 3;
        public long preloadSizeInBytes = 800 * 1024L;
        public long startBufferLimitInMS = 14 * 1000L;
        public long stopBufferLimitInMS = 5 * 1000L;
        public Depend depend;

        public Config(int scene) {
            this.scene = scene;
            final JSONObject preloadConfig = VEPlayerStatic.getPreloadConfig(scene);
            if (preloadConfig != null) {
                this.preloadCount = preloadConfig.optInt("count", 3);
                this.preloadSizeInBytes = preloadConfig.optInt("size", 800) * 1024L;
                this.startBufferLimitInMS = preloadConfig.optInt("start_buffer_limit", 14) * 1000L;
                this.stopBufferLimitInMS = preloadConfig.optInt("stop_buffer_limit", 5) * 1000L;
            }
        }

        public interface Depend {
            @WorkerThread
            Direction getScrollDirection();

            @WorkerThread
            @Nullable
            MediaSource getPlayingSource();
        }
    }

    public VideoPreload(Config config) {
        mConfig = config;

        if (sHandlerThread == null) {
            sHandlerThread = new HandlerThread("Preload");
            sHandlerThread.start();
        }

        mH = new Handler(sHandlerThread.getLooper());
    }

    @Override
    public void onEvent(Event event) {
        switch (event.code()) {
            case PlayerEvent.Action.PREPARE: {
                stop("PlayerPrepare");
                break;
            }
            case PlayerEvent.Info.VIDEO_RENDERING_START: {
                final Player player = event.owner(Player.class);
                if (player == null) return;

                final Track selected = player.getSelectedTrack(Track.TRACK_TYPE_VIDEO);
                final MediaSource source = player.getDataSource();
                if (source == null || selected == null) {
                    return;
                }
                //After first frame rendered, check disk cache
                run(() -> checkDiskCache(source, selected));
                break;
            }
            case PlayerEvent.Info.BUFFERING_UPDATE: {
                final Player player = event.owner(Player.class);
                if (player == null) return;

                final long bufferedDuration = player.getBufferedDuration();
                final long currentPosition = player.getCurrentPosition();
                final long duration = player.getDuration();
                //Check memory cache
                run(() -> checkMemoryCache(bufferedDuration, currentPosition, duration));
                break;
            }
            case PlayerEvent.Info.BUFFERING_START: {
                stop("PlayerBufferStart");
                break;
            }
        }
    }

    @AnyThread
    public void start(String reason) {
        run(() -> startPreload(reason));
    }

    @AnyThread
    public void stop(String reason) {
        mH.removeCallbacksAndMessages(null);

        run(() -> stopPreload(reason));
    }

    @WorkerThread
    private void checkDiskCache(MediaSource source, Track selected) {
        Asserts.checkThread(mH.getLooper());

        if (mPreloading) return;

        String cacheKey = VEPlayerInit.getCacheKeyFactory().generateCacheKey(source, selected);
        CacheLoader.CacheInfo cacheInfo = CacheLoader.Default.get().getCacheInfo(cacheKey);
        boolean cacheFinished = cacheInfo.sizeInBytes > 0 && cacheInfo.cachedSizeInBytes >= cacheInfo.sizeInBytes;
        if (cacheFinished) {
            startPreload("DiskCacheFinished");
        }
    }

    @WorkerThread
    private void checkMemoryCache(long bufferedDuration, long currentPosition, long duration) {
        Asserts.checkThread(mH.getLooper());

        final boolean cacheDangerous = bufferedDuration <= mConfig.stopBufferLimitInMS;
        if (mPreloading && cacheDangerous) {
            stopPreload("MemoryCacheDangerous");
            return;
        }

        if (mPreloading) return;
        final boolean cacheSafeEnough = bufferedDuration >= mConfig.startBufferLimitInMS;
        final boolean cacheEnd = currentPosition + bufferedDuration + 1000 >= duration;
        if (cacheSafeEnough) {
            startPreload("MemoryCacheSafeEnough");
        } else if (cacheEnd) {
            startPreload("MemoryCacheEnd");
        }
    }

    @WorkerThread
    private void stopPreload(String reason) {
        Asserts.checkThread(mH.getLooper());

        if (mPreloading) {
            mPreloading = false;
            L.v(this, "stopPreload", reason);

            mH.removeCallbacksAndMessages(null);
            CacheLoader.Default.get().stopAllTask();
        }
    }

    @WorkerThread
    private void startPreload(String reason) {
        Asserts.checkThread(mH.getLooper());

        final Config.Depend depend = mConfig.depend;
        if (depend == null) return;

        final int preloadCount = mConfig.preloadCount;
        if (preloadCount <= 0) return;

        final int count = mSources.size();
        if (count <= 0) return;

        final int playingIndex = resolvePlayingIndex();
        if (playingIndex < 0) return;

        if (mPreloading) return;
        mPreloading = true;

        final Direction direction = depend.getScrollDirection();

        int startIndex;
        int endIndex;
        if (direction == Direction.DOWN || direction == Direction.IDLE) {
            startIndex = playingIndex + 1;
            startIndex = MathUtils.clamp(startIndex, 0, count - 1);
            endIndex = startIndex + preloadCount - 1;
            endIndex = MathUtils.clamp(endIndex, startIndex, count - 1);
            L.v(this, "startPreload", reason, "current = " + playingIndex,
                    direction.name(), "preload range = [" + startIndex + "," + endIndex + "]");
            for (int i = startIndex; i <= endIndex; i++) {
                preload(createMediaSource(i), null);
            }
        } else if (direction == Direction.UP) {
            startIndex = playingIndex - 1;
            startIndex = MathUtils.clamp(startIndex, 0, count - 1);
            endIndex = startIndex - preloadCount + 1;
            endIndex = MathUtils.clamp(endIndex, 0, startIndex);
            L.v(this, "startPreload", reason, "current = " + playingIndex,
                    direction.name(), "preload range = [" + startIndex + "," + endIndex + "]");
            for (int i = startIndex; i >= endIndex; i--) {
                preload(createMediaSource(i), null);
            }
        }
    }

    @WorkerThread
    private int resolvePlayingIndex() {
        Asserts.checkThread(mH.getLooper());

        final Config.Depend depend = mConfig.depend;
        if (depend == null) return -1;

        final MediaSource playingSource = depend.getPlayingSource();
        if (playingSource == null) return -1;

        for (int i = mSources.size() - 1; i >= 0; i--) {
            if (MediaSource.mediaEquals(playingSource, mSources.get(i))) {
                return i;
            }
        }
        return -1;
    }

    @WorkerThread
    @Nullable
    private MediaSource createMediaSource(int index) {
        Asserts.checkThread(mH.getLooper());

        final MediaSource source = mSources.get(index);
        if (source != null) {
            source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_SIZE_IN_BYTES, mConfig.preloadSizeInBytes);
        }
        return source;
    }

    @WorkerThread
    private void preload(@Nullable MediaSource source, @Nullable CacheLoader.Task.Listener listener) {
        Asserts.checkThread(mH.getLooper());

        if (source == null) return;
        CacheLoader.Default.get().preload(source, listener);
    }

    @AnyThread
    private void run(Runnable runnable) {
        if (mH.getLooper() != Looper.myLooper()) {
            mH.post(runnable);
        } else {
            runnable.run();
        }
    }
}
