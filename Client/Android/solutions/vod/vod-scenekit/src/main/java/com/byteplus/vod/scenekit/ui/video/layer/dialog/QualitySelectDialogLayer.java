// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.vod.scenekit.ui.video.layer.dialog;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.SuppressLint;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.event.InfoTrackChanged;
import com.byteplus.playerkit.player.event.InfoTrackInfoReady;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Quality;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.volcengine.VolcConfig;
import com.byteplus.playerkit.player.volcengine.VolcQualityStrategy;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.strategy.VideoQuality;
import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer;
import com.byteplus.vod.scenekit.ui.video.layer.Layers;
import com.byteplus.vod.scenekit.ui.video.layer.TipsLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.util.ArrayList;
import java.util.List;


public class QualitySelectDialogLayer extends DialogListLayer<Track> {

    public QualitySelectDialogLayer() {
        super();
        adapter().setOnItemClickListener((position, holder) -> {
            MediaSource mediaSource = dataSource();
            if (mediaSource == null) return;
            Item<Track> item = adapter().getItem(position);
            if (item != null) {
                Player player = player();
                if (player != null) {
                    if (item.obj == null) {
                        player.selectTrackAuto();
                        select(null);
                        VideoQuality.setUserSelectedQualityRes(playScene(), Quality.QUALITY_RES_DEFAULT);
                        TipsLayer tipsLayer = layerHost().findLayer(TipsLayer.class);
                        if (tipsLayer != null) {
                            tipsLayer.show(holder.itemView.getContext().getString(R.string.vevod_quality_select_tips_switched, createAutoQualityDesc(null)));
                        }
                    } else {
                        final Item<Track> autoItem = adapter().findItem(null);
                        if (autoItem != null) {
                            autoItem.text = createAutoQualityDesc(null);
                        }

                        player.selectTrack(item.obj.getTrackType(), item.obj);
                        select(item.obj);
                        final Quality quality = item.obj.getQuality();
                        if (quality != null) {
                            VideoQuality.setUserSelectedQualityRes(playScene(), quality.getQualityRes());
                        }
                        TipsLayer tipsLayer = layerHost().findLayer(TipsLayer.class);
                        if (tipsLayer != null) {
                            tipsLayer.show(holder.itemView.getContext().getString(R.string.vevod_quality_select_tips_will_switch,
                                    quality == null ? null : quality.getQualityDesc()));
                        }
                    }
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
        if (playScene() != PlayScene.SCENE_FULLSCREEN) {
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

        @SuppressLint("NotifyDataSetChanged")
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
                    bindData(e.owner(Player.class), e.trackType, tracks);
                    break;
                }
                case PlayerEvent.Info.TRACK_CHANGED: {
                    InfoTrackChanged e = event.cast(InfoTrackChanged.class);
                    if (e.trackType != Track.TRACK_TYPE_VIDEO) return;

                    final Player player = player();
                    if (player == null) return;

                    if (player.isABRAutoMode()) {
                        Item<Track> item = adapter().findItem(null);
                        if (item != null && e.current != null) {
                            item.text = createAutoQualityDesc(e.current.getQuality());
                            select(null);
                            adapter().notifyDataSetChanged();
                        }
                    } else {
                        select(e.current);
                        if (e.pre == null) return;

                        TipsLayer tipsLayer = host.findLayer(TipsLayer.class);
                        if (tipsLayer != null) {
                            Quality quality = e.current.getQuality();
                            tipsLayer.show(context.getString(R.string.vevod_quality_select_tips_switched, quality == null ? null : quality.getQualityDesc()));
                        }
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

        @Track.TrackType final int trackType = MediaSource.mediaType2TrackType(source);
        final List<Track> tracks = player.getTracks(trackType);
        if (tracks == null) return;

        bindData(player, trackType, tracks);
        syncSelect();
    }

    private void syncSelect() {
        final Player player = player();
        if (player == null) return;

        final MediaSource source = dataSource();
        if (source == null) return;

        @Track.TrackType final int trackType = MediaSource.mediaType2TrackType(source);

        if (player.isABRAutoMode()) {
            select(null);
        } else {
            final Track track = player.getSelectedTrack(trackType);
            select(track);
        }
    }

    private void select(Track track) {
        adapter().setSelected(adapter().findItem(track));
    }

    private void bindData(Player player, @Track.TrackType int trackType, List<Track> tracks) {
        final List<Item<Track>> items = new ArrayList<>();
        if (VolcQualityStrategy.isEnableABR(VolcConfig.get(dataSource())) && player.isSupportSmoothTrackSwitching(trackType)) {
            final String autoQualityDesc = createAutoQualityDesc(getAutoModeCurrentQuality(player()));
            items.add(new Item<>(null, autoQualityDesc));
        }

        for (int i = tracks.size() - 1; i >= 0; i--) {
            Track track = tracks.get(i);
            final Quality quality = track.getQuality();
            if (quality != null) {
                items.add(new Item<>(track, quality.getQualityDesc()));
            }
        }
        adapter().setItems(items);
    }

    @NonNull
    public static String createAutoQualityDesc(Quality quality) {
        return "AUTO" + (quality == null ? "" : " (" + quality.getQualityDesc() + ")");
    }

    @Nullable
    public static Quality getAutoModeCurrentQuality(Player player) {
        if (player != null && player.isABRAutoMode()) {
            final MediaSource mediaSource = player.getDataSource();
            if (mediaSource != null) {
                final Track track = player.getCurrentTrack(MediaSource.mediaType2TrackType(mediaSource));
                if (track != null) {
                    return track.getQuality();
                }
            }
        }
        return null;
    }
}
