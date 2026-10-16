// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import android.widget.LinearLayout
import com.byteplus.live.sport.R
import com.byteplus.live.sport.watch.panel.PlayerSettingsBinder

/**
 * Landscape (right-side slide) settings panel. Reuses the portrait
 * `live_sport_panel_settings` layout verbatim so all rows stay pixel-identical
 * to the BottomSheet variant; only the card background is swapped to a
 * left-rounded full-height variant since it docks to the right edge.
 *
 * The protocol picker is presented as its own narrower white side panel
 * (instead of the portrait child BottomSheet) so the whole flow stays
 * immersive in landscape.
 */
class LandscapePlayerSettingsPanel(
    private val hostActivity: Activity,
    private val state: PlayerSettingsBinder.State,
    private val onApply: (PlayerSettingsBinder.Result) -> Unit,
) : LandscapeSidePanel(
    activity = hostActivity,
    widthPx = (hostActivity.resources.displayMetrics.density * PANEL_WIDTH_DP).toInt(),
) {

    override fun onCreateContent(inflater: LayoutInflater): View {
        val card = inflater.inflate(R.layout.live_sport_panel_settings, null, false)
        // Right-docked card → left-rounded corners + full height.
        card.setBackgroundResource(R.drawable.live_sport_landscape_settings_panel_bg)
        card.layoutParams = android.view.ViewGroup.LayoutParams(
            android.view.ViewGroup.LayoutParams.MATCH_PARENT,
            android.view.ViewGroup.LayoutParams.MATCH_PARENT,
        )
        return card
    }

    override fun onBind(content: View) {
        PlayerSettingsBinder.bind(
            context = content.context,
            content = content,
            state = state,
            protocolPicker = { rtmSupported, selected, onPicked ->
                ProtocolSidePanel(hostActivity, rtmSupported, selected, onPicked).show()
            },
            onClose = { dismiss() },
            onApply = {
                onApply(it)
                dismiss()
            },
        )
    }

    /** Narrow right-side slide panel that hosts the protocol option rows. */
    private class ProtocolSidePanel(
        activity: Activity,
        private val rtmSupported: Boolean,
        private val selected: com.byteplus.live.sport.player.PullProtocolOption,
        private val onPicked: (com.byteplus.live.sport.player.PullProtocolOption) -> Unit,
    ) : LandscapeSidePanel(
        activity = activity,
        widthPx = (activity.resources.displayMetrics.density * PICKER_WIDTH_DP).toInt(),
    ) {
        override fun onCreateContent(inflater: LayoutInflater): View {
            val view = inflater.inflate(R.layout.live_sport_panel_protocol_picker, null, false)
            view.setBackgroundResource(R.drawable.live_sport_landscape_settings_panel_bg)
            view.layoutParams = android.view.ViewGroup.LayoutParams(
                android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                android.view.ViewGroup.LayoutParams.MATCH_PARENT,
            )
            return view
        }

        override fun onBind(content: View) {
            val container = content.findViewById<LinearLayout>(R.id.protocol_picker_container)
            content.findViewById<ImageButton>(R.id.btn_protocol_picker_close)
                .setOnClickListener { dismiss() }
            PlayerSettingsBinder.populateProtocolRows(
                context = content.context,
                container = container,
                rtmSupported = rtmSupported,
                selected = selected,
            ) { picked ->
                onPicked(picked)
                dismiss()
            }
        }

        private companion object {
            const val PICKER_WIDTH_DP = 280f
        }
    }

    private companion object {
        const val PANEL_WIDTH_DP = 360f
    }
}
