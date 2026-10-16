// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.minidrama.remote.model.drama.DramaEntryEpisode;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.io.IOException;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Maintains a bounded preload window for entry episodes shown on the drama theater page.
 */
final class DramaBrowsePreloadCoordinator {
    private static final int WIFI_CANDIDATE_LIMIT = 6;
    private static final int METERED_CANDIDATE_LIMIT = 3;
    private static final int MAX_CONCURRENT_TASK_COUNT = 1;
    private static final long PRELOAD_SIZE_IN_BYTES = 800L * 1024L;
    private static final long WIFI_SESSION_BUDGET_IN_BYTES =
            WIFI_CANDIDATE_LIMIT * PRELOAD_SIZE_IN_BYTES;
    private static final long METERED_SESSION_BUDGET_IN_BYTES =
            METERED_CANDIDATE_LIMIT * PRELOAD_SIZE_IN_BYTES;

    private final Context mContext;
    private final CacheLoader mCacheLoader;
    private final Handler mMainHandler = new Handler(Looper.getMainLooper());
    private final ArrayDeque<Entry> mQueue = new ArrayDeque<>();
    private final Set<String> mQueuedDramaIds = new HashSet<>();
    private final Map<String, Entry> mRunningEntries = new HashMap<>();
    private final Set<String> mFinishedMediaIds = new HashSet<>();

    private long mSessionReservedBytes;
    private boolean mReleased;

    DramaBrowsePreloadCoordinator(@NonNull Context context, CacheLoader cacheLoader) {
        mContext = context.getApplicationContext();
        mCacheLoader = cacheLoader;
    }

    void updateCandidates(@NonNull List<DramaInfo> candidates) {
        List<DramaInfo> snapshot = new ArrayList<>(candidates);
        runOnMain(() -> updateCandidatesOnMain(snapshot));
    }

    void prepareForPlayback(@NonNull String selectedDramaId) {
        runOnMain(() -> {
            mQueue.clear();
            mQueuedDramaIds.clear();

            for (Entry entry : new ArrayList<>(mRunningEntries.values())) {
                if (TextUtils.equals(selectedDramaId, entry.dramaId)) {
                    entry.handedOff = true;
                } else {
                    stopEntry(entry);
                }
            }
        });
    }

    void pause() {
        runOnMain(this::cancelUnhandedTasks);
    }

    void resume() {
        runOnMain(() -> {
            for (Entry entry : mRunningEntries.values()) {
                entry.handedOff = false;
            }
        });
    }

    void release() {
        runOnMain(() -> {
            if (mReleased) return;
            mReleased = true;
            mQueue.clear();
            mQueuedDramaIds.clear();

            for (Entry entry : new ArrayList<>(mRunningEntries.values())) {
                if (!entry.handedOff) {
                    stopEntry(entry);
                }
            }
            mRunningEntries.clear();
        });
    }

    private void updateCandidatesOnMain(List<DramaInfo> candidates) {
        if (mReleased || mCacheLoader == null) return;

        Policy policy = resolvePolicy();
        if (policy.candidateLimit == 0) {
            cancelUnhandedTasks();
            return;
        }

        LinkedHashMap<String, DramaInfo> desired = new LinkedHashMap<>();
        Set<String> desiredMediaIds = new HashSet<>();
        final long nowMs = System.currentTimeMillis();
        for (DramaInfo info : candidates) {
            if (desired.size() >= policy.candidateLimit) break;
            if (info == null || TextUtils.isEmpty(info.dramaId)) continue;

            DramaEntryEpisode entryEpisode = info.entryEpisode;
            if (entryEpisode == null || !entryEpisode.isUsable(nowMs)) continue;
            String mediaId = entryEpisode.getMediaId();
            if (TextUtils.isEmpty(mediaId) || !desiredMediaIds.add(mediaId)) continue;
            desired.putIfAbsent(info.dramaId, info);
        }

        removeUndesiredQueuedTasks(desired.keySet());
        for (Entry entry : new ArrayList<>(mRunningEntries.values())) {
            if (!desired.containsKey(entry.dramaId) && !entry.handedOff) {
                stopEntry(entry);
            }
        }

        for (DramaInfo info : desired.values()) {
            enqueueIfNeeded(info);
        }
        drainQueue(policy);
    }

    private void enqueueIfNeeded(DramaInfo info) {
        DramaEntryEpisode episode = info.entryEpisode;
        String mediaId = episode == null ? null : episode.getMediaId();
        if (TextUtils.isEmpty(mediaId)
                || mFinishedMediaIds.contains(mediaId)
                || mQueuedDramaIds.contains(info.dramaId)
                || mRunningEntries.containsKey(info.dramaId)) {
            return;
        }

        mQueue.addLast(new Entry(info.dramaId, info, mediaId));
        mQueuedDramaIds.add(info.dramaId);
    }

