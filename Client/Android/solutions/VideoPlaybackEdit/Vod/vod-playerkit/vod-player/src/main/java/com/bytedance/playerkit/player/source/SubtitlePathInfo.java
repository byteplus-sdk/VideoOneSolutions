package com.bytedance.playerkit.player.source;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;

public class SubtitlePathInfo implements Serializable {

    @SerializedName("list")
    public List<Subtitle> list;
}
