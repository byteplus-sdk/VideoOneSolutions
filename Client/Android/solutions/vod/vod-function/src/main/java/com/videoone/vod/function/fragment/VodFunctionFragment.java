// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.vod.function.fragment;

import static com.videoone.vod.function.VodFunctionActivity.EXTRA_VIDEO_ITEM;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

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
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.byteplus.vodfunction.R;
import com.byteplus.vodfunction.databinding.VevodFunctionFragmentBinding;
import com.videoone.avatars.Avatars;

public class VodFunctionFragment extends BaseFragment {

    private VideoView mVideoView;

    private boolean mInterceptStartPlaybackOnResume;
    private boolean mKeepPlaybackState = false;

    public VodFunctionFragment() {
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.vevod_function_fragment;
    }

    @Override
    public boolean onBackPressed() {
        if (mVideoView != null) {
            final VideoLayerHost layerHost = mVideoView.layerHost();
            if (layerHost != null && layerHost.onBackPressed()) {
                return true;
            }
        }
        if (mVideoView != null) {
            mVideoView.stopPlayback();
        }

        if (mVideoView != null) {
            final PlaybackController controller = mVideoView.controller();
            if (controller != null) {
                controller.unbindPlayer();
            }
            mVideoView = null;
        }
        return super.onBackPressed();
    }

    private VevodFunctionFragmentBinding mBinding;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        view.setOnClickListener(v -> {/* consume click event */});

        mBinding = VevodFunctionFragmentBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.statusBars());
            mBinding.guidelineTop.setGuidelineBegin(insets.top);
            return WindowInsetsCompat.CONSUMED;
        });

        VevodFunctionFragmentBinding binding = mBinding;
        if (binding == null) return;

        mVideoView = createVideoView(requireContext());
        mBinding.videoViewContainer.addView(mVideoView,
                new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT, Gravity.CENTER));

        boolean showBottomContainer = setupBottomContainer(mBinding.bottomContainer);
        mBinding.bottomContainer.setVisibility(showBottomContainer ? View.VISIBLE : View.GONE);

        Bundle bundle = requireArguments();
        VideoItem videoItem = getVideoItem(bundle);
        playVideo(videoItem);
    }

    protected VideoItem getVideoItem(Bundle bundle) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return bundle.getSerializable(EXTRA_VIDEO_ITEM, VideoItem.class);
        } else {
            return (VideoItem) bundle.getSerializable(EXTRA_VIDEO_ITEM);
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
            Player player = mVideoView.player();
            if (player == null || !player.isPlaying()) {
                mVideoView.startPlayback();
            }
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
        videoView.setPlayScene(PlayScene.SCENE_SINGLE_FUNCTION);
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

        addFunctionLayer(layerHost);

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

    protected VideoView getVideoView() {
        return mVideoView;
    }

    protected final void playVideo(VideoItem videoItem) {
        assert videoItem != null : "VideoItem not provided";

        if (mVideoView.getDataSource() != null) {
            mVideoView.stopPlayback();
        }

        MediaSource mediaSource = VideoItem.toMediaSource(videoItem);
        mVideoView.bindDataSource(mediaSource);
        VideoViewExtras.updateExtra(mVideoView, videoItem);

        mBinding.title.setText(videoItem.getTitle());
        mBinding.subtitle.setText(FormatHelper.formatCountAndCreateTime(requireContext(), videoItem));

        Glide.with(mBinding.avatar)
                .load(Avatars.byUserId(videoItem.getUserId()))
                .transform(new CircleCrop())
                .into(mBinding.avatar);

        mBinding.username.setText(videoItem.getUserName());

        play();
    }

    protected void addFunctionLayer(@NonNull VideoLayerHost layerHost) {

    }

    protected boolean setupBottomContainer(FrameLayout container) {
        return false;
    }
}
