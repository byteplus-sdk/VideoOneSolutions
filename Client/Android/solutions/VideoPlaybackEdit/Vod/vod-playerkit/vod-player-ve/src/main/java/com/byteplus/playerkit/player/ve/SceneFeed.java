// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.ve;

public class SceneFeed {

    public static final int SCENE_UNKNOWN = 0;
    public static final int SCENE_SHORT_VIDEO = 1;
    public static final int SCENE_FEED_VIDEO = 2;

    public static String mapScene(int scene) {
        switch (scene) {
            case SCENE_SHORT_VIDEO:
                return "short";
            case SCENE_FEED_VIDEO:
                return "feed";
            default:
            case SCENE_UNKNOWN:
                return "unknown";
        }
    }
}
