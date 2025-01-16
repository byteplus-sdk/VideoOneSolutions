// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.app.Activity;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CenterCrop;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;

public class CoverLayer extends BaseLayer {

    @Override
    public String tag() {
        return "cover";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        ImageView imageView = new ImageView(parent.getContext());
        imageView.setScaleType(ImageView.ScaleType.FIT_XY);
        imageView.setBackgroundColor(ContextCompat.getColor(parent.getContext(), android.R.color.black));
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
                Gravity.CENTER);
        imageView.setLayoutParams(lp);
        return imageView;
    }

    @Override
    public void onVideoViewBindDataSource(MediaSource dataSource) {
        show();
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlaybackEvent.Action.START_PLAYBACK: {
                    final Player player = player();
                    if (player != null && player.isInPlaybackState()) {
                        return;
                    }
                    show();
                    break;
                }
                case PlaybackEvent.Action.STOP_PLAYBACK: {
                    show();
                    break;
                }
                case PlayerEvent.Action.SET_SURFACE: {
                    final Player player = player();
                    if (player != null && player.isInPlaybackState()) {
                        dismiss();
                    } else {
                        show();
                    }
                    break;
                }
                case PlayerEvent.Action.START: {
                    final Player player = player();
                    if (player != null && player.isPaused()) {
                        dismiss();
                    }
                    break;
                }
                case PlayerEvent.Action.STOP:
                case PlayerEvent.Action.RELEASE: {
                    show();
                    break;
                }
                case PlayerEvent.Info.VIDEO_RENDERING_START: {
                    dismiss();
                    break;
                }
            }
        }
    };

    @Override
    public void show() {
        super.show();
        load();
    }

    protected void load() {
        final ImageView imageView = getImageView();
        if (imageView == null) return;
        final String coverUrl = resolveCoverUrl();
        Activity activity = activity();
        if (activity != null && !activity.isDestroyed()) {
            Glide.with(imageView)
                    .load(coverUrl)
                    .transform(new CenterCrop())
                    .into(imageView);
        }
    }

    protected ImageView getImageView() {
        return getView();
    }

    String resolveCoverUrl() {
        final VideoView videoView = videoView();
        if (videoView == null) return null;

        final MediaSource mediaSource = videoView.getDataSource();
        if (mediaSource == null) return null;

        return mediaSource.getCoverUrl();
    }
}
