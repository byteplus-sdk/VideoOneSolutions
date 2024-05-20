// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback.event;

import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Event;


public class StateBindVideoView extends Event {

    public VideoView videoView;

    public StateBindVideoView() {
        super(PlaybackEvent.State.BIND_VIDEO_VIEW);
    }

    public StateBindVideoView init(VideoView videoView) {
        this.videoView = videoView;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        this.videoView = null;
    }
}
