// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import com.byteplus.playerkit.player.source.MediaSource;

public interface VolcConfigUpdater {
    void updateVolcConfig(MediaSource mediaSource);

    VolcConfigUpdater DEFAULT = new VolcConfigUpdater() {
        @Override
        public void updateVolcConfig(MediaSource mediaSource) {

        }
    };
}