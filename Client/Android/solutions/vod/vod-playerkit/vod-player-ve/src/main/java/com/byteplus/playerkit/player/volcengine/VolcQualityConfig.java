// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import com.byteplus.playerkit.player.source.Quality;

import java.io.Serializable;

public class VolcQualityConfig implements Serializable {
    public boolean enableStartupABR;
    public Quality defaultQuality;
    public Quality wifiMaxQuality;
    public Quality mobileMaxQuality;
    public Quality userSelectedQuality;
    public VolcDisplaySizeConfig displaySizeConfig;
    public boolean enableSupperResolutionDowngrade;

    public static class VolcDisplaySizeConfig implements Serializable {
        public int screenWidth;
        public int screenHeight;
        public int displayWidth;
        public int displayHeight;
    }
}
