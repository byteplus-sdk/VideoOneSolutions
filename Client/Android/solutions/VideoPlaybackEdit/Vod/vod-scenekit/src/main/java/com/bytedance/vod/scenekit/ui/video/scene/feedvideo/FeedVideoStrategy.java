// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.feedvideo;

import com.bytedance.playerkit.player.ve.SceneFeed;
import com.bytedance.playerkit.player.ve.VEPlayerStatic;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.VideoSettings;

import java.util.List;

public class FeedVideoStrategy {

    public static void setEnabled(boolean enable) {
        if (!VideoSettings.booleanValue(VideoSettings.FEED_VIDEO_ENABLE_PRELOAD)) return;

        VEPlayerStatic.setSceneStrategyEnabled(SceneFeed.SCENE_FEED_VIDEO, enable);
    }

    public static void setItems(List<VideoItem> videoItems) {
        if (!VideoSettings.booleanValue(VideoSettings.FEED_VIDEO_ENABLE_PRELOAD)) return;

        if (videoItems == null) return;

        VEPlayerStatic.setMediaSources(VideoItem.toMediaSources(videoItems, true));
    }

    public static void appendItems(List<VideoItem> videoItems) {
        if (!VideoSettings.booleanValue(VideoSettings.FEED_VIDEO_ENABLE_PRELOAD)) return;

        if (videoItems == null) return;

        VEPlayerStatic.addMediaSources(VideoItem.toMediaSources(videoItems, true));
    }
}
