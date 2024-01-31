// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.data.page;

import java.util.List;


public class Page<T> {
    public static int TOTAL_INFINITY = -1;

    public List<T> list;
    public int index;
    public int total;
    public String playMode; // linear or loop

    public Page(List<T> list, int index, int total) {
        this.list = list;
        this.index = index;
        this.total = total;
    }

    public Page(List<T> list, String playMode) {
        this.list = list;
        this.playMode = playMode;
    }
}
