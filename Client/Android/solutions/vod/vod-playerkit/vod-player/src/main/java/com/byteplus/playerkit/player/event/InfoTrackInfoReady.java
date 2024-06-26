// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import android.annotation.SuppressLint;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.utils.event.Event;

import java.util.List;


public class InfoTrackInfoReady extends Event {
    @Track.TrackType
    public int trackType;
    public List<Track> tracks;

    public InfoTrackInfoReady() {
        super(PlayerEvent.Info.TRACK_INFO_READY);
    }

    public InfoTrackInfoReady init(@Track.TrackType int trackType, List<Track> tracks) {
        this.trackType = trackType;
        this.tracks = tracks;
        return this;
    }

    @SuppressLint("WrongConstant")
    @Override
    public void recycle() {
        super.recycle();
        trackType = 0;
        tracks = null;
    }
}
