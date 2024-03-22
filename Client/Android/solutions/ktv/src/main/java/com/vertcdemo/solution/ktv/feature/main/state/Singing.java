// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.state;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.solution.ktv.bean.PickedSongInfo;

public class Singing {
    @NonNull
    public final SingState state;
    @Nullable
    public final PickedSongInfo song;

    public Singing(@NonNull SingState state) {
        this(state, null);
    }

    public Singing(@NonNull SingState state, @Nullable PickedSongInfo song) {
        this.state = state;
        this.song = song;
    }

    public static Singing IDLE = new Singing(SingState.IDLE);

    public static Singing EMPTY = new Singing(SingState.EMPTY);

    public static Singing singing(@NonNull PickedSongInfo song) {
        return new Singing(SingState.SINGING, song);
    }

    public static Singing wait(@NonNull PickedSongInfo song) {
        return new Singing(SingState.WAITING, song);
    }
}
