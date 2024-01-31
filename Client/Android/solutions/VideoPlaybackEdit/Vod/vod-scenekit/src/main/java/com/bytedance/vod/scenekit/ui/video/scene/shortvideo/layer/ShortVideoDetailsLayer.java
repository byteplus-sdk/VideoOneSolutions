// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.FragmentActivity;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CenterCrop;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.PlaybackEvent;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.databinding.VevodShortVideoDetailsLayerBinding;
import com.bytedance.vod.scenekit.ui.base.OuterActions;
import com.bytedance.vod.scenekit.ui.base.VideoViewExtras;
import com.bytedance.vod.scenekit.ui.video.layer.FullScreenLayer;
import com.bytedance.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.vod.scenekit.utils.FormatHelper;
import com.videoone.avatars.Avatars;

public class ShortVideoDetailsLayer extends BaseLayer {
    private VevodShortVideoDetailsLayerBinding binding;

    @Nullable
    @Override
    public String tag() {
        return "short_video_details";
    }

    public ShortVideoDetailsLayer() {
        setIgnoreLock(true);
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        binding = VevodShortVideoDetailsLayerBinding.inflate(
                LayoutInflater.from(parent.getContext()),
                parent,
                false
        );
        binding.fullScreen.setOnClickListener(v -> {
            FullScreenLayer.toggle(videoView(), true);
        });
        binding.like.addAnimatorListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                if (animatorListenerAdapter != null) {
                    animatorListenerAdapter.onAnimationEnd(animation);
                }
            }
        });
        binding.like.addLottieOnCompositionLoadedListener(composition -> binding.like.setFrame(0));
        return binding.getRoot();
    }

    @Nullable
    private AnimatorListenerAdapter animatorListenerAdapter;

    /**
     * @see ShortVideoProgressBarLayer
     */
    public void bind(VideoItem item) {
        show();
        Context context = context();
        assert context != null;
        binding.title.setText(context.getString(R.string.vevod_short_video_at, item.getUserName()));

        // Patch for TextView height issue when setMaxLines(int) called
        String subtitle = item.getTitle();
        binding.subtitle.setMaxLines(TextUtils.isEmpty(subtitle) ? 0 : 2);
        binding.subtitle.setText(subtitle);

        // PM: Only show progress bar when duration > 1 Min
        // Leave padding for ProgressBar
        boolean showBottom = item.getDuration() > 60_000;
        binding.bottom.setVisibility(showBottom ? View.VISIBLE : View.GONE);

        Glide.with(binding.avatar)
                .load(Avatars.byUserId(item.getUserId()))
                .transform(new CenterCrop(), new CircleCrop())
                .into(binding.avatar);

        updateLikeView(context, item);

        binding.comment.setText(FormatHelper.formatCount(context, item.getCommentCount()));

        binding.comment.setOnClickListener(v -> {
            FragmentActivity activity = activity();
            if (activity == null) {
                return;
            }
            OuterActions.showCommentDialog(activity, item.getVid());
        });

        loadCover(item);
    }

    private void updateLikeView(Context context, VideoItem item) {
        animatorListenerAdapter = new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                if (binding.likeContainer.isEnabled()) {
                    // Not user triggered event
                    return;
                }
                item.setLikeCount(item.getLikeCount() + (item.isILikeIt() ? 1 : -1));

                binding.like.setAnimation(item.isILikeIt() ? "like_cancel.json" : "like_icondata.json");
                binding.likeNum.setText(FormatHelper.formatCount(context, item.getLikeCount()));
                binding.likeContainer.setEnabled(true);
            }
        };
        binding.likeNum.setText(FormatHelper.formatCount(context, item.getLikeCount()));
        binding.like.setAnimation(item.isILikeIt() ? "like_cancel.json" : "like_icondata.json");
        binding.likeContainer.setEnabled(true);
        binding.likeContainer.setOnClickListener(v -> {
            binding.likeContainer.setEnabled(false);
            item.setILikeIt(!item.isILikeIt());
            binding.like.playAnimation();
        });
    }

    public void updateDisplayAnchor(int width, int height) {
        ConstraintLayout.LayoutParams params = (ConstraintLayout.LayoutParams) binding.displayAnchor.getLayoutParams();
        params.dimensionRatio = width + ":" + height;

        binding.fullScreen.setVisibility(View.VISIBLE);
    }

    public void updateDisplayFullScreen() {
        ConstraintLayout.LayoutParams params = (ConstraintLayout.LayoutParams) binding.displayAnchor.getLayoutParams();
        params.dimensionRatio = null;

        binding.fullScreen.setVisibility(View.GONE);
    }

    public void onDoubleTap() {
        VideoItem item = VideoViewExtras.getVideoItem(videoView());
        if (item == null || item.isILikeIt()) {
            return;
        }

        binding.likeContainer.performClick();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        // Short Details Page only shows when in portrait
        if (isFullScreenMode(toScene)) {
            dismiss();
        } else {
            show();
            VideoItem item = VideoViewExtras.getVideoItem(videoView());
            if (item != null) {
                binding.likeNum.setText(FormatHelper.formatCount(context(), item.getLikeCount()));
                binding.like.setAnimation(item.isILikeIt() ? "like_cancel.json" : "like_icondata.json");
                binding.likeContainer.setEnabled(true);
            }
        }
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    private final Dispatcher.EventListener mPlaybackListener = event -> {
        switch (event.code()) {
            case PlaybackEvent.Action.START_PLAYBACK: {
                final Player player = player();
                if (player != null && player.isInPlaybackState()) {
                    return;
                }
                showCover();
                break;
            }
            case PlayerEvent.Action.SET_SURFACE: {
                final Player player = player();
                if (player != null && player.isInPlaybackState()) {
                    dismissCover();
                } else {
                    showCover();
                }
                break;
            }
            case PlayerEvent.Action.START: {
                final Player player = player();
                if (player != null && player.isPaused()) {
                    dismissCover();
                }
                break;
            }
            case PlaybackEvent.Action.STOP_PLAYBACK:
            case PlayerEvent.Action.STOP:
            case PlayerEvent.Action.RELEASE: {
                showCover();
                break;
            }
            case PlayerEvent.Info.VIDEO_RENDERING_START: {
                dismissCover();
                break;
            }
        }
    };

    public void showCover() {
        binding.displayAnchor.setVisibility(View.VISIBLE);
    }

    public void dismissCover() {
        binding.displayAnchor.setVisibility(View.INVISIBLE);
    }

    private void loadCover(VideoItem item) {
        if (!VideoSettings.booleanValue(VideoSettings.SHORT_VIDEO_ENABLE_IMAGE_COVER)) {
            binding.displayAnchor.setImageDrawable(null);
            return;
        }
        String coverUrl = item.getCover();
        binding.displayAnchor.post(() -> {
            // Should use post to wait ImageView re-layout
            Glide.with(binding.displayAnchor)
                    .load(coverUrl)
                    .transform(new CenterCrop())
                    .into(binding.displayAnchor);
        });
    }
}
