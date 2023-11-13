// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import com.vertcdemo.solution.interactivelive.event.AudienceLinkApplyEvent;

public class AudienceLinkRequest {

    public final AudienceLinkApplyEvent event;

    public AudienceLinkRequest(AudienceLinkApplyEvent event) {
        this.event = event;
    }

    public boolean sameUser(String userId) {
        return event.sameUser(userId);
    }

    public boolean sameUser(AudienceLinkApplyEvent other) {
       return event.sameUser(other.applicant.userId);
    }
}
