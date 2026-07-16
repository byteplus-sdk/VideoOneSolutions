// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import android.content.Context
import android.content.Intent
import androidx.annotation.Keep
import com.byteplus.live.sport.R
import com.byteplus.live.sport.entry.LiveSportHomeActivity
import com.byteplus.live.sport.player.SportLiveEnv

/**
 * Sports Live scene entry — adds a card to the home screen list.
 *
 * Discovered by reflection in [SceneEntry.entries] via fully-qualified class name.
 *
 * Why [Keep]: the class is referenced **only** by string in `SceneEntry.entryNames`.
 * Without `@Keep`, R8 in release builds will strip the class and the home entry
 * silently disappears (the reflection call is wrapped in try/catch).
 */
@Keep
class LiveSportEntry : ISceneEntry {
    override val title: Int
        get() = R.string.live_sport_title
    override val description: Int
        get() = R.string.live_sport_description
    override val background: Int
        get() = R.drawable.live_sport_bg_entry

    override fun startup(context: Context) {
        // Module entry point: initialise TTSDK as soon as the user enters the
        // sports scene, so the license is loaded before any pull stream plays.
        // Without this, playback fails with VeLivePlayerInvalidLicense (-1).
        // Idempotent, so re-entering the scene is safe.
        SportLiveEnv.ensureInitialized(context)
        context.startActivity(Intent(context, LiveSportHomeActivity::class.java))
    }
}
