// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.VolumeBrightnessDialogLayer;
import com.bytedance.vod.scenekit.R;


public class VolumeBrightnessIconLayer extends AnimateLayer {

    private View mVolume;

    private View mBrightness;

    @Override
    public String tag() {
        return "volume";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_volume_brightness_icon_layer, parent, false);
        mVolume = view.findViewById(R.id.volumeContainer);
        mBrightness = view.findViewById(R.id.brightnessContainer);
        mVolume.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                VolumeBrightnessDialogLayer layer = layerHost().findLayer(VolumeBrightnessDialogLayer.class);
                if (layer != null) {
                    layer.setType(VolumeBrightnessDialogLayer.TYPE_VOLUME);
                    layer.animateShow(true);
                }
            }
        });

        mBrightness.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                VolumeBrightnessDialogLayer layer = layerHost().findLayer(VolumeBrightnessDialogLayer.class);
                if (layer != null) {
                    layer.setType(VolumeBrightnessDialogLayer.TYPE_BRIGHTNESS);
                    layer.animateShow(true);
                }
            }
        });
        return view;
    }

    public View getVolumeView() {
        return mVolume;
    }

    public View getBrightnessView() {
        return mBrightness;
    }
}
