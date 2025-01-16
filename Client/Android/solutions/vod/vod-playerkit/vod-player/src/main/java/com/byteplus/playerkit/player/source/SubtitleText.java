// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.source;

import com.byteplus.playerkit.utils.L;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class SubtitleText implements Serializable {
    @SerializedName("pts")
    private long pts;
    @SerializedName("duration")
    private long duration;
    @SerializedName(value = "text", alternate = {"info"})
    private String text;

    public long getPts() {
        return pts;
    }

    public void setPts(long pts) {
        this.pts = pts;
    }

    public long getDuration() {
        return duration;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

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
