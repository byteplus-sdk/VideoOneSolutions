// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.playback;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.ref.WeakReference;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 从 PlayerKit 播放事件流统计首帧耗时。
 * Tracks first-frame latency from PlayerKit's playback event stream.
 *
 * <p>时间戳统一来自 {@link Event#dispatchTime()}，使用 uptimeMillis，不能混用系统日期时间。
 * <p>All timestamps come from {@link Event#dispatchTime()}, which uses
 * {@code SystemClock.uptimeMillis()}. Do not mix these values with wall-clock timestamps.
 */
public final class FirstFrameMonitor implements Dispatcher.EventListener {
    public static final String TAG = "VOD_FIRST_FRAME";

    public static final int STATUS_SUCCESS = 1;
    public static final int STATUS_STOPPED = 2;
    public static final int STATUS_ERROR = 3;
    public static final int STATUS_RELEASED = 4;
    public static final int STATUS_REPLACED = 5;

    @IntDef({STATUS_SUCCESS, STATUS_STOPPED, STATUS_ERROR, STATUS_RELEASED, STATUS_REPLACED})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Status {
    }

    public interface Reporter {
        /**
         * 在 PlaybackController 的 Looper 上回调。
         * Called on the PlaybackController's looper.
         */
        void report(@NonNull Result result);
    }

    private static final AtomicLong SESSION_ID = new AtomicLong();
    private static final Reporter LOG_REPORTER = result -> L.i(TAG, "report", result.toString());

    private static volatile boolean sEnabled = true;
    private static volatile Reporter sReporter = LOG_REPORTER;

    private final WeakReference<PlaybackController> mControllerRef;
    private Session mSession;

    FirstFrameMonitor(@NonNull PlaybackController controller) {
        mControllerRef = new WeakReference<>(controller);
    }

    public static void setEnabled(boolean enabled) {
        sEnabled = enabled;
    }

    /**
     * 设置自定义上报器；传入 {@code null} 恢复结构化 logcat 日志。
     * Sets a custom reporter. Passing {@code null} restores structured logcat reporting.
     */
    public static void setReporter(@Nullable Reporter reporter) {
        sReporter = reporter == null ? LOG_REPORTER : reporter;
    }

    @Override
    public void onEvent(Event event) {
        if (!sEnabled) {
            mSession = null;
            return;
        }

        final long timeMs = event.dispatchTime();
        switch (event.code()) {
            case PlaybackEvent.Action.PREPARE_PLAYBACK:
                onPlaybackRequest(resolveMediaSource(), timeMs, false);
                break;
            case PlaybackEvent.Action.START_PLAYBACK:
                onPlaybackRequest(resolveMediaSource(), timeMs, true);
                break;
            case PlayerEvent.Action.PREPARE:
                if (mSession != null && mSession.prepareMs <= 0) {
                    mSession.prepareMs = timeMs;
                }
                break;
            case PlayerEvent.Info.VIDEO_RENDERING_START_BEFORE_START:
                // 预渲染就绪仅作命中标记，实际播放首帧事件才结束统计。
                // Pre-render readiness marks a hit; only the playback first-frame event completes success.
                if (mSession != null && mSession.preRenderReadyMs <= 0) {
                    mSession.preRenderReadyMs = timeMs;
                }
                break;
            case PlayerEvent.Info.VIDEO_RENDERING_START:
                finish(STATUS_SUCCESS, timeMs);
                break;
            case PlaybackEvent.Action.STOP_PLAYBACK:
                finish(STATUS_STOPPED, timeMs);
                break;
            case PlayerEvent.State.ERROR:
                finish(STATUS_ERROR, timeMs);
                break;
            case PlayerEvent.Action.RELEASE:
                finish(STATUS_RELEASED, timeMs);
                break;
        }
    }

    private void onPlaybackRequest(@Nullable MediaSource source, long timeMs, boolean start) {
        if (source == null) return;

        if (mSession != null && !mSession.mediaId.equals(source.getMediaId())) {
            finish(STATUS_REPLACED, timeMs);
        }
        if (mSession == null) {
            // 已出首帧媒体的暂停恢复不重复创建起播统计。
            // Resuming media that has already rendered does not create another startup session.
            if (isResumeOfRenderedMedia(source)) return;

            mSession = new Session(
                    SESSION_ID.incrementAndGet(),
                    source.getMediaId(),
                    source.getSourceType(),
                    timeMs);
        }
        if (start && mSession.startPlaybackMs <= 0) {
            mSession.startPlaybackMs = timeMs;
        }
    }

    private boolean isResumeOfRenderedMedia(MediaSource source) {
        final PlaybackController controller = mControllerRef.get();
        if (controller == null) return false;

        final Player player = controller.player();
        if (player == null || !MediaSource.mediaEquals(player.getDataSource(), source)) {
            return false;
        }
        final int state = player.getState();
        return state == Player.STATE_STARTED
                || state == Player.STATE_PAUSED
                || state == Player.STATE_COMPLETED;
    }

    @Nullable
    private MediaSource resolveMediaSource() {
        final PlaybackController controller = mControllerRef.get();
        if (controller == null) return null;

        final VideoView videoView = controller.videoView();
        if (videoView != null && videoView.getDataSource() != null) {
            return videoView.getDataSource();
        }
        final Player player = controller.player();
        return player == null ? null : player.getDataSource();
    }

    private void finish(@Status int status, long endTimeMs) {
        final Session session = mSession;
        if (session == null) return;

        // 先清空会话再回调，防止停止、释放等后续事件重复上报。
        // Clear the session before reporting so later stop or release events cannot report it twice.
        mSession = null;
        final Result result = Result.create(session, status, endTimeMs);
        final Reporter reporter = sReporter;
        if (reporter != null) {
            reporter.report(result);
        }
    }

    static Metrics calculateMetrics(
            long requestMs,
            long startPlaybackMs,
            long prepareMs,
            long preRenderReadyMs,
            long firstFrameMs) {
        return new Metrics(
                cost(firstFrameMs, requestMs),
                cost(firstFrameMs, startPlaybackMs),
                cost(firstFrameMs, prepareMs),
                cost(prepareMs, startPlaybackMs),
                preRenderReadyMs > 0);
    }

    private static long cost(long endMs, long startMs) {
        // 缺失或顺序无效的阶段返回 -1，避免被误读为零耗时。
        // Missing or out-of-order stages return -1 instead of appearing to cost zero.
        return endMs >= startMs && startMs > 0 ? endMs - startMs : -1;
    }

    private static final class Session {
        final long sessionId;
        final String mediaId;
        final int sourceType;
        final long requestMs;
        long startPlaybackMs;
        long prepareMs;
        long preRenderReadyMs;

        Session(long sessionId, String mediaId, int sourceType, long requestMs) {
            this.sessionId = sessionId;
            this.mediaId = mediaId;
            this.sourceType = sourceType;
            this.requestMs = requestMs;
        }
    }

    static final class Metrics {
        final long requestToFirstFrameMs;
        final long startToFirstFrameMs;
        final long prepareToFirstFrameMs;
        final long uiToPrepareMs;
        final boolean preRenderHit;

        Metrics(
                long requestToFirstFrameMs,
                long startToFirstFrameMs,
                long prepareToFirstFrameMs,
                long uiToPrepareMs,
                boolean preRenderHit) {
            this.requestToFirstFrameMs = requestToFirstFrameMs;
            this.startToFirstFrameMs = startToFirstFrameMs;
            this.prepareToFirstFrameMs = prepareToFirstFrameMs;
            this.uiToPrepareMs = uiToPrepareMs;
            this.preRenderHit = preRenderHit;
        }
    }

    /**
     * 每次起播的统计结果；非成功状态的首帧耗时为 -1。
     * Result for one startup session; first-frame durations are -1 when it does not succeed.
     */
    public static final class Result {
        public final long sessionId;
        @NonNull
        public final String mediaId;
        public final int sourceType;
        @Status
        public final int status;
        public final long requestToEndMs;
        public final long requestToFirstFrameMs;
        public final long startToFirstFrameMs;
        public final long prepareToFirstFrameMs;
        public final long uiToPrepareMs;
        public final boolean preRenderHit;

        private Result(
                long sessionId,
                @NonNull String mediaId,
                int sourceType,
                @Status int status,
                long requestToEndMs,
                Metrics metrics) {
            this.sessionId = sessionId;
            this.mediaId = mediaId;
            this.sourceType = sourceType;
            this.status = status;
            this.requestToEndMs = requestToEndMs;
            this.requestToFirstFrameMs = metrics.requestToFirstFrameMs;
            this.startToFirstFrameMs = metrics.startToFirstFrameMs;
            this.prepareToFirstFrameMs = metrics.prepareToFirstFrameMs;
            this.uiToPrepareMs = metrics.uiToPrepareMs;
            this.preRenderHit = metrics.preRenderHit;
        }

        private static Result create(Session session, @Status int status, long endTimeMs) {
            final long firstFrameMs = status == STATUS_SUCCESS ? endTimeMs : -1;
            return new Result(
                    session.sessionId,
                    session.mediaId,
                    session.sourceType,
                    status,
                    cost(endTimeMs, session.requestMs),
                    calculateMetrics(
                            session.requestMs,
                            session.startPlaybackMs,
                            session.prepareMs,
                            session.preRenderReadyMs,
                            firstFrameMs));
        }

        @Override
        public String toString() {
            return String.format(
                    Locale.US,
                    "session=%d media=%s source=%s status=%s request_end=%d request_ff=%d "
                            + "start_ff=%d prepare_ff=%d ui_prepare=%d pre_render_hit=%s",
                    sessionId,
                    mediaId,
                    MediaSource.mapSourceType(sourceType),
                    statusName(status),
                    requestToEndMs,
                    requestToFirstFrameMs,
                    startToFirstFrameMs,
                    prepareToFirstFrameMs,
                    uiToPrepareMs,
                    preRenderHit);
        }

        private static String statusName(@Status int status) {
            switch (status) {
                case STATUS_SUCCESS:
                    return "success";
                case STATUS_STOPPED:
                    return "stopped";
                case STATUS_ERROR:
                    return "error";
                case STATUS_RELEASED:
                    return "released";
                case STATUS_REPLACED:
                    return "replaced";
                default:
                    return "unknown";
            }
        }
    }
}