    private void drainQueue(Policy policy) {
        while (!mReleased
                && mRunningEntries.size() < MAX_CONCURRENT_TASK_COUNT
                && !mQueue.isEmpty()
                && mSessionReservedBytes + PRELOAD_SIZE_IN_BYTES <= policy.sessionBudgetBytes) {
            Entry entry = mQueue.removeFirst();
            mQueuedDramaIds.remove(entry.dramaId);
            startEntry(entry);
        }
    }

    private void startEntry(Entry entry) {
        DramaEntryEpisode episode = entry.info.entryEpisode;
        if (episode == null || episode.feed == null) return;
        if (TextUtils.isEmpty(episode.feed.dramaId)) {
            episode.feed.dramaId = entry.dramaId;
        }

        VideoItem videoItem = episode.feed.toVideoItem();
        VideoItem.playScene(videoItem, PlayScene.SCENE_SHORT);
        MediaSource source = VideoItem.toMediaSource(videoItem);
        source.putExtra(
                CacheLoader.Task.EXTRA_PRELOAD_SIZE_IN_BYTES,
                PRELOAD_SIZE_IN_BYTES);
        if (DramaSettings.isTheaterResumePointPreloadEnabled()) {
            source.putExtra(
                    CacheLoader.Task.EXTRA_PRELOAD_START_TIMESTAMP_MS,
                    Math.max(0L, episode.resumePositionMs));
        }

        mSessionReservedBytes += PRELOAD_SIZE_IN_BYTES;
        mRunningEntries.put(entry.dramaId, entry);
        L.d(this, "startEntry", entry.dramaId, entry.mediaId, episode.resumePositionMs);

        mCacheLoader.preload(source, new CacheLoader.Task.Listener.Adapter() {
            @Override
            public void onFinished(CacheLoader.Task task) {
                finishEntry(entry, true, null);
            }

            @Override
            public void onStopped(CacheLoader.Task task) {
                finishEntry(entry, false, null);
            }

            @Override
            public void onError(CacheLoader.Task task, IOException error) {
                finishEntry(entry, false, error);
            }
        });
    }

    private void finishEntry(Entry entry, boolean finished, IOException error) {
        runOnMain(() -> {
            Entry current = mRunningEntries.get(entry.dramaId);
            if (current != entry) return;

            mRunningEntries.remove(entry.dramaId);
            if (finished) {
                mFinishedMediaIds.add(entry.mediaId);
            }
            if (error == null) {
                L.d(this, "finishEntry", entry.dramaId, entry.mediaId, finished);
            } else {
                L.w(this, "finishEntry", error, entry.dramaId, entry.mediaId);
            }
            drainQueue(resolvePolicy());
        });
    }

    private void stopEntry(Entry entry) {
        if (entry.stopping || mCacheLoader == null) return;
        entry.stopping = true;
        mCacheLoader.stopTask(entry.mediaId);
    }

    private void removeUndesiredQueuedTasks(Set<String> desiredDramaIds) {
        mQueue.removeIf(entry -> {
            boolean remove = !desiredDramaIds.contains(entry.dramaId);
            if (remove) {
                mQueuedDramaIds.remove(entry.dramaId);
            }
            return remove;
        });
    }

    private void cancelUnhandedTasks() {
        mQueue.clear();
        mQueuedDramaIds.clear();
        for (Entry entry : new ArrayList<>(mRunningEntries.values())) {
            if (!entry.handedOff) {
                stopEntry(entry);
            }
        }
    }

    private Policy resolvePolicy() {
        ConnectivityManager manager =
                (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (manager == null) {
            return Policy.DISABLED;
        }

        try {
            Network network = manager.getActiveNetwork();
            NetworkCapabilities capabilities = manager.getNetworkCapabilities(network);
            if (capabilities == null
                    || !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)) {
                return Policy.DISABLED;
            }
            if (capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)) {
                return Policy.WIFI;
            }
            return Policy.METERED;
        } catch (SecurityException e) {
            L.w(this, "resolvePolicy", e, "ACCESS_NETWORK_STATE unavailable");
            return Policy.METERED;
        }
    }

    private void runOnMain(Runnable action) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            action.run();
        } else {
            mMainHandler.post(action);
        }
    }

    private static final class Entry {
        final String dramaId;
        final DramaInfo info;
        final String mediaId;
        boolean handedOff;
        boolean stopping;

        Entry(String dramaId, DramaInfo info, String mediaId) {
            this.dramaId = dramaId;
            this.info = info;
            this.mediaId = mediaId;
        }
    }

    private static final class Policy {
        static final Policy WIFI =
                new Policy(WIFI_CANDIDATE_LIMIT, WIFI_SESSION_BUDGET_IN_BYTES);
        static final Policy METERED =
                new Policy(METERED_CANDIDATE_LIMIT, METERED_SESSION_BUDGET_IN_BYTES);
        static final Policy DISABLED = new Policy(0, 0);

        final int candidateLimit;
        final long sessionBudgetBytes;

        Policy(int candidateLimit, long sessionBudgetBytes) {
            this.candidateLimit = candidateLimit;
            this.sessionBudgetBytes = sessionBudgetBytes;
        }
    }
}
