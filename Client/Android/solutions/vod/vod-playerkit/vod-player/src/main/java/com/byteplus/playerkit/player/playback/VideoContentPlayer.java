// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.playback;

import static com.byteplus.playerkit.utils.event.Dispatcher.EventListener;

import com.byteplus.mediaplus.mediaads.api.ContentPlayer;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.playerkit.player.PlayerEvent;


import java.lang.ref.WeakReference;

import com.byteplus.playerkit.player.PlayerEvent;


public class VideoContentPlayer implements ContentPlayer {
    private final Player mPlayer;
    private Listener mListener = null;
    private boolean mCompleted = false;

    // @Keep
    public static class Factory implements ContentPlayer.Factory {

        @Override
        public ContentPlayer create(Object player) {
            if (player instanceof Player) {
                return new VideoContentPlayer((Player) player);
            }
            return null;
        }
    }

    private static final class PlayerListener implements EventListener {

        private final WeakReference<VideoContentPlayer> vcpRef;

        PlayerListener(VideoContentPlayer vcp) {
            vcpRef = new WeakReference<>(vcp);
        }

        @Override
        public void onEvent(Event event) {
            final VideoContentPlayer vcp = vcpRef.get();

            if (vcp != null && vcp.mListener != null) {

                if (event.code() == PlayerEvent.State.COMPLETED) {
                    if (!vcp.isLooping()) {
                        vcp.mCompleted = true;
                    }
                    vcp.mListener.onCompletion();
                } else if (event.code() == PlayerEvent.State.ERROR) {
                    vcp.mListener.onError(event.code(), "Error");
                }
            }
        }
    }

    public VideoContentPlayer(Player player) {
        this.mPlayer = player;
        this.mPlayer.addPlayerListener(new PlayerListener(this));
    }


    @Override
    public void setListener(Listener listener) {
        mListener = listener;
    }

    @Override
    public void play() {
        mCompleted = false;
        mPlayer.start();
    }

    @Override
    public void pause() {
        L.d(this, "pause");
        if (!mPlayer.isIDLE() && !mPlayer.isPreparing()) {
            mPlayer.pause();
        }
    }

    @Override
    public void release() {
        L.d(this, "release");
        mCompleted = false;
        mPlayer.setSurface(null);
        mPlayer.release();
    }

    @Override
    public long getCurrentPosition() {
        return mPlayer.getCurrentPosition();
    }

    @Override
    public long getDuration() {
        return mPlayer.getDuration();
    }

    @Override
    public boolean isCompleted() {
        return mCompleted;
    }

    @Override
    public boolean isLooping() {
        return mPlayer.isLooping();
    }

    @Override
    public void recordLog(String log) {
        L.d(this, "recordLog", log);
    }
}
