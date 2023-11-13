// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.ve;

import android.content.Context;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.bytedance.playerkit.player.AVPlayer;
import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.adapter.PlayerAdapter;
import com.bytedance.playerkit.player.source.MediaSource;

class VEPlayerFactory implements Player.Factory {
    private final Context mContext;

    VEPlayerFactory(Context context) {
        this.mContext = context.getApplicationContext();
    }

    @Override
    public Player create(@NonNull MediaSource source) {
        PlayerAdapter.Factory factory = new VEPlayer.Factory(mContext, source);
        return new AVPlayer(mContext, factory, Looper.getMainLooper());
    }
}
