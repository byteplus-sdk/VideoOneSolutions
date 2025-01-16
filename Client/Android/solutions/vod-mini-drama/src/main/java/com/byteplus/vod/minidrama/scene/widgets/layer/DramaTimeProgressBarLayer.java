// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import com.byteplus.vod.minidrama.event.OnCommentEvent;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras;
import com.byteplus.vod.scenekit.ui.video.layer.TimeProgressBarLayer;

public class DramaTimeProgressBarLayer extends TimeProgressBarLayer {
    public DramaTimeProgressBarLayer() {
        super(TimeProgressBarLayer.CompletedPolicy.KEEP);
    }

    @Override
    protected void onCommentClicked() {
        String vid = VideoViewExtras.getVid(videoView());
        if (vid != null) {
            MiniEventBus.post(OnCommentEvent.landscape(vid));
        } else {
            L.w(this, "vid not found");
        }
    }
}
