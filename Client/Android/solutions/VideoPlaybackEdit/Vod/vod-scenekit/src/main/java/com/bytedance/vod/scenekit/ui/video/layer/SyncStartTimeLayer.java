// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.PlaybackEvent;
import com.bytedance.playerkit.player.playback.VideoLayerHost;

import com.bytedance.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.bytedance.vod.scenekit.utils.TimeUtils;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.R;


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
