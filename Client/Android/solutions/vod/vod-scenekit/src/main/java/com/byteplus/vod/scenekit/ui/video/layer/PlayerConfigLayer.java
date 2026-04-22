// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoLayer;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.strategy.VideoQuality;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

public class PlayerConfigLayer extends VideoLayer {
    @Nullable
    @Override
    public String tag() {
        return "player_config";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        return null;
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(eventListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(eventListener);
    }

    final Dispatcher.EventListener eventListener = event -> {
        switch (event.code()) {
            case PlaybackEvent.State.BIND_PLAYER:
                VideoView videoView = videoView();
                if (videoView == null) return;
                syncConfigByScene(videoView.getPlayScene());
                break;
        }
    };

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        syncConfigByScene(toScene);
    }

    private void syncConfigByScene(int scene) {
        final Player player = player();
        if (player == null) return;
        if (scene == PlayScene.SCENE_FULLSCREEN) {
            player.setLooping(false);
        } else if (scene == PlayScene.SCENE_SHORT) {
            player.setLooping(VideoSettings.intValue(VideoSettings.SHORT_VIDEO_PLAYBACK_COMPLETE_ACTION) == 0 /* 0 循环播放 */);
        }
        if (VideoSettings.intValue(VideoSettings.QUALITY_ENABLE_ABR) == VideoSettings.ABRType.ABR_TYPE_ABR) {
            player.setABRQualityConfig(VideoQuality.sceneABRQualityConfig(scene));
        }
    }
}
