// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.selector.model;

public class IndexItem {
    public final int index;
    public boolean locked;
    public boolean playing;

    public IndexItem(int index) {
        this(index, false, false);
    }

    public IndexItem(int index, boolean locked, boolean playing) {
        this.index = index;
        this.locked = locked;
        this.playing = playing;
    }
}
