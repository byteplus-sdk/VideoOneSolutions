// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.vod.scenekit.ui.video.layer.base;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.playback.VideoLayer;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.vod.scenekit.ui.video.layer.Layers;


public abstract class DialogLayer extends AnimateLayer implements VideoLayerHost.BackPressedHandler {

    private boolean mDismissOtherLayers = true;

    @Nullable
    @Override
    protected final View createView(@NonNull ViewGroup parent) {
        return createDialogView(parent);
    }

    abstract protected View createDialogView(@NonNull ViewGroup parent);

    @Override
    public boolean onBackPressed() {
        if (isShowing()) {
            animateDismiss();
            return true;
        } else {
            return false;
        }
    }

    public void setDismissOtherLayers(boolean dismiss) {
        mDismissOtherLayers = dismiss;
    }

    protected abstract int backPressedPriority();

    @CallSuper
    @Override
    protected void onBindLayerHost(@NonNull VideoLayerHost layerHost) {
        layerHost.registerBackPressedHandler(this, backPressedPriority());
    }

    @CallSuper
    @Override
    protected void onUnbindLayerHost(@NonNull VideoLayerHost layerHost) {
        layerHost.unregisterBackPressedHandler(this);
    }

    @Override
    public void show() {
        boolean isShowing = isShowing();
        super.show();
        if (!isShowing && isShowing()) {
            dismissLayers();
        }
    }

    private void dismissLayers() {
        if (!mDismissOtherLayers) {
            return;
        }
        for (int i = 0; i < layerHost().layerSize(); i++) {
            VideoLayer layer = layerHost().findLayer(i);
            if (layer instanceof AnimateLayer) {
                ((AnimateLayer) layer).requestAnimateDismiss(Layers.VisibilityRequestReason.REQUEST_DISMISS_REASON_DIALOG_SHOW);
            } else if (layer instanceof BaseLayer) {
                ((BaseLayer) layer).requestDismiss(Layers.VisibilityRequestReason.REQUEST_DISMISS_REASON_DIALOG_SHOW);
            }
        }
    }

    @Override
    public void requestDismiss(@NonNull String reason) {
        if (!TextUtils.equals(reason, Layers.VisibilityRequestReason.REQUEST_DISMISS_REASON_DIALOG_SHOW)) {
            super.requestDismiss(reason);
        }
    }

    @Override
    public void requestHide(@NonNull String reason) {
        if (!TextUtils.equals(reason, Layers.VisibilityRequestReason.REQUEST_DISMISS_REASON_DIALOG_SHOW)) {
            super.requestHide(reason);
        }
    }
}
