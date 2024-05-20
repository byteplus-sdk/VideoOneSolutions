// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.source;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.List;

/**
 * Preload or playback track selector
 */
public interface TrackSelector {

    int TYPE_PLAY = 0;
    int TYPE_PRELOAD = 1;

    /**
     * Select situation type. One of
     * {@link #TYPE_PLAY},
     * {@link #TYPE_PRELOAD}
     */
    @Documented
    @Retention(RetentionPolicy.SOURCE)
    @IntDef({TYPE_PLAY, TYPE_PRELOAD})
    @interface Type {
    }

    /**
     * Default implements of {@link TrackSelector}. Return first track in {@code tracks}.
     */
    TrackSelector DEFAULT = (type, trackType, tracks, source) -> tracks.get(0);

    /**
     * Select track for preload or playback
     *
     * @param type      Select situation type. One of {@link Type}
     * @param trackType Select track type. One of {@link Track.TrackType}
     * @param tracks    List of tracks to be selected
     * @return Selected track in tracks.
     */
    @NonNull
    Track selectTrack(@Type int type, @Track.TrackType int trackType, @NonNull List<Track> tracks, @NonNull MediaSource source);
}
