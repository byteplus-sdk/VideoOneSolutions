// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer.base;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;

public abstract class PlaybackEventLayer extends BaseLayer {

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
