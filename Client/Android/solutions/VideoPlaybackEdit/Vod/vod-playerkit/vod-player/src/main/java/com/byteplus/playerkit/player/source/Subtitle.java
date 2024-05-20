// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.source;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.utils.L;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;
import java.util.Locale;

public class Subtitle implements Serializable {

    @SerializedName("id")
    public int index;
    @SerializedName("sub_id")
    public int subtitleId;
    @SerializedName("language")
    public String language;
    @SerializedName("language_id")
    public int languageId;
    @SerializedName("url")
    public String url;
    @SerializedName("format")
    public String format;
    @SerializedName("sub_desc")
    public String subtitleDesc;
    @SerializedName("source")
    public String source;

    public String dump() {
        return String.format(Locale.getDefault(), "[%s %s]", L.obj2String(this), TextUtils.isEmpty(subtitleDesc) ? language : subtitleDesc);
    }

    @Nullable
    public static String dump(Subtitle subtitle) {
        if (!L.ENABLE_LOG) return null;
        if (subtitle == null) return null;

        return subtitle.dump();
    }

    @Nullable
    public static String dump(List<Subtitle> subtitles) {
        StringBuilder sb = new StringBuilder();
        for (Subtitle subtitle : subtitles) {
            sb.append(subtitle.dump()).append(", ");
        }
        return sb.toString();
    }
}
