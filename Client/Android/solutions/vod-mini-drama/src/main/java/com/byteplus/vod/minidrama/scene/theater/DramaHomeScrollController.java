// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.graphics.Rect;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import com.byteplus.vod.minidrama.scene.settings.HomePreloadConfig;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Consumer;
import java.util.function.Supplier;

/** 主线程管理根列表、横向列表和 ViewPager2 的共同准入条件。
 * Main-thread admission across the root list, nested lists and ViewPager2.
 */
final class DramaHomeScrollController {
    private final RecyclerView root;
    private final Supplier<List<DramaInfo>> visibleItems;
    private final Consumer<List<DramaInfo>> updateWindow;
    private final Runnable onMotion;
    private final Map<RecyclerView, Observer> observers = new HashMap<>();
    private final Handler handler = new Handler(Looper.getMainLooper());
    private Set<String> visibleDuringUpdate;
    private Set<String> forwardDuringUpdate;
    private ViewTreeObserver layoutObserver;
    private boolean active;
    private boolean released;
    private boolean scheduled;
    private long scheduledAtMs;
    private boolean awaitingFirstWindow = true;
    private long lastUpdateMs;
    private final Runnable update = this::update;
    private final ViewTreeObserver.OnGlobalLayoutListener onLayout = this::schedule;
    private final View.OnAttachStateChangeListener onAttach = new View.OnAttachStateChangeListener() {
        @Override public void onViewAttachedToWindow(View view) {
            if (active && !released) {
                observeLayout();
                schedule();
            }
        }
        @Override public void onViewDetachedFromWindow(View view) {
            stopObserving();
            updateWindow.accept(new ArrayList<>());
        }
    };

    DramaHomeScrollController(RecyclerView root, Supplier<List<DramaInfo>> visibleItems,
                              Consumer<List<DramaInfo>> updateWindow) {
        this(root, visibleItems, updateWindow, () -> {});
    }

    DramaHomeScrollController(RecyclerView root, Supplier<List<DramaInfo>> visibleItems,
                              Consumer<List<DramaInfo>> updateWindow, Runnable onMotion) {
        requireMainThread();
        this.root = root;
        this.visibleItems = visibleItems;
        this.updateWindow = updateWindow;
        this.onMotion = onMotion;
    }

    void setActive(boolean value) {
        requireMainThread();
        if (released || active == value) return;
        active = value;
        if (value) {
            root.addOnAttachStateChangeListener(onAttach);
            observeLayout();
            schedule();
        } else {
            root.removeOnAttachStateChangeListener(onAttach);
            stopObserving();
            updateWindow.accept(new ArrayList<>());
        }
    }

    void reset() {
        requireMainThread();
        if (released) return;
        cancelUpdate();
        awaitingFirstWindow = true;
        schedule();
    }

    void schedule() {
        requireMainThread();
        if (!isRunning() || !DramaSettings.isTheaterEntryPreloadEnabled()) return;
        // 滚动事件只合并调度，View 树遍历留到节流后的窗口更新。
        // Scroll events only coalesce work; traverse the view tree after throttling.
        long now = SystemClock.uptimeMillis();
        // 首次真实可见窗口不受节流影响；空列表/刷新布局不会消耗这次机会。
        // The first real visible window bypasses throttling, including after empty/loading layouts.
        scheduleAt(awaitingFirstWindow ? now : Math.max(now,
                lastUpdateMs + DramaSettings.getHomePreloadConfig().updateIntervalMs));
    }

    private void scheduleAt(long whenMs) {
        // 最多一个主线程任务：保留较早时间，停止滚动可提前执行。
        // Keep one main-loop task at the earlier time; stopping can advance the check.
        if (scheduled && scheduledAtMs <= whenMs) return;
        cancelUpdate();
        scheduled = true;
        scheduledAtMs = whenMs;
        handler.postAtTime(update, whenMs);
    }

    private void cancelUpdate() {
        handler.removeCallbacks(update);
        scheduled = false;
    }

    private void update() {
        scheduled = false;
        if (!isRunning() || !DramaSettings.isTheaterEntryPreloadEnabled()) return;
        syncObservers();
        long now = SystemClock.uptimeMillis();
        List<DramaInfo> visible = visibleItems.get();
        Set<String> ids = new HashSet<>();
        for (DramaInfo info : visible) {
            if (info != null && info.dramaId != null) {
                ids.add(info.dramaId);
            }
        }
        if (!ids.isEmpty()) {
            awaitingFirstWindow = false;
            lastUpdateMs = now;
        }
        // 同一主线程调用内复用刚采集的窗口，避免每个候选重复遍历 View 树。
        // Reuse this fresh window only within the synchronous main-thread update.
        visibleDuringUpdate = ids;
        forwardDuringUpdate = forwardIds(visible);
        try {
            updateWindow.accept(visible);
        } finally {
            visibleDuringUpdate = null;
            forwardDuringUpdate = null;
        }
        // 不自行启动下一轮；滚动、布局或业务回调有变化时再调度。
        // No periodic retry: only scroll, layout or business events schedule another check.
    }

