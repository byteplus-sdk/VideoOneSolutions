// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

/**
 * Local disconnect Audience
 */
public class AudienceLinkKickResultEvent {

    public String userId;

    public AudienceLinkKickResultEvent(String userId) {
        this.userId = userId;
    }
}
