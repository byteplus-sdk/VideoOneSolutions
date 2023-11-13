// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.eventbus;

public class SDKJoinChannelSuccessEvent {
    public String channelId;
    public String userId;

    public SDKJoinChannelSuccessEvent(String channelId, String userId) {
        this.channelId = channelId;
        this.userId = userId;
    }
}
