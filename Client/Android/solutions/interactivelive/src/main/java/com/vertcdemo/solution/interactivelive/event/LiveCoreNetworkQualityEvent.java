// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.event;

import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.livestreamv2.Constants;

public class LiveCoreNetworkQualityEvent {
    public enum Quality {
        UNKNOWN, GOOD, POOR, BAD
    }

    public Quality quality;

    /**
     * @param networkQuality Network quality
     * @see Constants#MSG_REPORT_NETWORK_QUALITY
     */
    public LiveCoreNetworkQualityEvent(int networkQuality) {
        Quality quality;
        switch (networkQuality) {
            case Constants.NETWORK_QUALITY_GOOD:
                quality = Quality.GOOD;
                break;
            case Constants.NETWOKR_QUALITY_POOR:
                quality = Quality.POOR;
                break;
            case Constants.NETWORK_QUALITY_BAD:
                quality = Quality.BAD;
                break;
            case Constants.NETWORK_QUALITY_UNKNOWN:
            default:
                quality = Quality.UNKNOWN;
        }
        this.quality = quality;
    }

    public LiveCoreNetworkQualityEvent(VeLivePusherDef.VeLiveNetworkQuality networkQuality) {
        Quality quality;
        switch (networkQuality) {
            case VeLiveNetworkQualityGood:
                quality = Quality.GOOD;
                break;
            case VeLiveNetworkQualityPoor:
                quality = Quality.POOR;
                break;
            case VeLiveNetworkQualityBad:
                quality = Quality.BAD;
                break;
            case VeLiveNetworkQualityUnknown:
            default:
                quality = Quality.UNKNOWN;
        }
        this.quality = quality;
    }
}
