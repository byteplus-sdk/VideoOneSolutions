// Copyright (c) 2026 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.playback;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class FirstFrameMonitorTest {

    @Test
    public void calculateMetrics_returnsExpectedSegments() {
        FirstFrameMonitor.Metrics metrics = FirstFrameMonitor.calculateMetrics(
                100,
                120,
                150,
                180,
                300);

        assertEquals(200, metrics.requestToFirstFrameMs);
        assertEquals(180, metrics.startToFirstFrameMs);
        assertEquals(150, metrics.prepareToFirstFrameMs);
        assertEquals(30, metrics.uiToPrepareMs);
        assertTrue(metrics.preRenderHit);
    }

    @Test
    public void calculateMetrics_returnsMissingForAbsentStages() {
        FirstFrameMonitor.Metrics metrics = FirstFrameMonitor.calculateMetrics(
                100,
                0,
                0,
                0,
                300);

        assertEquals(200, metrics.requestToFirstFrameMs);
        assertEquals(-1, metrics.startToFirstFrameMs);
        assertEquals(-1, metrics.prepareToFirstFrameMs);
        assertEquals(-1, metrics.uiToPrepareMs);
        assertFalse(metrics.preRenderHit);
    }
}
