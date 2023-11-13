// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.vod.scenekit.ui.video.layer.dialog;

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

import com.bytedance.vod.scenekit.ui.video.layer.Layers;
import com.bytedance.vod.scenekit.ui.video.layer.TipsLayer;
import com.bytedance.vod.scenekit.ui.video.layer.GestureLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.vod.scenekit.R;

import java.util.Arrays;
import java.util.List;


public class SpeedSelectDialogLayer extends DialogListLayer<Float> {

    public SpeedSelectDialogLayer() {
        adapter().setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(int position, RecyclerView.ViewHolder holder) {
                Item<Float> item = adapter().getItem(position);
                if (item != null) {
                    Player player = player();
                    if (player != null) {
                        float speed = player.getSpeed();
                        float select = item.obj;
                        if (select != speed) {
                            player.setSpeed(select);
                            animateDismiss();

                            VideoLayerHost layerHost = layerHost();
                            if (layerHost == null) return;
                            TipsLayer tipsLayer = layerHost.findLayer(TipsLayer.class);
                            if (tipsLayer != null) {
                                tipsLayer.show("Speed is switched to " + item.text);
                            }
                            adapter().setSelected(adapter().findItem(select));
                        }
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
        setTitle(parent.getResources().getString(R.string.vevod_speed_select_dialog_title));
        adapter().setList(createItems(parent.getContext()));
        return super.createDialogView(parent);
    }

    private static List<Item<Float>> createItems(Context context) {
        return Arrays.asList(
                new Item<>(3.0F, "3.0x"),
                new Item<>(2.0F, "2.0x"),
                new Item<>(1.5F, "1.5x"),
                new Item<>(1.0F, "1.0x"),
                new Item<>(0.5F, "0.5x")
        );
    }

    @Override
    public void show() {
        super.show();

        Player player = player();
        if (player != null) {
            adapter().setSelected(adapter().findItem(player.getSpeed()));
        }
    }

    private static List<Item<Float>> sItems;

    public static String mapSpeed(Context context, float speed) {
        if (sItems == null) {
            sItems = createItems(context);
        }
        for (Item<Float> item : sItems) {
            if (speed == item.obj) {
                return item.text;
            }
        }
        return null;
    }

    @Override
    public String tag() {
        return "speed_select";
    }

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.SPEED_SELECT_DIALOG_LAYER_BACK_PRIORITY;
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (toScene != PlayScene.SCENE_FULLSCREEN) {
            dismiss();
        }
    }
}
