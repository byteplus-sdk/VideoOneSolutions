// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.vod.scenekit.ui.video.layer.dialog;

import com.byteplus.playerkit.player.playback.VideoLayer;
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer;


public abstract class MoreDialogLayer extends DialogLayer {
    public static VideoLayer create() {
        return new MoreDialogLayerSimple(true, true);
    }

    public static VideoLayer createWithoutLoopMode() {
        return new MoreDialogLayerSimple(false, false);
    }
}
