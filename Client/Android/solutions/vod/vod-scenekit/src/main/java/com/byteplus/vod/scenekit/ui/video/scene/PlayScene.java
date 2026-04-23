// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene;


import com.byteplus.playerkit.player.volcengine.VolcScene;

public class PlayScene {
    public static final int SCENE_NONE = VolcScene.SCENE_UNKNOWN;
    public static final int SCENE_SHORT = VolcScene.SCENE_SHORT_VIDEO;
    public static final int SCENE_FEED = VolcScene.SCENE_FEED_VIDEO;
    public static final int SCENE_LONG = VolcScene.SCENE_LONG_VIDEO;
    public static final int SCENE_DETAIL = VolcScene.SCENE_DETAIL_VIDEO;
    public static final int SCENE_FULLSCREEN = VolcScene.SCENE_FULLSCREEN;
    public static final int SCENE_SINGLE_FUNCTION = 6;

    public static String map(int scene) {
        switch (scene) {
            case SCENE_SHORT:
                return "short";
            case SCENE_FEED:
                return "feed";
            case SCENE_LONG:
                return "long";
            case SCENE_DETAIL:
                return "detail";
            case SCENE_SINGLE_FUNCTION:
                return "s-function";
            case SCENE_NONE:
            default:
                return "none";
        }
    }

    public static boolean isFullScreenMode(int scene) {
        return scene == SCENE_FULLSCREEN;
    }
}
