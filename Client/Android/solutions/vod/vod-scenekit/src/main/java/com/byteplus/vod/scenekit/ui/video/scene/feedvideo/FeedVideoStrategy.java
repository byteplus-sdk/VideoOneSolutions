// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.feedvideo;

import com.byteplus.playerkit.player.ve.SceneFeed;
import com.byteplus.playerkit.player.ve.VEPlayerStatic;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;

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
