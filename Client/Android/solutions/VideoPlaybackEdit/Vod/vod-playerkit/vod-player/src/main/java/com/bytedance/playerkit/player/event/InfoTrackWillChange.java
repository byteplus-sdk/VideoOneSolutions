// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import android.annotation.SuppressLint;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.source.Track;
import com.bytedance.playerkit.utils.event.Event;


public class InfoTrackWillChange extends Event {

    @Track.TrackType
    public int trackType;
    public Track current;
    public Track target;

    public InfoTrackWillChange() {
        super(PlayerEvent.Info.TRACK_WILL_CHANGE);
    }

    public InfoTrackWillChange init(@Track.TrackType int trackType, Track current, Track target) {
        this.trackType = trackType;
        this.current = current;
        this.target = target;
        return this;
    }

    @SuppressLint("WrongConstant")
    @Override
    public void recycle() {
        super.recycle();
        trackType = 0;
        current = null;
        target = null;
    }
}
