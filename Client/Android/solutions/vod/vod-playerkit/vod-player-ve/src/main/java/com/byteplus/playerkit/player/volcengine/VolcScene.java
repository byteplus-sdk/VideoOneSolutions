// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

public class VolcScene {
    public static final int SCENE_UNKNOWN = 0;
    public static final int SCENE_SHORT_VIDEO = 1;
    public static final int SCENE_FEED_VIDEO = 2;
    public static final int SCENE_LONG_VIDEO = 3;
    public static final int SCENE_DETAIL_VIDEO = 4;
    public static final int SCENE_FULLSCREEN = 5;

    public static String mapScene(int volcScene) {
        switch (volcScene) {
            case SCENE_SHORT_VIDEO:
                return "short";
            case SCENE_FEED_VIDEO:
                return "feed";
            case SCENE_DETAIL_VIDEO:
                return "detail";
            default:
            case SCENE_UNKNOWN:
                return "unknown";
        }
    }


}
