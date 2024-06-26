// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.sample;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.DisplayView;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.base.BaseFragment;
import com.byteplus.vod.scenekit.ui.video.layer.CoverLayer;
import com.byteplus.vod.scenekit.ui.video.layer.FullScreenLayer;
import com.byteplus.vod.scenekit.ui.video.layer.FullScreenTipsLayer;
import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LockLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayCompleteLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayErrorLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayPauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.SyncStartTimeLayer;
import com.byteplus.vod.scenekit.ui.video.layer.TimeProgressBarLayer;
import com.byteplus.vod.scenekit.ui.video.layer.TipsLayer;
import com.byteplus.vod.scenekit.ui.video.layer.TitleBarLayer;
import com.byteplus.vod.scenekit.ui.video.layer.VolumeBrightnessIconLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.QualitySelectDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.SpeedSelectDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.TimeProgressDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.VolumeBrightnessDialogLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoPageView;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.byteplus.vod.scenekit.utils.ViewUtils;
import com.byteplus.voddemo.R;
import com.byteplus.voddemo.databinding.VevodDetailVideoFragmentBinding;


public class SampleDetailVideoFragment extends BaseFragment {

    public static final String EXTRA_MEDIA_SOURCE = "extra_media_source";
    public static final String EXTRA_CONTINUES_PLAYBACK = "extra_continues_playback";

    public static final String EXTRA_VIDEO_ITEM = "extra_video_item";

    private MediaSource mMediaSource;

    @Nullable
    private VideoItem mVideoItem;

    private boolean mContinuesPlayback;

    private VideoView mVideoView;

    private VideoView mSharedVideoView;
    private View mTransitionView;
    private boolean mInterceptStartPlaybackOnResume;

    public interface DetailVideoSceneEventListener {
        void onEnterDetail();

        void onExitDetail();
    }

    public SampleDetailVideoFragment() {
    }

    public static Bundle createBundle(MediaSource mediaSource, boolean continuesPlay) {
        Bundle bundle = new Bundle();
        bundle.putSerializable(EXTRA_MEDIA_SOURCE, mediaSource);
        bundle.putBoolean(EXTRA_CONTINUES_PLAYBACK, continuesPlay);
        return bundle;
    }

