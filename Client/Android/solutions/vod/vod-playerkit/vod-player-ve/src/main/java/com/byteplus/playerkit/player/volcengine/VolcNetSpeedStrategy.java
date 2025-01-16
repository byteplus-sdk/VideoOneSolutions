// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import com.ss.ttvideoengine.strategy.StrategyManager;

public class VolcNetSpeedStrategy {

    static void init() {
        if (!VolcConfigGlobal.ENABLE_SPEED_TEST_STRATEGY_INIT) return;

        StrategyManager.instance().startSpeedPredictor();
    }
}
