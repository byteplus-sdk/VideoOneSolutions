// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer.base;

import androidx.annotation.NonNull;

import com.bytedance.playerkit.player.playback.VideoLayer;

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
}
