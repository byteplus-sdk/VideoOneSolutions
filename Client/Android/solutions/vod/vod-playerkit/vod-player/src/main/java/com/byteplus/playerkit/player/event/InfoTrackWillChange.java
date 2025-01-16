// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import android.annotation.SuppressLint;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.utils.event.Event;


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
        trackType = Track.TRACK_TYPE_UNKNOWN;
        current = null;
        target = null;
    }
}
