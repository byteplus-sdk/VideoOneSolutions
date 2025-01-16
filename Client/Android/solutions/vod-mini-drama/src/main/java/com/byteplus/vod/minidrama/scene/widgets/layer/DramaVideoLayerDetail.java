// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.airbnb.lottie.LottieAnimationView;
import com.byteplus.minidrama.R;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.minidrama.event.OnCommentEvent;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras;
import com.byteplus.vod.scenekit.ui.video.layer.PauseLayer;
import com.byteplus.vod.scenekit.utils.FormatHelper;

public class DramaVideoLayerDetail extends DramaVideoLayer {

    public DramaVideoLayerDetail() {
        super(Type.DETAIL);
    }

    @Override
    public void onVideoViewBindDataSource(MediaSource dataSource) {
        super.onVideoViewBindDataSource(dataSource);
        updateUI();
    }

    private View likeContainer;
    private LottieAnimationView likeView;
    private TextView likeNum;
    private AnimatorListenerAdapter animatorListenerAdapter;

    private TextView commentView;

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        final View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_mini_drama_video_layer, parent, false);

        commentView = view.findViewById(R.id.comment);

        likeContainer = view.findViewById(R.id.like_container);
        likeView = likeContainer.findViewById(R.id.like);
        likeNum = likeContainer.findViewById(R.id.like_num);
        likeView.addAnimatorListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                if (animatorListenerAdapter != null) {
                    animatorListenerAdapter.onAnimationEnd(animation);
                }
            }
        });
        likeView.addLottieOnCompositionLoadedListener(composition -> likeView.setFrame(0));
        return view;
    }

    @Override
    public void onVideoViewStartPlaybackIntercepted(VideoView videoView, String reason) {
        super.onVideoViewStartPlaybackIntercepted(videoView, reason);
        if (INTERCEPT_START_PLAYBACK_REASON_LOCKED.equals(reason)) {
            PauseLayer layer = findLayer(PauseLayer.class);
            if (layer != null) {
                layer.show();
            }
        }
    }

    @Override
    protected void updateUI() {
        VideoItem videoItem = VideoItem.get(dataSource());
        if (videoItem == null) {
            return;
        }

        View view = getView();
        if (view == null) {
            return;
        }
        final Context context = view.getContext();

        commentView.setText(FormatHelper.formatCount(context, videoItem.getCommentCount()));
        likeNum.setText(FormatHelper.formatCount(context, videoItem.getLikeCount()));
        likeContainer.setEnabled(true);

        commentView.setOnClickListener(v -> {
            MiniEventBus.post(OnCommentEvent.portrait(videoItem.getVid()));
        });

        updateLikeView(context, videoItem);
    }

    @Override
    public void onDoubleTap() {
        VideoItem item = VideoViewExtras.getVideoItem(videoView());
        if (item == null || item.isILikeIt()) {
            return;
        }

        likeContainer.performClick();
    }

    private void updateLikeView(Context context, VideoItem item) {
        animatorListenerAdapter = new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                if (likeContainer.isEnabled()) {
                    // Not user triggered event
                    return;
                }
                item.setLikeCount(item.getLikeCount() + (item.isILikeIt() ? 1 : -1));

                likeView.setAnimation(item.isILikeIt() ? "like_cancel.json" : "like_icondata.json");
                likeNum.setText(FormatHelper.formatCount(context, item.getLikeCount()));
                likeContainer.setEnabled(true);
            }
        };
        likeNum.setText(FormatHelper.formatCount(context, item.getLikeCount()));
        likeView.setAnimation(item.isILikeIt() ? "like_cancel.json" : "like_icondata.json");
        likeContainer.setEnabled(true);
        likeContainer.setOnClickListener(v -> {
            likeContainer.setEnabled(false);
            item.setILikeIt(!item.isILikeIt());
            likeView.playAnimation();
        });
    }
}
