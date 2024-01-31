// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.content.res.Configuration;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.event.InfoBufferingUpdate;
import com.bytedance.playerkit.player.event.InfoProgressUpdate;
import com.bytedance.playerkit.player.event.InfoTrackChanged;
import com.bytedance.playerkit.player.event.InfoTrackWillChange;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.player.source.Quality;
import com.bytedance.playerkit.player.source.Subtitle;
import com.bytedance.playerkit.player.source.Track;
import com.bytedance.playerkit.utils.L;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.ui.base.OuterActions;
import com.bytedance.vod.scenekit.ui.base.VideoViewExtras;
import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.QualitySelectDialogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.SpeedSelectDialogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.SubtitleSelectDialogLayer;
import com.bytedance.vod.scenekit.ui.widgets.MediaSeekBar;
import com.bytedance.vod.scenekit.utils.TimeUtils;
import com.bytedance.vod.scenekit.utils.UIUtils;
import com.bytedance.vod.settingskit.CenteredToast;

import java.util.List;

public class TimeProgressBarLayer extends AnimateLayer {

    public enum CompletedPolicy {
        /**
         * Dismiss ProgressBar after play completed
         */
        DISMISS,
        /**
         * Keep show ProgressBar after play completed
         */
        KEEP
    }

    private MediaSeekBar mSeekBar;

    @NonNull
    private final CompletedPolicy mCompletedPolicy;

    @Override
    public String tag() {
        return "time_progressbar";
    }

    public TimeProgressBarLayer() {
        this(CompletedPolicy.DISMISS);
    }

    public TimeProgressBarLayer(@NonNull CompletedPolicy policy) {
        setIgnoreLock(true);
        mCompletedPolicy = policy;
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_time_progress_bar_layer, parent, false);

        mSeekBar = view.findViewById(R.id.mediaSeekBar);
        mSeekBar.setOnSeekListener(new MediaSeekBar.OnUserSeekListener() {

            @Override
            public void onUserSeekStart(long startPosition) {
                showControllerLayers();
            }

            @Override
            public void onUserSeekPeeking(long peekPosition) {
                showControllerLayers();
            }

            @Override
            public void onUserSeekStop(long startPosition, long seekToPosition) {
                final Player player = player();
                if (player == null) return;

                if (player.isInPlaybackState()) {
                    if (player.isCompleted()) {
                        player.start();
                        player.seekTo(seekToPosition);
                    } else {
                        player.seekTo(seekToPosition);
                    }
                }

                showControllerLayers();
            }
        });

        mFullScreenIcon = view.findViewById(R.id.fullScreen);
        mFullScreenIcon.setOnClickListener(v -> {
            FullScreenLayer.toggle(videoView(), true);
        });

        mTimeContainer = view.findViewById(R.id.timeContainer);
        mCurrentPosition = mTimeContainer.findViewById(R.id.currentPosition);
        mDuration = mTimeContainer.findViewById(R.id.duration);

        mInteractLayout = view.findViewById(R.id.interact_stub);
        mLikeContainer = mInteractLayout.findViewById(R.id.likeContainer);
        mLikeNum = mLikeContainer.findViewById(R.id.likeNum);
        mCommentContainer = mInteractLayout.findViewById(R.id.commentContainer);
        mCommentNum = mCommentContainer.findViewById(R.id.commentNum);

        mLikeContainer.setOnClickListener(v -> {
            boolean newValue = !v.isSelected();
            v.setSelected(newValue);
            VideoItem item = VideoViewExtras.getVideoItem(videoView());
            if (item != null) {
                item.setILikeIt(newValue);
                item.setLikeCount(item.getLikeCount() + (newValue ? 1 : -1));
                mLikeNum.setText(String.valueOf(item.getLikeCount()));
            }
        });
        mCommentContainer.setOnClickListener(v -> {
            FragmentActivity activity = activity();
            if (activity == null) {
                return;
            }
            String vid = VideoViewExtras.getVid(videoView());
            if (vid != null) {
                OuterActions.showCommentDialogL(activity, vid);
                GestureLayer layer = findLayer(GestureLayer.class);
                if (layer != null) {
                    layer.dismissController();
                }
            } else {
                L.w(this, "vid not found");
            }
        });

