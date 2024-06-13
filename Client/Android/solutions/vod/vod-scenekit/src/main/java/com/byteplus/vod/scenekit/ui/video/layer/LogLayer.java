// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.event.InfoCacheUpdate;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Quality;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.utils.Asserts;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.byteplus.vod.scenekit.utils.TimeUtils;

import java.util.ArrayList;
import java.util.List;

public class LogLayer extends BaseLayer {

    private LogInfo mLogInfo;

    private static class LogInfo {
        private final List<Long> cacheHintBytes = new ArrayList<>();
        private long startPlaybackFT;
        private long prepareFT;
        private long videoRenderStartFT;

        private static String cacheHint(LogInfo logInfo) {
            if (logInfo == null) return "";
            String s = "";
            for (Long bytes : logInfo.cacheHintBytes) {
                if (!TextUtils.isEmpty(s)) {
                    s += ", ";
                }
                s = s + bytes;
            }
            return s;
        }

        public static long firstFrame(LogInfo logInfo, boolean player) {
            if (logInfo == null) return -1;
            if (player) {
                if (logInfo.videoRenderStartFT > logInfo.prepareFT) {
                    return logInfo.videoRenderStartFT - logInfo.prepareFT;
                }
            } else {
                if (logInfo.videoRenderStartFT > logInfo.startPlaybackFT) {
                    return logInfo.videoRenderStartFT - logInfo.startPlaybackFT;
                }
            }
            return -1;
        }
    }

    public LogLayer() {
        setIgnoreLock(true);
    }

    @Override
    public String tag() {
        return "log";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        TextView textView = new TextView(parent.getContext());
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        lp.gravity = Gravity.CENTER;
        textView.setLayoutParams(lp);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        textView.setPadding(20, 20, 20, 20);
        textView.setTextColor(Color.RED);
        return textView;
    }

    @Override
    public void requestDismiss(@NonNull String reason) {
        if (!TextUtils.equals(reason, Layers.VisibilityRequestReason.REQUEST_DISMISS_REASON_DIALOG_SHOW)) {
            super.requestDismiss(reason);
        }
    }

    @Override
    public void requestHide(@NonNull String reason) {
        if (!TextUtils.equals(reason, Layers.VisibilityRequestReason.REQUEST_DISMISS_REASON_DIALOG_SHOW)) {
            super.requestHide(reason);
        }
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
        showOpt();
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
        showOpt();
    }

    @Override
    public void onVideoViewBindDataSource(MediaSource dataSource) {
        showOpt();
    }

    @Override
    public void onSurfaceAvailable(Surface surface, int width, int height) {
        showOpt();
    }

    @Override
    public void onSurfaceDestroy(Surface surface) {
        showOpt();
    }

    @Override
    public void show() {
        super.show();
        final StringBuilder info = new StringBuilder();
        info.append(mediaSourceState()).append("\n");
        info.append(trackState()).append("\n");
        info.append(videoViewState()).append("\n");
        info.append(playbackState()).append("\n");
        Player player = player();
        if (player != null && !player.isReleased()) {
            info.append("Time: ")
                    .append(player.getSpeed())
                    .append("X ")
                    .append(TimeUtils.time2String(player.getDuration()))
                    .append(" - ")
                    .append(TimeUtils.time2String(player.getCurrentPosition()))
                    .append(player.isLooping() ? " loop" : "")
                    .append("\n");
            Track track = player.getCurrentTrack(Track.TRACK_TYPE_VIDEO);
            Quality quality = track != null ? track.getQuality() : null;
            info.append("Quality: ")
                    .append(quality == null ? null : quality.getQualityDesc())
                    .append("(")
                    .append(player.getVideoWidth())
                    .append("x")
                    .append(player.getVideoHeight())
                    .append(")")
                    .append(player.isSuperResolutionEnabled() ? "SR" : "")
                    .append("\n");
            info.append("Volume: ")
                    .append(mapVolume(player.getVolume()))
                    .append("\n");
            info.append("CacheHint: ")
                    .append(LogInfo.cacheHint(mLogInfo))
                    .append("\n");
            info.append("FirstFramePlayer: ")
                    .append(LogInfo.firstFrame(mLogInfo, true))
                    .append("\n");
            info.append("FirstFramePlayer+UI: ")
                    .append(LogInfo.firstFrame(mLogInfo, false))
                    .append("\n");
        }
        final TextView textView = Asserts.checkNotNull(getView());
        if (!TextUtils.equals(info, textView.getText())) {
            textView.setText(info);
        }
    }

    private String mediaSourceState() {
        MediaSource mediaSource = dataSource();
        if (mediaSource != null) {
            return mediaSource.dump();
        }
        return "unbind mediaSource";
    }

    private String trackState() {
        Player player = player();
        if (player != null && !player.isReleased()) {
            Track track = player.getCurrentTrack(Track.TRACK_TYPE_VIDEO);
            if (track != null) {
                return Track.dump(track);
            }
        }
        return "unknown track";
    }

    private String playbackState() {
        final PlaybackController controller = controller();
        if (controller == null) {
            return "playback unbind controller";
        } else {
            final Player player = controller.player();
            if (player == null) {
                return "playback unbind player";
            }
            return player.dump();
        }
    }

    private String mapVolume(float[] volume) {
        if (volume.length == 2) {
            return volume[0] + " " + volume[1];
        }
        return "";
    }


    private String videoViewState() {
        VideoView videoView = videoView();
        if (videoView == null) return "unbind videoView";
        return videoView.dump();
    }

    @Override
    protected void onBindVideoView(@NonNull VideoView videoView) {
        showOpt();
    }

    @Override
    protected void onUnBindVideoView(@NonNull VideoView videoView) {
        showOpt();
    }

    @Override
    public void onVideoViewDisplayViewChanged(View oldView, View newView) {
        showOpt();
    }

    @Override
    public void onVideoViewDisplayModeChanged(int fromMode, int toMode) {
        showOpt();
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlaybackEvent.Action.START_PLAYBACK:
                    if (mLogInfo == null) {
                        mLogInfo = new LogInfo();
                        mLogInfo.startPlaybackFT = event.dispatchTime();
                    }
                    break;
                case PlaybackEvent.Action.STOP_PLAYBACK:
                case PlayerEvent.Action.RELEASE:
                    if (mLogInfo != null) {
                        mLogInfo = null;
                    }
                    break;
                case PlayerEvent.Action.PREPARE:
                    if (mLogInfo != null && mLogInfo.prepareFT <= 0) {
                        mLogInfo.prepareFT = event.dispatchTime();
                    }
                    break;
                case PlayerEvent.Info.VIDEO_RENDERING_START:
                    if (mLogInfo != null && mLogInfo.videoRenderStartFT <= 0) {
                        mLogInfo.videoRenderStartFT = event.dispatchTime();
                    }
                    break;
                case PlayerEvent.Info.CACHE_UPDATE:
                    if (mLogInfo != null) {
                        mLogInfo.cacheHintBytes.add(event.cast(InfoCacheUpdate.class).cachedBytes);
                    }
                    break;
            }
            showOpt();
        }
    };


    private void showOpt() {
        mH.removeCallbacks(runnable);
        mH.postDelayed(runnable, 100);
    }

    private final Handler mH = new Handler(Looper.getMainLooper());

    private final Runnable runnable = new Runnable() {
        @Override
        public void run() {
            show();
        }
    };
}
