// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import android.content.Context;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.AVPlayer;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.adapter.PlayerAdapter;
import com.byteplus.playerkit.player.source.MediaSource;

class VolcPlayerFactory implements Player.Factory {
    private final Context mContext;

    VolcPlayerFactory(Context context) {
        this.mContext = context.getApplicationContext();
    }

    @Override
    public Player create(@NonNull MediaSource source) {
        PlayerAdapter.Factory factory = new VolcPlayer.Factory(mContext, source);
        return new AVPlayer(mContext, factory, Looper.getMainLooper());
    }
}
