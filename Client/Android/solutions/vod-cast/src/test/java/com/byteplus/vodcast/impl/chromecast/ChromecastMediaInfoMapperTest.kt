// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodcast.impl.chromecast

import com.byteplus.vodcast.api.LoadOptions
import com.byteplus.vodcast.api.LocalPlayerHook
import com.byteplus.vodcast.api.MediaItem
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Covers the load parameter priority rules used by the ChromeCast mapper.
 *
 * Note: [ChromecastMediaInfoMapper.adapt] builds GMS `MediaInfo` / `MediaLoadOptions`
 * directly and depends on Android `Uri` / `Bundle`, so JVM tests verify the pure
 * function [resolveLoadParams] instead.
 */
class ChromecastMediaInfoMapperTest {

    private fun item(
        startPositionMs: Long = 0L,
        speed: Float = 1f,
        autoplay: Boolean = true,
    ): MediaItem = MediaItem(
        contentUrl = "https://example.com/x.m3u8",
        startPositionMs = startPositionMs,
        speed = speed,
        autoplay = autoplay,
    )

    private class FakeHook(
        private val completed: Boolean = false,
        private val speed: Float = 1f,
    ) : LocalPlayerHook {
        override fun currentLocalPositionMs(): Long = 0L
        override fun isLocalCompleted(): Boolean = completed
        override fun currentLocalSpeed(): Float = speed
    }

    @Test
    fun b7_local_completed_forces_position_zero_and_autoplay_true() {
        val r = resolveLoadParams(
            item = item(startPositionMs = 99_999L, autoplay = false),
            options = LoadOptions(autoplay = false, playPositionMs = 50_000L),
            hook = FakeHook(completed = true),
        )
        assertEquals(0L, r.positionMs)
        assertTrue("Completed local playback should force autoplay=true", r.autoplay)
    }

    @Test
    fun b2_options_position_takes_priority_over_item_start() {
        val r = resolveLoadParams(
            item = item(startPositionMs = 1_000L),
            options = LoadOptions(playPositionMs = 5_000L),
            hook = null,
        )
        assertEquals(5_000L, r.positionMs)
    }

    @Test
    fun b2_item_start_used_when_options_zero() {
        val r = resolveLoadParams(
            item = item(startPositionMs = 1_234L),
            options = LoadOptions(playPositionMs = 0L),
            hook = null,
        )
        assertEquals(1_234L, r.positionMs)
    }

    @Test
    fun b2_zero_when_neither_provided() {
        val r = resolveLoadParams(item(), LoadOptions(), null)
        assertEquals(0L, r.positionMs)
    }

    @Test
    fun b6_speed_priority_options_over_item_over_hook() {
        // options take highest priority
        val r1 = resolveLoadParams(
            item = item(speed = 1.5f),
            options = LoadOptions(speed = 2.0f),
            hook = FakeHook(speed = 0.75f),
        )
        assertEquals(2.0f, r1.speed)

        // item values are used next
        val r2 = resolveLoadParams(
            item = item(speed = 1.5f),
            options = LoadOptions(speed = 1f),
            hook = FakeHook(speed = 0.75f),
        )
        assertEquals(1.5f, r2.speed)

        // hook values are the fallback
        val r3 = resolveLoadParams(
            item = item(speed = 1f),
            options = LoadOptions(speed = 1f),
            hook = FakeHook(speed = 0.75f),
        )
        assertEquals(0.75f, r3.speed)
    }

    @Test
    fun b6_default_speed_when_nothing_specified() {
        val r = resolveLoadParams(item(speed = 1f), LoadOptions(speed = 1f), null)
        assertEquals(1f, r.speed)
    }

    @Test
    fun autoplay_falls_back_to_options_and_item_when_not_completed() {
        val both = resolveLoadParams(
            item(autoplay = true), LoadOptions(autoplay = true), null,
        )
        assertTrue(both.autoplay)

        val itemFalse = resolveLoadParams(
            item(autoplay = false), LoadOptions(autoplay = true), null,
        )
        assertEquals(false, itemFalse.autoplay)

        val optsFalse = resolveLoadParams(
            item(autoplay = true), LoadOptions(autoplay = false), null,
        )
        assertEquals(false, optsFalse.autoplay)
    }
}
