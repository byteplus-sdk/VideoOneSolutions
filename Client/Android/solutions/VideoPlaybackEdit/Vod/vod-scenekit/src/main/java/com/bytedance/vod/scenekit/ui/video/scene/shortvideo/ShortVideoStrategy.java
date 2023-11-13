// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.shortvideo;

import com.bytedance.playerkit.player.playback.DisplayModeHelper;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.player.ve.SceneFeed;
import com.bytedance.playerkit.player.ve.VEPlayerStatic;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.VideoSettings;

import java.util.List;

public class ShortVideoStrategy {

    public static void setEnabled(boolean enable) {
        if (!VideoSettings.booleanValue(VideoSettings.SHORT_VIDEO_ENABLE_STRATEGY)) return;

        VEPlayerStatic.setSceneStrategyEnabled(SceneFeed.SCENE_SHORT_VIDEO, enable);
    }

    public static void setItems(List<VideoItem> videoItems) {
        if (!VideoSettings.booleanValue(VideoSettings.SHORT_VIDEO_ENABLE_STRATEGY)) return;

        if (videoItems == null) return;

        VEPlayerStatic.setMediaSources(VideoItem.toMediaSources(videoItems, false));
    }

    public static void appendItems(List<VideoItem> videoItems) {
        if (!VideoSettings.booleanValue(VideoSettings.SHORT_VIDEO_ENABLE_STRATEGY)) return;

        if (videoItems == null) return;

        VEPlayerStatic.addMediaSources(VideoItem.toMediaSources(videoItems, false));
    }

    public static boolean renderFrame(VideoView videoView) {
        if (!VideoSettings.booleanValue(VideoSettings.SHORT_VIDEO_ENABLE_STRATEGY)) return false;
        if (videoView == null) return false;

        int[] frameInfo = new int[2];
        VEPlayerStatic.renderFrame(videoView.getDataSource(), videoView.getSurface(), frameInfo);
        int videoWidth = frameInfo[0];
        int videoHeight = frameInfo[1];
        if (videoWidth > 0 && videoHeight > 0) {
            videoView.setDisplayAspectRatio(DisplayModeHelper.calDisplayAspectRatio(videoWidth, videoHeight, 0));
            return true;
        }
        return false;
    }
}
