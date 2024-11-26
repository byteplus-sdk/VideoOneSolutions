// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.video.scene.detail;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Rect;
import android.os.Build;
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
import androidx.lifecycle.ViewModelProvider;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
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
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras;
import com.byteplus.vod.scenekit.ui.video.layer.CoverLayer;
import com.byteplus.vod.scenekit.ui.video.layer.FullScreenLayer;
import com.byteplus.vod.scenekit.ui.video.layer.FullScreenTipsLayer;
import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LockLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.MiniPlayerLayer;
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
import com.byteplus.vod.scenekit.ui.video.layer.helper.MiniPlayerHelper;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoPageView;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.byteplus.vod.scenekit.utils.ViewUtils;
import com.byteplus.voddemo.R;
import com.byteplus.vodcommon.data.remote.RemoteApi;
import com.byteplus.voddemo.databinding.VevodDetailVideoFragmentBinding;
import com.byteplus.voddemo.ui.video.scene.detail.bean.RecommendInfo;
import com.videoone.avatars.Avatars;


public class DetailVideoFragment extends BaseFragment {

    public static final String EXTRA_MEDIA_SOURCE = "extra_media_source";
    public static final String EXTRA_CONTINUES_PLAYBACK = "extra_continues_playback";

    public static final String EXTRA_VIDEO_ITEM = "extra_video_item";

    public static final String EXTRA_KEEP_PLAYBACK_STATE = "extra_keep_playback_state";

    public static final String EXTRA_RECOMMEND_TYPE = "extra_recommend_type";

    @Nullable
    private VideoItem mVideoItem;

    private boolean mContinuesPlayback;

    private VideoView mVideoView;

    private VideoView mSharedVideoView;
    private View mTransitionView;
    private boolean mInterceptStartPlaybackOnResume;
    private boolean mKeepPlaybackState = false;

    private DetailViewModel mDetailModel;

    public interface DetailVideoSceneEventListener {
        void onEnterDetail();

        void onExitDetail();
    }

    public DetailVideoFragment() {
    }


    public static Bundle createBundle(VideoItem item, MediaSource mediaSource, boolean continuesPlay,
                                      @RemoteApi.VideoType int videoType) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(EXTRA_VIDEO_ITEM, item);
        bundle.putSerializable(EXTRA_MEDIA_SOURCE, mediaSource);
        bundle.putBoolean(EXTRA_CONTINUES_PLAYBACK, continuesPlay);
        bundle.putInt(EXTRA_RECOMMEND_TYPE, videoType);
        return bundle;
    }

    public static Bundle createBundle(VideoItem item, @RemoteApi.VideoType int videoType) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(EXTRA_VIDEO_ITEM, item);
        bundle.putInt(EXTRA_RECOMMEND_TYPE, videoType);
        return bundle;
    }

    public static DetailVideoFragment newInstance(@Nullable Bundle bundle) {
        DetailVideoFragment fragment = new DetailVideoFragment();
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
        if (mVideoView != null && isCurrentRecommendItem()) {
            mVideoView.stopPlayback();
        }
        if (mFeedVideoViewHolder != null) {
            mVideoView = null;
            return animateExit();
        }
        if (mContinuesPlayback || isCurrentRecommendItem()) {
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

    private boolean isCurrentRecommendItem() {
        return mDetailModel.recommendVideoItem.getValue() != null;
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
        mDetailModel = new ViewModelProvider(this).get(DetailViewModel.class);
        Bundle bundle = getArguments();
        if (bundle != null) {
            mContinuesPlayback = bundle.getBoolean(EXTRA_CONTINUES_PLAYBACK);
            VideoItem videoItem = mVideoItem = bundle.getParcelable(EXTRA_VIDEO_ITEM);
            mKeepPlaybackState = bundle.getBoolean(EXTRA_KEEP_PLAYBACK_STATE, false);

            String vid = videoItem == null ? null : videoItem.getVid();
            if (vid != null) {
                int videoType = bundle.getInt(EXTRA_RECOMMEND_TYPE, RemoteApi.VideoType.FEED);
                RecommendInfo info = new RecommendInfo(vid, videoType);
                mDetailModel.recommendInfo.setValue(info);
            }
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
            mVideoView = mSharedVideoView = mFeedVideoViewHolder.getSharedVideoView();
            ViewUtils.removeFromParent(mSharedVideoView);
            startEnterTransition();

            // take Over SharedVideoView
            mFeedVideoViewHolder.detachSharedVideoView(mSharedVideoView);
        } else {
            mVideoView = createVideoView(requireActivity());

            MediaSource mediaSource = (MediaSource) requireArguments().getSerializable(EXTRA_MEDIA_SOURCE);
            assert mediaSource != null;
            mVideoView.bindDataSource(mediaSource);
            VideoViewExtras.updateExtra(mVideoView, mVideoItem);
        }

        binding.videoViewContainer.addView(mVideoView,
                new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT, Gravity.CENTER));

        mVideoView.setPlayScene(PlayScene.SCENE_DETAIL);

        renderVideoInfo(binding, mVideoItem);

        mDetailModel.recommendVideoItem.observe(getViewLifecycleOwner(), videoItem -> {
            if (videoItem == null) {
                return;
            }

            renderVideoInfo(binding, videoItem);

            assert mVideoView != null;
            if (mVideoView == mSharedVideoView) {
                // Prevent reuse shared VideoView for recommend Item
                mVideoView.stopPlayback();
                ViewUtils.removeFromParent(mVideoView);

                mVideoView = createVideoView(requireActivity());
                binding.videoViewContainer.addView(mVideoView,
                        new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                                FrameLayout.LayoutParams.MATCH_PARENT, Gravity.CENTER));
                mVideoView.setPlayScene(PlayScene.SCENE_DETAIL);
            }
            mVideoView.stopPlayback();
            MediaSource mediaSource = VideoItem.toMediaSource(videoItem);
            mVideoView.bindDataSource(mediaSource);
            VideoViewExtras.updateExtra(mVideoView, videoItem);
            mVideoView.startPlayback();

            mDetailModel.updateRecommendInfoVid(videoItem.getVid());
        });
    }

    private void renderVideoInfo(VevodDetailVideoFragmentBinding binding, VideoItem item) {
        if (item != null) {
            binding.title.setText(item.getTitle());
            binding.subtitle.setText(FormatHelper.formatCountAndCreateTime(requireContext(), item));

            Glide.with(binding.avatar)
                    .load(Avatars.byUserId(item.getUserId()))
                    .transform(new CircleCrop())
                    .into(binding.avatar);

            binding.username.setText(item.getUserName());
        } else {
            binding.title.setVisibility(View.GONE);
            binding.subtitle.setVisibility(View.GONE);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mSharedVideoView != mVideoView) {
            VideoView videoView = mVideoView;
            VideoLayerHost videoLayerHost = videoView == null ? null : videoView.layerHost();
            if (videoLayerHost != null) {
                videoLayerHost.removeAllLayers();
            }
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
            if (!mKeepPlaybackState) {
                play();
            }
            mKeepPlaybackState = false;
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
                if (MiniPlayerHelper.get().isMiniPlayerOff()) {
                    mVideoView.pausePlayback();
                }
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
        layerHost.addLayer(new TimeProgressBarLayer(TimeProgressBarLayer.CompletedPolicy.KEEP));
        layerHost.addLayer(new TitleBarLayer());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layerHost.addLayer(new MiniPlayerLayer());
        }

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
        if (mVideoView != null && mSharedVideoView != mVideoView) {
            mVideoView.stopPlayback();
        }
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
