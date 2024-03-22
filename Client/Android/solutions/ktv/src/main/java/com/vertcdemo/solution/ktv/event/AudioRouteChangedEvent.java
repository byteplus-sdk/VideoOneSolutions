// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.ss.bytertc.engine.data.AudioRoute;

/**
 * RTC 用户拔去有线耳机事件
 */
public class AudioRouteChangedEvent {
    public final AudioRoute route;

    public AudioRouteChangedEvent(AudioRoute route) {
        this.route = route;
    }

    public boolean canOpenEarMonitor() {
        return canOpenEarMonitor(this.route);
    }

    public static boolean canOpenEarMonitor(AudioRoute route) {
        return route == AudioRoute.AUDIO_ROUTE_HEADSET
                || route == AudioRoute.AUDIO_ROUTE_HEADSET_USB;
    }
}
