// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.event;

import com.vertcdemo.core.eventbus.SkipLogging;

@SkipLogging
public class AudioStatsEvent {
    public int rtt;
    public float upload;
    public float download;

    public AudioStatsEvent(int rtt, float upload, float download) {
        this.rtt = rtt;
        this.upload = upload;
        this.download = download;
    }
}
