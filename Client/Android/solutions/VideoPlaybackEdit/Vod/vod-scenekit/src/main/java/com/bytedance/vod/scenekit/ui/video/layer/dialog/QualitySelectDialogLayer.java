// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.vod.scenekit.ui.video.layer.dialog;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.event.InfoTrackChanged;
import com.bytedance.playerkit.player.event.InfoTrackInfoReady;
import com.bytedance.playerkit.player.event.InfoTrackWillChange;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.playerkit.player.source.Quality;
import com.bytedance.playerkit.player.source.Track;

import com.bytedance.vod.scenekit.ui.video.layer.Layers;
import com.bytedance.vod.scenekit.ui.video.layer.TipsLayer;
import com.bytedance.vod.scenekit.ui.video.layer.GestureLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.R;

import java.util.ArrayList;
import java.util.List;


public class QualitySelectDialogLayer extends DialogListLayer<Track> {

    private boolean mUserQualitySwitching;

    public QualitySelectDialogLayer() {
        super();
        adapter().setOnItemClickListener((position, holder) -> {
            Item<Track> item = adapter().getItem(position);
            if (item != null) {
                Player player = player();
                if (player != null) {
                    mUserQualitySwitching = true;
                    player.selectTrack(item.obj.getTrackType(), item.obj);
                    animateDismiss();
                }
            }
        });
        setAnimateDismissListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                VideoLayerHost host = layerHost();
                if (host == null) return;

                TipsLayer tipsLayer = host.findLayer(TipsLayer.class);
                if (tipsLayer == null || !tipsLayer.isShowing()) {
                    GestureLayer layer = host.findLayer(GestureLayer.class);
                    if (layer != null) {
                        layer.showController();
                    }
                }
            }
        });
    }

    @Nullable
    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        setTitle(parent.getResources().getString(R.string.vevod_quality_select_title));
        return super.createDialogView(parent);
    }

    @Override
    public String tag() {
        return "quality_select";
    }

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.QUALITY_SELECT_DIALOG_LAYER_BACK_PRIORITY;
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!isFullScreenMode(toScene)) {
            dismiss();
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

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            VideoLayerHost host = layerHost();
            if (host == null) return;
            Context context = context();
            if (context == null) return;

            switch (event.code()) {
                case PlayerEvent.Info.TRACK_INFO_READY: {
                    InfoTrackInfoReady e = event.cast(InfoTrackInfoReady.class);
                    if (e.trackType != Track.TRACK_TYPE_VIDEO) return;

                    final List<Track> tracks = e.tracks;
                    bindData(tracks);
                    break;
                }
                case PlayerEvent.Info.TRACK_WILL_CHANGE: {
                    InfoTrackWillChange e = event.cast(InfoTrackWillChange.class);
                    if (e.trackType != Track.TRACK_TYPE_VIDEO) return;

                    select(e.target);

                    if (!mUserQualitySwitching) return;

                    TipsLayer tipsLayer = host.findLayer(TipsLayer.class);
                    if (tipsLayer != null) {
                        Quality quality = e.target.getQuality();
                        tipsLayer.show(context.getString(R.string.vevod_quality_select_tips_will_switch,
                                quality == null ? null : quality.getQualityDesc()));
                    }
                    break;
                }
                case PlayerEvent.Info.TRACK_CHANGED: {
                    InfoTrackChanged e = event.cast(InfoTrackChanged.class);
                    if (e.trackType != Track.TRACK_TYPE_VIDEO) return;

                    adapter().setSelected(adapter().findItem(e.current));

                    if (!mUserQualitySwitching) return;
                    mUserQualitySwitching = false;

                    select(e.current);
                    TipsLayer tipsLayer = host.findLayer(TipsLayer.class);
                    if (tipsLayer != null) {
                        Quality quality = e.current.getQuality();
                        tipsLayer.show(context.getString(R.string.vevod_quality_select_tips_switched, quality == null ? null : quality.getQualityDesc()));
                    }
                    break;
                }
            }
        }
    };

    @Override
    public void show() {
        syncData();
        super.show();
    }

    private void syncData() {
        final Player player = player();
        if (player == null) return;

        final MediaSource source = dataSource();
        if (source == null) return;

        @Track.TrackType
        final int trackType = source.getMediaType() == MediaSource.MEDIA_TYPE_AUDIO ?
                Track.TRACK_TYPE_AUDIO : Track.TRACK_TYPE_VIDEO;
        final List<Track> tracks = player.getTracks(trackType);
        if (tracks == null) return;

        bindData(tracks);

        final Track track = player.getSelectedTrack(trackType);
        select(track);
    }

    private void select(Track track) {
        adapter().setSelected(adapter().findItem(track));
    }

    private void bindData(List<Track> tracks) {
        final List<Item<Track>> items = new ArrayList<>();
        for (Track track : tracks) {
            final Quality quality = track.getQuality();
            if (quality != null) {
                items.add(new Item<>(track, quality.getQualityDesc()));
            }
        }
        adapter().setList(items);
    }
}