    public static Bundle createBundle(VideoItem item, MediaSource mediaSource, boolean continuesPlay) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(EXTRA_VIDEO_ITEM, item);
        bundle.putSerializable(EXTRA_MEDIA_SOURCE, mediaSource);
        bundle.putBoolean(EXTRA_CONTINUES_PLAYBACK, continuesPlay);
        return bundle;
    }

    public static Bundle createBundle(VideoItem item) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(EXTRA_VIDEO_ITEM, item);
        return bundle;
    }

    public static SampleDetailVideoFragment newInstance(@Nullable Bundle bundle) {
        SampleDetailVideoFragment fragment = new SampleDetailVideoFragment();
        if (bundle != null) {
            fragment.setArguments(bundle);
        }
        return fragment;
    }

    protected FeedVideoPageView.DetailPageNavigator.FeedVideoViewHolder mFeedVideoViewHolder;

    public void setFeedVideoViewHolder(FeedVideoPageView.DetailPageNavigator.FeedVideoViewHolder holder) {
        mFeedVideoViewHolder = holder;
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.vevod_detail_video_fragment;
    }

    @Override
    public boolean onBackPressed() {
        if (mVideoView != null) {
            final VideoLayerHost layerHost = mVideoView.layerHost();
            if (layerHost != null && layerHost.onBackPressed()) {
                return true;
            }
        }
        if (mFeedVideoViewHolder != null) {
            mVideoView = null;
            return animateExit();
        }
        if (mContinuesPlayback) {
            if (mVideoView != null) {
                final PlaybackController controller = mVideoView.controller();
                if (controller != null) {
                    controller.unbindPlayer();
                }
                mVideoView = null;
            }
        }
        return super.onBackPressed();
    }

    private boolean animateExit() {
        if (isVisible()) {
            startExitTransition(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    giveBackSharedVideoView();
                    requireActivity().onBackPressed();
                }
            });
            return true;
        } else {
            giveBackSharedVideoView();
            return false;
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle bundle = getArguments();
        if (bundle != null) {
            mMediaSource = (MediaSource) bundle.getSerializable(EXTRA_MEDIA_SOURCE);
            mContinuesPlayback = bundle.getBoolean(EXTRA_CONTINUES_PLAYBACK);
            mVideoItem = bundle.getParcelable(EXTRA_VIDEO_ITEM);
        }
    }

    @Override
    protected void initBackPressedHandler() {
        if (mFeedVideoViewHolder != null) {
            super.initBackPressedHandler();
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        view.setOnClickListener(v -> {/* consume click event */});

        VevodDetailVideoFragmentBinding binding = VevodDetailVideoFragmentBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.statusBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            return WindowInsetsCompat.CONSUMED;
        });

        mTransitionView = binding.transitionView;
        if (mFeedVideoViewHolder != null) {
            mSharedVideoView = mFeedVideoViewHolder.getSharedVideoView();
            ViewUtils.removeFromParent(mSharedVideoView);
            startEnterTransition();

            // take Over SharedVideoView
            mFeedVideoViewHolder.detachSharedVideoView(mSharedVideoView);
            mVideoView = mSharedVideoView;
        } else {
            mVideoView = createVideoView(requireActivity());
            mVideoView.bindDataSource(mMediaSource);
        }

        binding.videoViewContainer.addView(mVideoView,
                new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT, Gravity.CENTER));
        mVideoView.setPlayScene(PlayScene.SCENE_DETAIL);

        if (mVideoItem != null) {
            binding.title.setText(mVideoItem.getTitle());
            binding.subtitle.setText(FormatHelper.formatCountAndCreateTime(requireContext(), mVideoItem));
        } else {
            binding.title.setVisibility(View.GONE);
            binding.subtitle.setVisibility(View.GONE);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        resume();
    }

    @Override
    public void onPause() {
        super.onPause();
        pause();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        stop();
    }

    private void play() {
        if (mVideoView != null) {
            mVideoView.startPlayback();
        }
    }

    private void resume() {
        if (!mInterceptStartPlaybackOnResume) {
            play();
        }
        mInterceptStartPlaybackOnResume = false;
    }

    private void pause() {
        if (mVideoView != null) {
            Player player = mVideoView.player();
            if (player != null && (player.isPaused() || (!player.isLooping() && player.isCompleted()))) {
                mInterceptStartPlaybackOnResume = true;
            } else {
                mInterceptStartPlaybackOnResume = false;
                mVideoView.pausePlayback();
            }
        }
    }

    private void stop() {
        if (mVideoView != null) {
            mVideoView.stopPlayback();
            mVideoView = null;
        }
    }

    private VideoView createVideoView(Context context) {
        VideoView videoView = new VideoView(context);
        VideoLayerHost layerHost = new VideoLayerHost(context);
        layerHost.addLayer(new GestureLayer());
        layerHost.addLayer(new CoverLayer());

        layerHost.addLayer(new TimeProgressBarLayer());
        layerHost.addLayer(new TitleBarLayer());

        layerHost.addLayer(new TipsLayer());
        layerHost.addLayer(new SyncStartTimeLayer());
        layerHost.addLayer(new VolumeBrightnessIconLayer());
        layerHost.addLayer(new VolumeBrightnessDialogLayer());
        layerHost.addLayer(new TimeProgressDialogLayer());
        layerHost.addLayer(new PlayErrorLayer());
        layerHost.addLayer(new PlayPauseLayer());
        layerHost.addLayer(new LockLayer());
        layerHost.addLayer(new LoadingLayer());
        layerHost.addLayer(new PlayCompleteLayer());
        layerHost.addLayer(new FullScreenLayer());

        layerHost.addLayer(new QualitySelectDialogLayer());
        layerHost.addLayer(new SpeedSelectDialogLayer());
        layerHost.addLayer(MoreDialogLayer.create());

        if (VideoSettings.booleanValue(VideoSettings.COMMON_SHOW_FULL_SCREEN_TIPS)) {
            layerHost.addLayer(new FullScreenTipsLayer());
        }
        if (VideoSettings.booleanValue(VideoSettings.DEBUG_ENABLE_LOG_LAYER)) {
            layerHost.addLayer(new LogLayer());
        }
        layerHost.attachToVideoView(videoView);
        videoView.setBackgroundColor(ContextCompat.getColor(requireContext(), android.R.color.black));
        videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT);
        videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW);
        new PlaybackController().bind(videoView);
        return videoView;
    }

    private void giveBackSharedVideoView() {
        ViewUtils.removeFromParent(mSharedVideoView);
        mFeedVideoViewHolder.attachSharedVideoView(mSharedVideoView);
        mSharedVideoView = null;
        mFeedVideoViewHolder = null;
    }

    private void startEnterTransition() {
        final Rect startRect = mFeedVideoViewHolder.calVideoViewTransitionRect();
        mTransitionView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                mTransitionView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                if (isVisible()) {
                    final float targetY = mTransitionView.getY();
                    startTransitionAnimation(startRect.top, targetY, null);
                }
            }
        });
    }

    private void startExitTransition(Animator.AnimatorListener listener) {
        final float startY = mTransitionView.getY();
        final Rect targetRect = mFeedVideoViewHolder.calVideoViewTransitionRect();
        startTransitionAnimation(startY, targetRect.top, listener);
    }

    private void startTransitionAnimation(float startY, float targetY, Animator.AnimatorListener listener) {
        ValueAnimator animator = ValueAnimator
                .ofFloat(startY, targetY)
                .setDuration(300);
        animator.addUpdateListener(animation -> mTransitionView.setY((Float) animation.getAnimatedValue()));
        if (listener != null) {
            animator.addListener(listener);
        }
        animator.start();
    }
}
