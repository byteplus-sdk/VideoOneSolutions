// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.core

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/** Tests the network transition decision helper. */
class NetworkMonitorTest {

    @Test
    fun no_network_to_has_network_returns_restored() {
        assertEquals(NetworkEvent.RESTORED, decideNetworkEvent(previous = false, current = true))
    }

    @Test
    fun has_network_to_no_network_returns_lost() {
        assertEquals(NetworkEvent.LOST, decideNetworkEvent(previous = true, current = false))
    }

    @Test
    fun no_change_returns_null() {
        assertNull(decideNetworkEvent(previous = true, current = true))
        assertNull(decideNetworkEvent(previous = false, current = false))
    }
}
