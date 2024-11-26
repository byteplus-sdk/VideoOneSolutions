// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.google.gson.annotations.SerializedName;

/**
 * Connection state update event
 */
public class LinkMicStatusEvent {
    @SerializedName("linkmic_status")
    public int linkMicStatus;

    @Override
    public String toString() {
        return "LinkMicStatusEvent{" +
                "linkMicStatus=" + linkMicStatus +
                '}';
    }
}
