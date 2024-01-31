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
 * Create Date : 2023/6/16
 */

package com.bytedance.playerkit.player.source;

import com.bytedance.playerkit.utils.L;
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