        mQuality = mInteractLayout.findViewById(R.id.quality);
        mQualityContainer = view.findViewById(R.id.qualityContainer);
        mQualityContainer.setOnClickListener(v -> {
            QualitySelectDialogLayer qualitySelectLayer = findLayer(QualitySelectDialogLayer.class);
            if (qualitySelectLayer != null) {
                qualitySelectLayer.animateShow(false);
            }
        });
        mSpeed = mInteractLayout.findViewById(R.id.speed);
        mSpeedContainer = mInteractLayout.findViewById(R.id.speedContainer);
        mSpeedContainer.setOnClickListener(v -> {
            SpeedSelectDialogLayer speedSelectLayer = findLayer(SpeedSelectDialogLayer.class);
            if (speedSelectLayer != null) {
                speedSelectLayer.animateShow(false);
            }
        });

        mSubtitleContainer = mInteractLayout.findViewById(R.id.subtitleContainer);
        mSubtitle = mInteractLayout.findViewById(R.id.subtitle);
        mSubtitleIcon = mInteractLayout.findViewById(R.id.subtitle_icon);
        mSubtitleContainer.setOnClickListener(v -> {
            SubtitleSelectDialogLayer dialogLayer = findLayer(SubtitleSelectDialogLayer.class);
            if (dialogLayer != null) {
                dialogLayer.animateShow(false);
            }
        });

        mPlaylistContainer = mInteractLayout.findViewById(R.id.playlistContainer);
        mPlaylist = mInteractLayout.findViewById(R.id.playlist);
        mPlaylistContainer.setOnClickListener(v -> {
            PlaylistLayer playlistLayer = findLayer(PlaylistLayer.class);
            if (playlistLayer != null) {
                playlistLayer.animateShow(false);
            }
        });

