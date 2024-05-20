// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.source;

import com.byteplus.playerkit.utils.L;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class SubtitleText implements Serializable {
    @SerializedName("pts")
    public long pts;
    @SerializedName("duration")
    public long duration;
    @SerializedName("info")
    public String text;

    @Override
    public String toString() {
        return "SubtitleText{" +
                "pts=" + pts +
                ", duration=" + duration +
                ", text='" + text + '\'' +
                '}';
    }

    public static String dump(SubtitleText text) {
        if (!L.ENABLE_LOG) return null;
        if (text == null) return null;

        return text.pts + " " + text.duration + " " + text.text;
    }
}
