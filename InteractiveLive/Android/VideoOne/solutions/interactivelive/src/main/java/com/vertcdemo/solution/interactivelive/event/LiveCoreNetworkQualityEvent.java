// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.ss.avframework.livestreamv2.Constants;

public class LiveCoreNetworkQualityEvent {

    /**
     * @see Constants#STATUS_STREAM_NORMAL_PUBLISH
     * @see Constants#STATUS_INTERACT_CLIENT_MIXER
     * @see Constants#STATUS_INTERACT_SERVER_MIXER
     */
    public final int status;

    /**
     * @see Constants#NETWORK_QUALITY_UNKNOWN
     * @see Constants#NETWORK_QUALITY_GOOD
     * @see Constants#NETWOKR_QUALITY_POOR
     * @see Constants#NETWORK_QUALITY_BAD
     */
    public final int networkQuality;

    /**
     * @param status         status
     * @param networkQuality Network quality
     * @see Constants#MSG_REPORT_NETWORK_QUALITY
     */
    public LiveCoreNetworkQualityEvent(int status, int networkQuality) {
        this.status = status;
        this.networkQuality = networkQuality;
    }
}
