// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.content.Context;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.byteplus.vod.scenekit.utils.TimeUtils;


public class SyncStartTimeLayer extends BaseLayer {

    @Override
    public String tag() {
        return "sync_start_time";
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlaybackEvent.Action.STOP_PLAYBACK:
                    dismiss();
                    break;
                case PlayerEvent.State.PREPARED: {
                    VideoLayerHost layerHost = layerHost();
                    if (layerHost == null) return;
                    Context context = context();
                    if (context == null) return;

                    Player player = event.owner(Player.class);
                    if (player.getStartTime() > 1000) {
                        TipsLayer tipsLayer = layerHost.findLayer(TipsLayer.class);
                        if (tipsLayer != null) {
                            tipsLayer.show(context.getString(R.string.vevod_tips_sync_start_time,
                                    TimeUtils.time2String(player.getStartTime())));
                        }
                    }
                    break;
                }
            }
        }
    };
}
