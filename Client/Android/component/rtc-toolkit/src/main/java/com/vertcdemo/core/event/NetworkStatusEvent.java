// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.event;

import androidx.annotation.NonNull;

import com.ss.bytertc.engine.type.NetworkQuality;

import java.util.Map;

/**
 * 网络状态状态(良好、卡顿)事件
 */
public class NetworkStatusEvent {

    public enum Quality {
        UNKNOWN, GOOD, POOR, BAD
    }

    private final Map<String, Integer> quality;

    public NetworkStatusEvent(@NonNull Map<String, Integer> quality) {
        this.quality = quality;
    }

    public Quality get(String userId) {
        Integer quality = this.quality.get(userId);
        if (quality == null) {
            return Quality.UNKNOWN;
        } else {
            switch (quality) {
                case NetworkQuality.NETWORK_QUALITY_EXCELLENT:
                case NetworkQuality.NETWORK_QUALITY_GOOD:
                    return Quality.GOOD;

                case NetworkQuality.NETWORK_QUALITY_POOR:
                case NetworkQuality.NETWORK_QUALITY_BAD:
                    return Quality.POOR;

                case NetworkQuality.NETWORK_QUALITY_VERY_BAD:
                case NetworkQuality.NETWORK_QUALITY_DOWN:
                    return Quality.BAD;

                default:
                    return Quality.UNKNOWN;
            }
        }
    }
}
