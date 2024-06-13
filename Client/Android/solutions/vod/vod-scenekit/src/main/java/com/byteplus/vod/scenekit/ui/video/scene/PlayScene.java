// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene;


public class PlayScene {
    public static final int SCENE_NONE = 0;
    public static final int SCENE_SHORT = 1;
    public static final int SCENE_FEED = 2;
    public static final int SCENE_LONG = 3;
    public static final int SCENE_DETAIL = 4;
    public static final int SCENE_SINGLE_FUNCTION = 5;
    public static final int SCENE_FULLSCREEN = 6;

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
