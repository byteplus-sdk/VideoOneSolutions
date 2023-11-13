// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

public class PublishVideoStreamEvent {
    public final String uid;
    public final String roomId;

    public PublishVideoStreamEvent(String uid, String roomId) {
        this.roomId = roomId;
        this.uid = uid;
    }
}
