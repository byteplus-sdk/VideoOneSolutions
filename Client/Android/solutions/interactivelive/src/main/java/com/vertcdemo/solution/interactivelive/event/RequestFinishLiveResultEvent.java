// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.vertcdemo.solution.interactivelive.bean.LiveFinishResponse;

public class RequestFinishLiveResultEvent {
    public final LiveFinishResponse response;

    public RequestFinishLiveResultEvent() {
        this(null);
    }

    public RequestFinishLiveResultEvent(LiveFinishResponse response) {
        this.response = response;
    }

    public boolean isSuccess() {
        return response != null;
    }
}
