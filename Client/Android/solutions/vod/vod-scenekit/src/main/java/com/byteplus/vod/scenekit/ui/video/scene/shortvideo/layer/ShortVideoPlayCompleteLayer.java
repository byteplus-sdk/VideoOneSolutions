// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.config.ICompleteAction;
import com.byteplus.vod.scenekit.ui.video.layer.FullScreenLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayCompleteLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoPlayCompleteLayer extends PlayCompleteLayer {
    public ShortVideoPlayCompleteLayer() {
        setIgnoreLock(true);
    }

    @Override
    protected void onPlaybackEvent(Event event) {
        ICompleteAction config = getConfig();
        int action = config != null ? config.completeAction() : ICompleteAction.LOOP;
        if (action == ICompleteAction.LOOP) {
            // Loop mode, no need show PlayCompleteLayer
            dismiss();
            return;
        }

        if (FullScreenLayer.isFullScreen(videoView())) {
            // Only show in FullScreen/Landscape mode
            super.onPlaybackEvent(event);
        }
        // do nothing in Portrait mode
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!PlayScene.isFullScreenMode(toScene)) {
            dismiss();
        }
    }
}
