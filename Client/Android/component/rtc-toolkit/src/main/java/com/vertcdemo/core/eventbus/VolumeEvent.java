// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.eventbus;

import java.util.Map;

public class VolumeEvent {
    public Map<String, Integer> uidVolumeMap;

    public VolumeEvent(Map<String, Integer> uidVolumeMap) {
        this.uidVolumeMap = uidVolumeMap;
    }
}
