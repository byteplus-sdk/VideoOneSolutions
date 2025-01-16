// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer.base;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.playback.ext.IStrategy;
import com.byteplus.playerkit.player.playback.VideoLayer;
import com.byteplus.playerkit.player.playback.VideoLayerHost;

import java.util.Collections;
import java.util.List;


public abstract class BaseLayer extends VideoLayer {

    public void requestShow(@NonNull String reason) {
        show();
    }

    public void requestDismiss(@NonNull String reason) {
        dismiss();
    }

    public void requestHide(@NonNull String reason) {
        hide();
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        return null;
    }

    // region VideoOne Enhancement
    @Nullable
    protected final <T extends VideoLayer> T findLayer(String tag) {
        VideoLayerHost layerHost = layerHost();
        if (layerHost == null) return null;
        return (T) layerHost.findLayer(tag);
    }

    @Nullable
    protected final <T extends VideoLayer> T findLayer(Class<T> clazz) {
        VideoLayerHost layerHost = layerHost();
        if (layerHost == null) return null;
        return layerHost.findLayer(clazz);
    }

    @NonNull
    protected final <T extends VideoLayer> List<T> findLayers(Class<T> clazz) {
        VideoLayerHost layerHost = layerHost();
        if (layerHost == null) return Collections.emptyList();
        return layerHost.findLayers(clazz);
    }

    public <T> T getConfig() {
        VideoLayerHost layerHost = layerHost();
        IStrategy config = layerHost.getConfig();
        return (T) config;
    }
    // endregion
}
