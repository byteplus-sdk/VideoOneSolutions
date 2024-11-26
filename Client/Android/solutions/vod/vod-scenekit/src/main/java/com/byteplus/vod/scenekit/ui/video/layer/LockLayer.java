// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.utils.UIUtils;

public class LockLayer extends AnimateLayer {

    private ImageView mImageView;

    public LockLayer() {
        setIgnoreLock(true);
    }

    @Override
    public String tag() {
        return "lock";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        mImageView = new ImageView(parent.getContext());
        mImageView.setLayoutParams(new FrameLayout.LayoutParams(
                (int) UIUtils.dip2Px(context(), 44),
                (int) UIUtils.dip2Px(context(), 44),
                Gravity.CENTER_VERTICAL | Gravity.RIGHT));
        ((FrameLayout.LayoutParams) mImageView.getLayoutParams()).rightMargin = (int) UIUtils.dip2Px(context(), 60);
        mImageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        mImageView.setImageDrawable(ResourcesCompat.getDrawable(parent.getResources(), R.drawable.vevod_lock_layer_ic_selector, null));
        mImageView.setOnClickListener(v -> {
            layerHost().setLocked(!layerHost().isLocked());

            GestureLayer gestureLayer = layerHost().findLayer(GestureLayer.class);
            if (gestureLayer != null) {
                gestureLayer.showController();
            }
        });
        return mImageView;
    }

    @Override
    protected void onLayerHostLockStateChanged(boolean locked) {
        super.onLayerHostLockStateChanged(locked);
        syncLockedState(locked);
    }

    @Override
    public void show() {
        super.show();
        syncLockedState(isLayerHostLocked());
    }

    private boolean isLayerHostLocked() {
        VideoLayerHost layerHost = layerHost();
        return layerHost != null && layerHost.isLocked();
    }

    private boolean hasVolumeBrightnessIconLayer() {
        VideoLayerHost layerHost = layerHost();
        if (layerHost != null) {
            VolumeBrightnessIconLayer layer = layerHost.findLayer(VolumeBrightnessIconLayer.class);
           return layer != null;
        }
       return false;
    }

    private void syncLockedState(boolean locked) {
        if (mImageView != null) {
            mImageView.setSelected(locked);
            if (locked) {
                mImageView.setTranslationY(0);
            } else {
                int transY = hasVolumeBrightnessIconLayer() ? (int) UIUtils.dip2Px(context(), -56) : 0;
                mImageView.setTranslationY(transY);
            }
        }
    }
}
