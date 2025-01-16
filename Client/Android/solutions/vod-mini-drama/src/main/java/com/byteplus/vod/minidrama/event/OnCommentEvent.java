// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.event;

public class OnCommentEvent {
    public final String vid;
    public final boolean isLandscape;

    public OnCommentEvent(String vid, boolean isLandscape) {
        this.vid = vid;
        this.isLandscape = isLandscape;
    }

    public static OnCommentEvent landscape(String vid) {
        return new OnCommentEvent(vid, true);
    }

    public static OnCommentEvent portrait(String vid) {
        return new OnCommentEvent(vid, false);
    }
}
