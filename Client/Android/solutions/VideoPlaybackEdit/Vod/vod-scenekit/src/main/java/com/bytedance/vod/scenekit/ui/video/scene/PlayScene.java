// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene;


public class PlayScene {
    public static final int SCENE_UNKNOWN = 0;
    public static final int SCENE_SHORT = 1;
    public static final int SCENE_FEED = 2;
    public static final int SCENE_LONG = 3;
    public static final int SCENE_DETAIL = 4;
    public static final int SCENE_FULLSCREEN = 5;

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
            case SCENE_FULLSCREEN:
                return "fullscreen";
            case SCENE_UNKNOWN:
            default:
                return "unknown";
        }
    }
}
