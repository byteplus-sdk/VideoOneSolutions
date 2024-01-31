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
import androidx.recyclerview.widget.RecyclerView;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.playerkit.player.source.Subtitle;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.ui.video.layer.GestureLayer;
import com.bytedance.vod.scenekit.ui.video.layer.Layers;
import com.bytedance.vod.scenekit.ui.video.layer.TipsLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.vod.settingskit.CenteredToast;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class SubtitleSelectDialogLayer extends DialogListLayer<Subtitle> {

    public SubtitleSelectDialogLayer() {
        adapter().setOnItemClickListener((position, holder) -> {
            Item<Subtitle> item = adapter().getItem(position);
            if (item != null) {
                Player player = player();
                if (player != null) {
                    Subtitle subtitle = player.isSubtitleEnabled() ? player.getSelectedSubtitle() : null;
                    Subtitle select = item.obj;
                    if (subtitle != select) {
                        if (select == null) {
                            if (player.isSubtitleEnabled()) {
                                CenteredToast.show(holder.itemView.getContext(), R.string.vevod_subtitle_tips_off);
                            }
                            player.setSubtitleEnabled(false);
                        } else {
                            if (!player.isSubtitleEnabled()) {
                                CenteredToast.show(holder.itemView.getContext(), R.string.vevod_subtitle_tips_on);
                            }
                            player.setSubtitleEnabled(true);
                            player.selectSubtitle(select);
                        }
                        animateDismiss();
                        adapter().setSelected(adapter().findItem(select));
                    }
                }
            }
        });
        setAnimateDismissListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                VideoLayerHost layerHost = layerHost();
                if (layerHost == null) return;

                TipsLayer tipsLayer = layerHost.findLayer(TipsLayer.class);
                if (tipsLayer == null || !tipsLayer.isShowing()) {
                    GestureLayer layer = layerHost.findLayer(GestureLayer.class);
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
        setTitle(parent.getResources().getString(R.string.vevod_time_progress_bar_subtitle));
        return super.createDialogView(parent);
    }

    private List<Item<Subtitle>> createItems(Context context) {
        final Player player = player();
        List<Subtitle> subtitles = player == null ? null : player.getSubtitles();
        List<Item<Subtitle>> list = new ArrayList<>();
        list.add(new Item<>(null, context.getString(R.string.vevod_subtitle_dialog_off)));
        if (subtitles != null) {
            for (Subtitle subtitle : subtitles) {
                if ("ASR".equals(subtitle.source)) {
                    if (list.size() > 1) {
                        list.add(1, new Item<>(subtitle, getLanguage(context, subtitle.languageId)));
                        continue;
                    }
                }
                list.add(new Item<>(subtitle, getLanguage(context, subtitle.languageId)));
            }
        }
        return list;

    }

    @Override
    public void show() {
        super.show();

        Player player = player();
        if (player != null) {
            adapter().setList(createItems(context()));
            if (player.isSubtitleEnabled()) {
                adapter().setSelected(adapter().findItem(player.getSelectedSubtitle()));
            } else {
                adapter().setSelected(null);
            }
        }
    }

    @Override
    public String tag() {
        return "subtitle_select";
    }

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.SPEED_SELECT_DIALOG_LAYER_BACK_PRIORITY;
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!isFullScreenMode(toScene)) {
            dismiss();
        }
    }

    public static String getLanguage(Context context, int lanId) {
        switch (lanId) {
            case 1:
                return context.getString(R.string.vevod_subtitle_dialog_ch);
            case 2:
                return context.getString(R.string.vevod_subtitle_dialog_en);
            case 3:
                return context.getString(R.string.vevod_subtitle_dialog_jp);
            case 4:
                return context.getString(R.string.vevod_subtitle_dialog_ko);
            default:
                return context.getString(R.string.vevod_time_progress_bar_subtitle);
        }
    }
}
