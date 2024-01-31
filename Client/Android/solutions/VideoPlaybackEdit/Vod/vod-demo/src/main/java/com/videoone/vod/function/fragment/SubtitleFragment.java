package com.videoone.vod.function.fragment;

import androidx.annotation.NonNull;

import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.vod.scenekit.ui.video.layer.SubtitleLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.SubtitleSelectDialogLayer;

public class SubtitleFragment extends VodFunctionFragment{

    @Override
    protected void addFunctionLayer(@NonNull VideoLayerHost layerHost) {
        super.addFunctionLayer(layerHost);
        layerHost.addLayer(new SubtitleLayer());
        layerHost.addLayer(new SubtitleSelectDialogLayer());
    }
}