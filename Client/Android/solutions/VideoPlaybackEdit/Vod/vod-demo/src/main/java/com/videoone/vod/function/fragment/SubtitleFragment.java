// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.vod.function.fragment;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.vod.scenekit.ui.video.layer.SubtitleLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.SubtitleSelectDialogLayer;

public class SubtitleFragment extends VodFunctionFragment{

    @Override
    protected void addFunctionLayer(@NonNull VideoLayerHost layerHost) {
        super.addFunctionLayer(layerHost);
        layerHost.addLayer(new SubtitleLayer());
        layerHost.addLayer(new SubtitleSelectDialogLayer());
    }
}