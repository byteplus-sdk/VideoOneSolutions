// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.event;

import com.ss.bytertc.engine.type.NetworkQualityStats;

public class RTCNetworkQualityEvent {
    public final NetworkQualityStats localQuality;
    public final NetworkQualityStats[] remoteQualities;

    public RTCNetworkQualityEvent(NetworkQualityStats localQuality, NetworkQualityStats[] remoteQualities) {
        this.localQuality = localQuality;
        this.remoteQualities = remoteQualities;
    }
}
