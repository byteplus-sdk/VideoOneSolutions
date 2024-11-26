// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.vertcdemo.solution.interactivelive.http.response.FinishRoomResponse;

public class RequestFinishLiveResultEvent {
    public final FinishRoomResponse response;

    public RequestFinishLiveResultEvent() {
        this(null);
    }

    public RequestFinishLiveResultEvent(FinishRoomResponse response) {
        this.response = response;
    }

    public boolean isSuccess() {
        return response != null;
    }
}
