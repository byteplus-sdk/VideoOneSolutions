// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.playerkit.player.source;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;

public class SubtitlePathInfo implements Serializable {

    @SerializedName("list")
    public List<Subtitle> list;
}