        applyTheme(view);
        return view;
    }

    private void showControllerLayers() {
        GestureLayer gestureLayer = findLayer(GestureLayer.class);
        if (gestureLayer != null) {
            gestureLayer.showController();
        }
    }

    private void applyTheme(View view) {
        if (view == null) return;
        if (isFullScreenMode(playScene())) {
            applyFullScreen(view);
        } else {
            applyHalfScreen(view);
        }
    }

    // region Half Screen View
    private View mFullScreenIcon;

    private void applyHalfScreen(View view) {
        mInteractLayout.setVisibility(View.GONE);
        mTimeContainer.setVisibility(View.GONE);

        final VideoLayerHost layerHost = layerHost();
        final boolean isLocked = layerHost != null && layerHost.isLocked();
        mSeekBar.setTextVisibility(!isLocked);
        mSeekBar.setSeekEnabled(!isLocked);

        mFullScreenIcon.setVisibility(isLocked ? View.GONE : View.VISIBLE);

        mSubtitleContainer.setVisibility(View.GONE);

        mPlaylistContainer.setVisibility(View.GONE);

        ViewGroup.MarginLayoutParams lp = (ViewGroup.MarginLayoutParams) mSeekBar.getLayoutParams();
        lp.height = (int) UIUtils.dip2Px(context(), 44);
        lp.leftMargin = lp.rightMargin = (int) UIUtils.dip2Px(context(), 10);
        mSeekBar.setLayoutParams(lp);

        view.setBackgroundResource(R.drawable.vevod_time_progress_bar_layer_halfscreen_shadow_shape);
    }
    // endregion

    // region Full Screen View
    private View mInteractLayout;

    private View mTimeContainer;
    private TextView mCurrentPosition;
    private TextView mDuration;

    private View mLikeContainer;
    private TextView mLikeNum;

    private View mCommentContainer;
    private TextView mCommentNum;

    private View mQualityContainer;
    private TextView mQuality;

    private View mPlaylistContainer;
    private TextView mPlaylist;

    private View mSpeedContainer;
    private TextView mSpeed;

    private View mSubtitleContainer;
    private TextView mSubtitle;
    private ImageView mSubtitleIcon;

    private void applyFullScreen(View view) {
        mFullScreenIcon.setVisibility(View.GONE);

        mTimeContainer.setVisibility(View.VISIBLE);

        final VideoLayerHost layerHost = layerHost();
        final boolean isLocked = layerHost != null && layerHost.isLocked();
        mInteractLayout.setVisibility(isLocked ? View.GONE : View.VISIBLE);

        mSeekBar.setTextVisibility(false);
        mSeekBar.setSeekEnabled(!isLocked);

        SubtitleSelectDialogLayer subtitleDialogLayer = findLayer(SubtitleSelectDialogLayer.class);
        mSubtitleContainer.setVisibility(subtitleDialogLayer == null ? View.GONE : View.VISIBLE);

        PlaylistLayer playlistLayer = findLayer(PlaylistLayer.class);
        mPlaylistContainer.setVisibility(playlistLayer == null ? View.GONE : View.VISIBLE);

        ViewGroup.MarginLayoutParams lp = (ViewGroup.MarginLayoutParams) mSeekBar.getLayoutParams();
        lp.height = (int) UIUtils.dip2Px(context(), 40);
        lp.leftMargin = lp.rightMargin = (int) UIUtils.dip2Px(context(), 36);
        mSeekBar.setLayoutParams(lp);
        view.setBackgroundResource(R.drawable.vevod_time_progress_bar_layer_fullscreen_shadow_shape);

        applyCounts();
    }
    // endregion

    private void syncProgress() {
        final Player player = player();
        if (player != null) {
            if (player.isInPlaybackState()) {
                setProgress(player.getCurrentPosition(), player.getDuration(), player.getBufferedPercentage());
            }
        }
    }

    private void setProgress(long currentPosition, long duration, int bufferPercent) {
        if (!checkShow() || !isShowing()) {
            return;
        }
        if (mSeekBar != null) {
            if (duration >= 0) {
                mSeekBar.setDuration(duration);
            }
            if (currentPosition >= 0) {
                mSeekBar.setCurrentPosition(currentPosition);
            }
            if (bufferPercent >= 0) {
                mSeekBar.setCachePercent(bufferPercent);
            }
        }

        if (mCurrentPosition != null) {
            if (currentPosition >= 0) {
                mCurrentPosition.setText(TimeUtils.time2String(currentPosition));
            }
        }
        if (mDuration != null) {
            if (duration >= 0) {
                mDuration.setText(TimeUtils.time2String(duration));
            }
        }
    }

    private void syncQuality() {
        if (mQuality == null) return;
        final Player player = player();
        if (player != null) {
            Track selected = player.getSelectedTrack(Track.TRACK_TYPE_VIDEO);
            if (selected != null) {
                Quality quality = selected.getQuality();
                if (quality != null) {
                    mQuality.setText(quality.getQualityDesc());
                }
            }

            List<Track> tracks = player.getTracks(Track.TRACK_TYPE_VIDEO);
            if (tracks == null) {
                mQualityContainer.setVisibility(View.GONE);
            } else {
                mQualityContainer.setVisibility(View.VISIBLE);
            }
        } else {
            mQualityContainer.setVisibility(View.GONE);
        }
    }

    private void syncSpeed() {
        if (mSpeed == null) return;
        final Player player = player();

        if (player != null) {
            float speed = player.getSpeed();
            if (speed != 1) {
                mSpeed.setText(SpeedSelectDialogLayer.mapSpeed(context(), speed));
            } else {
                mSpeed.setText(R.string.vevod_time_progress_bar_speed);
            }
        } else {
            mSpeed.setText(R.string.vevod_time_progress_bar_speed);
        }
    }

    private void syncSubtitle() {
        if (mSubtitle == null) return;
        final Player player = player();

        Subtitle selectedSubtitle = player == null ? null : player.getSelectedSubtitle();
        if (selectedSubtitle != null && player.isSubtitleEnabled()) {
            mSubtitleIcon.setImageResource(R.drawable.vevod_fullscreen_subtitle_enable);
            mSubtitle.setText(SubtitleSelectDialogLayer.getLanguage(mSpeed.getContext(), selectedSubtitle.languageId));
            SubtitleLayer layer = findLayer(SubtitleLayer.class);
            if (layer != null && !layer.isShowing()) {
                layer.applyVisible();
            }
        } else {
            SubtitleLayer layer = findLayer(SubtitleLayer.class);
            if (layer != null && layer.isShowing()) {
                layer.dismiss();
            }
            mSubtitle.setText(R.string.vevod_time_progress_subtitle);
            mSubtitleIcon.setImageResource(R.drawable.vevod_fullscreen_subtitle_disable);
        }
    }

    private void syncPlaylist() {
        if (mPlaylistContainer == null || mPlaylistContainer.getVisibility() == View.GONE) {
            return;
        }
        PlaylistLayer playlistLayer = findLayer(PlaylistLayer.class);
        if (playlistLayer == null) {
            return;
        }
        mPlaylist.setText(String.valueOf(playlistLayer.getPlaylistSize()));
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
        dismiss();
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        VideoView videoView = videoView();
        PlaybackController playbackController =videoView == null ? null : videoView.controller();
        if (isInPictureInPictureMode) {
            if (playbackController != null) {
                playbackController.removePlaybackListener(mPlaybackListener);
            }
            dismiss();
        } else {
            if (playbackController != null) {
                playbackController.addPlaybackListener(mPlaybackListener);
            }
            show();
        }
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlayerEvent.State.STARTED:
                case PlayerEvent.Info.SEEKING_START: {
                    syncProgress();
                    if (mCompletedPolicy == CompletedPolicy.KEEP && isShowing()) {
                        dismiss();
                    }
                    break;
                }
                case PlayerEvent.State.PAUSED: {
                    syncProgress();
                    break;
                }
                case PlayerEvent.State.COMPLETED: {
                    syncProgress();
                    if (checkShow() && (mCompletedPolicy == CompletedPolicy.KEEP)) {
                        show();
                    } else {
                        dismiss();
                    }
                    break;
                }
                case PlayerEvent.State.STOPPED:
                case PlayerEvent.State.RELEASED: {
                    dismiss();
                    break;
                }
                case PlayerEvent.Info.PROGRESS_UPDATE: {
                    InfoProgressUpdate e = event.cast(InfoProgressUpdate.class);
                    setProgress(e.currentPosition, e.duration, -1);
                    break;
                }
                case PlayerEvent.Info.BUFFERING_UPDATE: {
                    InfoBufferingUpdate e = event.cast(InfoBufferingUpdate.class);
                    setProgress(-1, -1, e.percent);
                    break;
                }
                case PlayerEvent.Info.TRACK_WILL_CHANGE: {
                    InfoTrackWillChange e = event.cast(InfoTrackWillChange.class);
                    if (e.trackType == Track.TRACK_TYPE_VIDEO) {
                        if (mQuality != null) {
                            final Quality quality;
                            if (e.current != null) {
                                quality = e.current.getQuality();
                            } else {
                                quality = e.target.getQuality();
                            }
                            if (quality != null) {
                                mQuality.setText(quality.getQualityDesc());
                            }
                        }
                    }
                    break;
                }
                case PlayerEvent.Info.TRACK_CHANGED: {
                    InfoTrackChanged e = event.cast(InfoTrackChanged.class);
                    if (e.trackType == Track.TRACK_TYPE_VIDEO) {
                        if (mQuality != null) {
                            Quality quality = e.current.getQuality();
                            if (quality != null) {
                                mQuality.setText(quality.getQualityDesc());
                            }
                        }
                    }
                    break;
                }
                case PlayerEvent.Info.SUBTITLE_CHANGED: {
                    syncSubtitle();
                    break;
                }
            }
        }
    };

    @Override
    public void show() {
        if (!checkShow()) return;
        super.show();
        sync();
    }

    private void sync() {
        applyTheme(getView());
        syncProgress();
        syncQuality();
        syncSpeed();
        syncSubtitle();
        syncPlaylist();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (checkShow()) {
            sync();
        } else {
            dismiss();
        }
    }

    @Override
    protected void onLayerHostLockStateChanged(boolean locked) {
        if (checkShow() && isShowing()) {
            sync();
        }
    }

    protected boolean checkShow() {
        return true;
    }

    @Override
    protected boolean preventAnimateDismiss() {
        final Player player = player();
        return player != null && player.isPaused();
    }

    private void applyCounts() {
        VideoItem item = VideoViewExtras.getVideoItem(videoView());
        if (mLikeContainer != null) {
            boolean isILikeIt = item != null && item.isILikeIt();
            mLikeContainer.setSelected(isILikeIt);
        }
        if (mLikeNum != null) {
            int likeCount = item == null ? 0 : item.getLikeCount();
            mLikeNum.setText(String.valueOf(likeCount));
        }
        if (mCommentNum != null) {
            int commentCount = item == null ? 0 : item.getCommentCount();
            mCommentNum.setText(String.valueOf(commentCount));
        }
    }
}
