// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.videoone.rn

import android.content.Context
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider
import com.google.android.gms.cast.framework.media.CastMediaOptions
import com.google.android.gms.cast.framework.media.NotificationOptions

/**
 * Google Cast options provider.
 *
 * - APP_ID: "CC1AD845" is Google's default media receiver (no custom receiver needed).
 *   Replace with your own Cast App ID if you register a custom receiver in the future.
 *
 * - NotificationOptions: shows a media notification while casting so the user can
 *   control playback from the notification shade without returning to the app.
 */
class CastOptionsProvider : OptionsProvider {

    override fun getCastOptions(context: Context): CastOptions {
        // Build a persistent notification for the cast session
        val notificationOptions = NotificationOptions.Builder()
            .setTargetActivityClassName(MainActivity::class.java.name)
            .build()

        val mediaOptions = CastMediaOptions.Builder()
            .setNotificationOptions(notificationOptions)
            .build()

        return CastOptions.Builder()
            // Default Google Cast receiver — works out-of-the-box, no registration needed.
            .setReceiverApplicationId(CAST_APP_ID)
            .setCastMediaOptions(mediaOptions)
            .build()
    }

    override fun getAdditionalSessionProviders(context: Context): List<SessionProvider>? = null

    companion object {
        /** Default Google Cast receiver App ID. */
        const val CAST_APP_ID = "CC1AD845"
    }
}