    boolean canStart(String dramaId) {
        requireMainThread();
        if (dramaId == null || !isRunning()
                || !DramaSettings.isTheaterEntryPreloadEnabled()) return false;
        HomePreloadConfig config = DramaSettings.getHomePreloadConfig();
        long now = SystemClock.uptimeMillis();
        // 迟到回包也检查实时可见性和速度，不使用上次更新时的准入结论。
        // Late responses recheck live visibility and motion rather than cached admission.
        if (visibleDuringUpdate == null) syncObservers();
        for (Map.Entry<RecyclerView, Observer> entry : observers.entrySet()) {
            entry.getValue().sample.stateChanged(entry.getKey().getScrollState());
            if (!entry.getValue().sample.allowsStart(config, now)) return false;
        }
        if (visibleDuringUpdate != null) {
            return visibleDuringUpdate.contains(dramaId) || forwardDuringUpdate.contains(dramaId);
        }
        List<DramaInfo> current = visibleItems.get();
        for (DramaInfo info : current) {
            if (info != null && dramaId.equals(info.dramaId)) return true;
        }
        return forwardIds(current).contains(dramaId);
    }

    private static Set<String> forwardIds(List<DramaInfo> items) {
        Set<String> ids = new HashSet<>();
        if (items instanceof HomePreloadWindow window) {
            for (DramaInfo info : window.forward) {
                if (info != null && info.dramaId != null) ids.add(info.dramaId);
            }
        }
        return ids;
    }

    int direction(RecyclerView recycler) {
        Observer observer = observers.get(recycler);
        return observer == null ? 1 : observer.sample.direction();
    }

    private boolean isRunning() {
        return active && !released && root.isAttachedToWindow();
    }

    boolean canWarmup(String dramaId) {
        // 预渲染比数据预加载更重，只为可见卡片在全部列表静止时开始/继续。
        // Prerender is heavier than data preload; require a visible card and all lists idle.
        if (!canStart(dramaId)) return false;
        boolean visible = visibleDuringUpdate != null && visibleDuringUpdate.contains(dramaId);
        if (visibleDuringUpdate == null) {
            for (DramaInfo info : visibleItems.get()) {
                if (info != null && dramaId.equals(info.dramaId)) {
                    visible = true;
                    break;
                }
            }
        }
        if (!visible) return false;
        for (RecyclerView recycler : observers.keySet()) {
            if (recycler.getScrollState() != RecyclerView.SCROLL_STATE_IDLE) return false;
        }
        return true;
    }

    private void observeLayout() {
        if (!isRunning() || layoutObserver != null) return;
        layoutObserver = root.getViewTreeObserver();
        layoutObserver.addOnGlobalLayoutListener(onLayout);
    }

    private void stopObserving() {
        cancelUpdate();
        awaitingFirstWindow = true;
        for (Map.Entry<RecyclerView, Observer> entry : observers.entrySet()) {
            entry.getKey().removeOnScrollListener(entry.getValue());
        }
        observers.clear();
        if (layoutObserver != null) {
            if (layoutObserver.isAlive()) layoutObserver.removeOnGlobalLayoutListener(onLayout);
            layoutObserver = null;
        }
    }

    private void syncObservers() {
        Set<RecyclerView> attached = new HashSet<>();
        collectRecyclers(root, attached);
        for (RecyclerView recycler : new ArrayList<>(observers.keySet())) {
            if (!attached.contains(recycler)) {
                recycler.removeOnScrollListener(observers.remove(recycler));
            }
        }
        for (RecyclerView recycler : attached) {
            if (!observers.containsKey(recycler)) {
                Observer observer = new Observer();
                observer.sample.stateChanged(recycler.getScrollState());
                observers.put(recycler, observer);
                recycler.addOnScrollListener(observer);
            }
        }
    }

    private static void collectRecyclers(View view, Set<RecyclerView> out) {
        if (!view.isShown() || view.getAlpha() <= 0 || !view.getGlobalVisibleRect(new Rect())) return;
        if (view instanceof RecyclerView recycler) out.add(recycler);
        if (view instanceof ViewGroup group) {
            for (int i = 0; i < group.getChildCount(); i++) collectRecyclers(group.getChildAt(i), out);
        }
    }

    private final class Observer extends RecyclerView.OnScrollListener {
        final HomeScrollSample sample = new HomeScrollSample();
        @Override public void onScrollStateChanged(@NonNull RecyclerView view, int state) {
            sample.stateChanged(state);
            if (state == RecyclerView.SCROLL_STATE_IDLE) {
                // 停下后可能马上点击，取消剩余节流等待；遍历仍放在下一次主线程调度。
                // Recheck on the next main-loop turn without the remaining throttle delay.
                if (isRunning() && DramaSettings.isTheaterEntryPreloadEnabled()) {
                    scheduleAt(SystemClock.uptimeMillis());
                }
            } else {
                onMotion.run();
                schedule();
            }
        }
        @Override public void onScrolled(@NonNull RecyclerView view, int dx, int dy) {
            sample.stateChanged(view.getScrollState());
            sample.scrolled(dx, dy, view.getResources().getDisplayMetrics().density,
                    SystemClock.uptimeMillis());
            if (dx != 0 || dy != 0) onMotion.run();
            schedule();
        }
    }

    void release() {
        requireMainThread();
        if (released) return;
        // 终态先置位，迟到的布局/配置回调不能重新启动已销毁页面。
        // Mark terminal state first so late layout/config callbacks cannot revive a destroyed page.
        released = true;
        active = false;
        root.removeOnAttachStateChangeListener(onAttach);
        stopObserving();
        updateWindow.accept(new ArrayList<>());
    }

    private static void requireMainThread() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            throw new IllegalStateException("Home scroll state must be accessed on the main thread");
        }
    }
}
