// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import androidx.annotation.Nullable;

import com.vertcdemo.solution.interactivelive.core.annotation.InviteReply;

/**
 * Notification of local notification invitation result
 */
public class InviteAudienceEvent {

    public final String userId;
    @InviteReply
    public final int reply;

    @Nullable
    public final String linkerId;

    public InviteAudienceEvent(String userId, @InviteReply int reply) {
        this(userId, reply, null);
    }

    public InviteAudienceEvent(String userId, @InviteReply int reply, @Nullable String linkerId) {
        this.userId = userId;
        this.reply = reply;
        this.linkerId = linkerId;
    }
}
