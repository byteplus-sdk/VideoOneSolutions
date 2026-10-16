// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

public class PublishVideoStreamEvent {
    public final String userId;
    public final String streamId;
    public final String roomId;

    public PublishVideoStreamEvent(String userId, String streamId, String roomId) {
        this.roomId = roomId;
        this.userId = userId;
        this.streamId = streamId;
    }
}
