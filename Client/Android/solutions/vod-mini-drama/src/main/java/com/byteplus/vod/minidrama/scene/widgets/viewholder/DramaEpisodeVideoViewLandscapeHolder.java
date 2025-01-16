// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.viewholder;

import android.os.Build;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.byteplus.minidrama.R;
import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.DisplayView;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoLandscapeFragment;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaEpisodeListLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaGestureLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaTimeProgressBarLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaTitleBarLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoLayer;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.layer.CoverLayer;
import com.byteplus.vod.scenekit.ui.video.layer.FullScreenTipsLayer;
import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LockLayer;
import com.byteplus.vod.scenekit.ui.video.layer.MiniPlayerLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayCompleteLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayErrorLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayPauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.SubtitleLayer;
import com.byteplus.vod.scenekit.ui.video.layer.SyncStartTimeLayer;
import com.byteplus.vod.scenekit.ui.video.layer.TipsLayer;
import com.byteplus.vod.scenekit.ui.video.layer.VolumeBrightnessIconLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.QualitySelectDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.SpeedSelectDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.SubtitleSelectDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.TimeProgressDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.VolumeBrightnessDialogLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

public class DramaEpisodeVideoViewLandscapeHolder extends DramaEpisodeVideoViewHolder {

    @NonNull
    final DramaDetailVideoLandscapeFragment landscapeFragment;

    public DramaEpisodeVideoViewLandscapeHolder(@NonNull DramaDetailVideoLandscapeFragment fragment, @NonNull View itemView,
                                                DramaVideoLayer.Type type,
                                                DramaGestureLayer.DramaGestureContract gestureContract) {
        super(itemView, type, gestureContract);
        landscapeFragment = fragment;
    }

    @NonNull
    @Override
    protected VideoView createVideoView(@NonNull FrameLayout parent, DramaVideoLayer.Type type, DramaGestureLayer.DramaGestureContract gestureContract) {
        VideoView videoView = new VideoView(parent.getContext());
        videoView.setPlayScene(PlayScene.SCENE_FULLSCREEN);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        lp.gravity = Gravity.CENTER;
        parent.addView(videoView, lp);

        VideoLayerHost layerHost = new VideoLayerHost(parent.getContext());
        layerHost.addLayer(new GestureLayer());
        layerHost.addLayer(new CoverLayer());
        layerHost.addLayer(new DramaTimeProgressBarLayer());
        layerHost.addLayer(new DramaTitleBarLayer(() -> {
            VideoItem videoItem = (VideoItem) getBindingItem();
            if (videoItem == null) {
                return "";
            }
            return parent.getContext().getString(R.string.vevod_mini_drama_detail_video_episode_number_desc,
                    DramaFeed.of(videoItem).episodeNumber);
        }));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layerHost.addLayer(new MiniPlayerLayer());
        }
        layerHost.addLayer(new DramaEpisodeListLayer(new DramaEpisodeListLayer.IEpisodeListCallback() {
            @Override
            public int getSize() {
                return landscapeFragment.currentDrama().episodeVideoItems.size();
            }

            @Override
            public DramaItem getDramaItem() {
                return landscapeFragment.currentDrama();
            }

            @Override
            public Fragment getFragment() {
                return landscapeFragment;
            }
        }));

        layerHost.addLayer(DramaVideoLayer.create(type));
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

        layerHost.addLayer(new QualitySelectDialogLayer());
        layerHost.addLayer(new SpeedSelectDialogLayer());
        layerHost.addLayer(MoreDialogLayer.create());

        if (VideoSettings.booleanValue(VideoSettings.COMMON_SHOW_FULL_SCREEN_TIPS)) {
            layerHost.addLayer(new FullScreenTipsLayer());
        }
        layerHost.addLayer(new SubtitleLayer());
        layerHost.addLayer(new SubtitleSelectDialogLayer());
        layerHost.attachToVideoView(videoView);
        videoView.setBackgroundColor(ContextCompat.getColor(parent.getContext(), android.R.color.black));
        videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT);
        videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW);
        new PlaybackController().bind(videoView);
        return videoView;
    }
}
