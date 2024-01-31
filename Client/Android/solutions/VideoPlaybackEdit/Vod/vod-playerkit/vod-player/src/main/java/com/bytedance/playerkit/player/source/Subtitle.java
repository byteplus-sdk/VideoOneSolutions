/*
 * Copyright (C) 2023 bytedance
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Create Date : 2023/6/12
 */

package com.bytedance.playerkit.player.source;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.bytedance.playerkit.utils.L;
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
