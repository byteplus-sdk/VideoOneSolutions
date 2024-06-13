// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback.event;

import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Event;


public class StateUnbindVideoView extends Event {

    public VideoView videoView;

    public StateUnbindVideoView() {
        super(PlaybackEvent.State.UNBIND_VIDEO_VIEW);
    }

    public StateUnbindVideoView init(VideoView videoView) {
        this.videoView = videoView;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        videoView = null;
    }
}
