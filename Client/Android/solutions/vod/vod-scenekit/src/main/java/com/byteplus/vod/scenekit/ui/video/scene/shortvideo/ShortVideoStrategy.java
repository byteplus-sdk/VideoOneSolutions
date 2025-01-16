// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.shortvideo;

import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.volcengine.VolcEngineStrategy;
import com.byteplus.playerkit.player.volcengine.VolcScene;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.util.List;

public class ShortVideoStrategy {

    public static void setEnabled(boolean enable) {
        VolcEngineStrategy.setEnabled(VolcScene.SCENE_SHORT_VIDEO, enable);
    }

    public static void setItems(List<VideoItem> videoItems) {
        VolcEngineStrategy.setMediaSources(VideoItem.toMediaSources(videoItems, false));
    }

    public static void appendItems(List<VideoItem> videoItems) {
        VolcEngineStrategy.addMediaSources(VideoItem.toMediaSources(videoItems, false));
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
