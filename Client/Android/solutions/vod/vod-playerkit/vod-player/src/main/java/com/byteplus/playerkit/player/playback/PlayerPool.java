// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.source.MediaSource;

public interface PlayerPool {

    PlayerPool DEFAULT = new DefaultPlayerPool();

    @NonNull
    Player acquire(@NonNull MediaSource source, Player.Factory factory);

    Player get(@NonNull MediaSource source);

    void recycle(@NonNull Player player);
}
