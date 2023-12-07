// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer.base;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.playerkit.utils.event.Event;

public abstract class PlaybackEventAnimateLayer extends AnimateLayer {

    private final Dispatcher.EventListener mEventListener = this::onPlaybackEvent;

    @CallSuper
    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mEventListener);
    }

    @CallSuper
    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mEventListener);
    }

    protected void onPlaybackEvent(Event event) {

    }
}
