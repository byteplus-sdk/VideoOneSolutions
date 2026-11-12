// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.utils;

import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.utils.ProgressRecorder;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;

/**
 * 播放进程内最多一次首页预热；正常播放优先，不持有可复用的剧集播放器。
 * At most one Home warmup per playback process; real playback takes priority, with no pooled player.
 */
public final class DramaStartupWarmup {
    public static final long TIMEOUT_MS = 5_000L;
    private static final String PROGRESS_KEY = "drama-startup-warmup";
    private static final DramaStartupWarmup INSTANCE = new DramaStartupWarmup();
    private final Handler handler = new Handler(Looper.getMainLooper());
    private boolean consumed;
    private Attempt active;

    private final class Attempt {
        final Object owner;
        final Runnable onFinished;
        final long startedMs = SystemClock.elapsedRealtime();
        Player player;
        final Runnable timeout = () -> finish(this, "timeout");
        final Dispatcher.EventListener listener = event -> {
            if (active != this || event.owner(Player.class) != player) return;
            if (event.code() == PlayerEvent.Info.VIDEO_RENDERING_START_BEFORE_START) {
                // 退出播放器事件栈后释放，避免在 SDK 回调中重入 release。
                // Release after leaving the SDK event stack to avoid reentrant release.
                handler.postAtTime(() -> finish(this, "frameReady"), this, SystemClock.uptimeMillis());
            } else if (event.code() == PlayerEvent.State.ERROR) {
                handler.postAtTime(() -> finish(this, "error"), this, SystemClock.uptimeMillis());
            }
        };

        Attempt(Object owner, Runnable onFinished) {
            this.owner = owner;
            this.onFinished = onFinished;
        }
    }

    DramaStartupWarmup() {}

    public static DramaStartupWarmup get() { return INSTANCE; }

    public boolean isAvailable() {
        requireMainThread();
        return !consumed && DramaSettings.isTheaterStartupWarmupEnabled();
    }

    public boolean isActive(Object owner) {
        requireMainThread();
        return active != null && active.owner == owner;
    }

    /** source 必须是新建的私有媒体源，不能传入实际播放/缓存任务共用的对象。
     * source must be a fresh private source, never one shared with playback or cache tasks.
     */
    public boolean tryStart(Object owner, MediaSource source, Runnable onFinished) {
        requireMainThread();
        Player.Factory factory = Player.Factory.Default.get();
        if (!isAvailable() || factory == null || source == null) return false;
        // 创建前消耗机会；失败、取消、回首页和 Activity 重建均不重试。
        // Consume before creation; failure, cancellation, return and recreation never retry.
        consumed = true;
        Attempt attempt = new Attempt(owner, onFinished);
        active = attempt;
        source.setSyncProgressId(PROGRESS_KEY);
        handler.postAtTime(attempt.timeout, attempt, SystemClock.uptimeMillis() + TIMEOUT_MS);
        L.i(this, "startupWarmup", "start=home");
        try {
            attempt.player = factory.create(source);
            attempt.player.addPlayerListener(attempt.listener);
            attempt.player.setStartWhenPrepared(false);
            attempt.player.setStartTime(0L);
            attempt.player.setMuted(true);
            attempt.player.prepare(source);
        } catch (RuntimeException | LinkageError error) {
            finish(attempt, "prepareFailed");
        }
        return true;
    }

    public void cancel(Object owner, String reason) {
        requireMainThread();
        if (isActive(owner)) finish(active, reason);
    }

    /** 在初始 Explore 路由或真实播放前调用；只关闭额外首页预热，不影响下一集策略。
     * Call on initial Explore routing or before real playback; next-episode preparation is independent.
     */
    public void useNormalPlayback(String reason) {
        requireMainThread();
        if (!consumed) L.i(this, "startupWarmup", "normalPlayback=" + reason);
        consumed = true;
        if (active != null) finish(active, reason);
    }

    private void finish(Attempt attempt, String reason) {
        if (active != attempt) return;
        active = null;
        handler.removeCallbacksAndMessages(attempt);
        Player player = attempt.player;
        attempt.player = null;
        try {
            if (player != null) {
                player.removePlayerListener(attempt.listener);
                player.release();
            }
        } finally {
            // AVPlayer.release 会记录 prepared 进度；隔离并删除临时 key，保护真实续播。
            // AVPlayer.release records prepared progress; isolate and remove it to protect real resume.
            ProgressRecorder.removeProgress(PROGRESS_KEY);
            L.i(this, "startupWarmup", "finish=" + reason
                    + " elapsedMs=" + (SystemClock.elapsedRealtime() - attempt.startedMs));
            attempt.onFinished.run();
        }
    }

    private static void requireMainThread() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            throw new IllegalStateException("Startup warmup must run on the main thread");
        }
    }
}
