// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.utils;

import static com.byteplus.vod.minidrama.utils.VideoItemHelper.filter;

import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.volcengine.VolcEngineStrategy;
import com.byteplus.playerkit.player.volcengine.VolcScene;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.ss.ttvideoengine.strategy.StrategyManager;
import com.ss.ttvideoengine.strategy.preload.StrategyPreloadConfig;

import java.util.List;

public class MiniDramaVideoStrategy {
    private static final int DETAIL_PRELOAD_COUNT = 5;
    private static final int DETAIL_PRELOAD_SIZE_KB = 500;

    public static void setEnabled(boolean enable) {
        if (enable) {
            // 扩大后续集覆盖到 5 × 500 KiB，不改变预渲染播放器数量。
            // Cover 5 upcoming episodes at 500 KiB each without changing the pre-render player count.
            StrategyPreloadConfig config = new StrategyPreloadConfig.Builder()
                    .setCount(DETAIL_PRELOAD_COUNT)
                    .setSize(DETAIL_PRELOAD_SIZE_KB)
                    .build();
            StrategyManager.instance().setCustomPreloadConfig(config);
        }
        VolcEngineStrategy.setEnabled(VolcScene.SCENE_SHORT_VIDEO, enable);
        if (!enable) {
            // 自定义配置为 SDK 全局配置，退出详情页策略时恢复默认值。
            // The custom config is global to the SDK; restore defaults when disabling the detail strategy.
            StrategyManager.instance().setCustomPreloadConfig(
                    new StrategyPreloadConfig.Builder().build());
        }
    }

    public static void setItems(List<VideoItem> videoItems) {
        VolcEngineStrategy.setMediaSources(VideoItem.toMediaSources(filter(videoItems, VideoItem::playable), false));
    }

    public static void appendItems(List<VideoItem> videoItems) {
        VolcEngineStrategy.addMediaSources(VideoItem.toMediaSources(filter(videoItems, VideoItem::playable), false));
    }


    public static boolean renderFrame(VideoView videoView) {
        if (videoView == null) return false;

        int[] frameInfo = new int[2];
        VolcEngineStrategy.renderFrame(videoView.getDataSource(), videoView.getSurface(), frameInfo);
        int videoWidth = frameInfo[0];
        int videoHeight = frameInfo[1];
        if (videoWidth > 0 && videoHeight > 0) {
            videoView.setDisplayAspectRatio(DisplayModeHelper.calDisplayAspectRatio(videoWidth, videoHeight, 0));
            return true;
        }
        return false;
    }
}
