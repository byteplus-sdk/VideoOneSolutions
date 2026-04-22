// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.config;

import com.byteplus.playerkit.player.source.Quality;
import com.byteplus.playerkit.utils.L;

import java.io.Serializable;

public class ABRQualityConfig implements Serializable {
    public int screenWidth;
    public int screenHeight;
    public int displayWidth;
    public int displayHeight;

    public Quality defaultQuality;
    public Quality wifiMaxQuality;
    public Quality mobileMaxQuality;

    public String dump() {
        return L.obj2String(this) + " Screen(" + screenWidth + "x" + screenHeight + ")" + " Display(" + displayWidth + "x" + displayHeight + ")" + " default=" + Quality.dump(defaultQuality, false) + " wifiMax=" + Quality.dump(wifiMaxQuality, false) + " mobileMax=" + Quality.dump(mobileMaxQuality, false);
    }

    public static String dump(ABRQualityConfig config) {
        if (!L.ENABLE_LOG) return null;
        if (config == null) return null;
        return config.dump();
    }
}
