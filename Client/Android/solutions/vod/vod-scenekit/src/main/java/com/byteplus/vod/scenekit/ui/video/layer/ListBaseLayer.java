// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.layer;

import androidx.annotation.Nullable;

import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

public abstract class ListBaseLayer extends DialogLayer {
    @Nullable
    @Override
    public String tag() {
        return "base_list";
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!PlayScene.isFullScreenMode(toScene)) {
            dismiss();
        }
    }

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.PLAYLIST_DIALOG_BACK_PRIORITY;
    }

    public int getSize() {
        return 0;
    }

}
