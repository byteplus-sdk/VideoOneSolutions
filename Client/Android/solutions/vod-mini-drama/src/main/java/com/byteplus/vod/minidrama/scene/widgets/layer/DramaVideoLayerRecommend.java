// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.content.res.Resources;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.bumptech.glide.Glide;
import com.byteplus.vod.minidrama.event.EpisodeRecommendClicked;
import com.byteplus.vod.minidrama.event.OnCommentEvent;
import com.byteplus.vod.minidrama.event.OnRecommendForYou;
import com.byteplus.vod.minidrama.remote.model.drama.DisplayType;
import com.byteplus.vod.minidrama.remote.model.drama.DramaRecommend;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaRecommendVideoLayerBinding;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.videoone.avatars.Avatars;

public class DramaVideoLayerRecommend extends DramaVideoLayer {

    public DramaVideoLayerRecommend() {
        super(Type.RECOMMEND);
    }

    private VevodMiniDramaRecommendVideoLayerBinding binding;

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        binding = VevodMiniDramaRecommendVideoLayerBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);

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

    @Override
    protected void updateUI() {
        VideoItem videoItem = VideoItem.get(dataSource());
        DramaRecommend recommend = DramaRecommend.of(videoItem);
        if (videoItem == null || recommend == null) {
            L.w(this, "syncRecommendData", "recommend is null");
            return;
        }
        assert binding != null;
        final Context context = binding.getRoot().getContext();

        binding.episodesRecommendForYou.setOnClickListener(v -> {
            MiniEventBus.post(new OnRecommendForYou(recommend));
        });

        binding.fullScreen.setOnClickListener(v -> {
            MiniEventBus.post(EpisodeRecommendClicked.text(recommend));
        });

        binding.avatar.setImageResource(Avatars.byUserId(videoItem.getUserId()));
        binding.comment.setText(FormatHelper.formatCount(context, videoItem.getCommentCount()));
        binding.likeNum.setText(FormatHelper.formatCount(context, videoItem.getLikeCount()));
        binding.likeContainer.setEnabled(true);

        binding.comment.setOnClickListener(v -> {
            MiniEventBus.post(OnCommentEvent.portrait(videoItem.getVid()));
        });

        updateLikeView(context, videoItem);

        if (recommend.getDisplayType() == DisplayType.COVER) {
            displayCoverMode(context, videoItem, recommend);
        } else {
            displayTextMode(context, videoItem, recommend);
        }
    }

    void displayCoverMode(@NonNull Context context,
                          @NonNull VideoItem videoItem,
                          @NonNull DramaRecommend recommend) {
        binding.groupStyleNormal.setVisibility(View.GONE);
        binding.groupStyleCard.setVisibility(View.VISIBLE);

        binding.dramaTitleCard.setText(recommend.getDramaTitle());
        binding.dramaPlayTimes.setText(FormatHelper.formatCount(context, recommend.getDramaPlayTimes()));

        Glide.with(binding.dramaCover)
                .load(recommend.getDramaCover())
                .centerCrop()
                .into(binding.dramaCover);

        binding.playNow.setOnClickListener(v -> {
            MiniEventBus.post(EpisodeRecommendClicked.cover(recommend));
        });
    }

    void displayTextMode(@NonNull Context context,
                         @NonNull VideoItem videoItem,
                         @NonNull DramaRecommend recommend) {
        Resources resources = context.getResources();
        binding.groupStyleNormal.setVisibility(View.VISIBLE);
        binding.groupStyleCard.setVisibility(View.GONE);

        binding.dramaTitleNormal.setText(recommend.getDramaTitle());
        binding.username.setText(resources.getString(R.string.vevod_mini_drama_at, videoItem.getUserName()));
        binding.description.setText(resources.getString(
                R.string.vevod_mini_drama_episode_description,
                recommend.getDramaTitle(),
                recommend.getEpisodeNumber(),
                recommend.getEpisodeTitle()
        ));

        binding.dramaTitleNormalContainer.setOnClickListener(v -> {
            MiniEventBus.post(EpisodeRecommendClicked.text(recommend));
        });
    }

    private AnimatorListenerAdapter animatorListenerAdapter;

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

    @Override
    public void onDoubleTap() {
        VideoItem item = VideoViewExtras.getVideoItem(videoView());
        if (item == null || item.isILikeIt()) {
            return;
        }

        binding.likeContainer.performClick();
    }
}
