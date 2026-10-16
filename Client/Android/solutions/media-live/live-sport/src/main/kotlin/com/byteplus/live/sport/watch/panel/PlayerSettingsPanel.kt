// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.panel

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.widget.SwitchCompat
import com.byteplus.live.sport.R
import com.byteplus.live.sport.player.PullProtocolOption
import com.google.android.material.bottomsheet.BottomSheetDialog

/**
 * Bottom-sheet settings panel: pull protocol picker plus ABR /
 * super-resolution / sharpen toggles.
 *
 * Editing model — STAGED:
 *  - Opening the panel takes a snapshot of the current [State]; user changes
 *    only mutate this in-memory snapshot.
 *  - "Save" calls [Callback.onApply] once with the final values.
 *  - Closing the panel without saving (close button, scrim tap, back press)
 *    discards staged edits — nothing is committed to the player.
 *
 * The actual row binding + RTM/ABR gating logic lives in [PlayerSettingsBinder]
 * so the landscape side-panel (which renders the same content inside a slide
 * container) can reuse it without copy-pasting.
 */
class PlayerSettingsPanel(
    private val context: Context,
    private val callback: Callback,
) {

    interface Callback {
        /** Called once with the final staged values when the user taps Save. */
        fun onApply(result: PlayerSettingsBinder.Result)
    }

    fun show(state: PlayerSettingsBinder.State) {
        val view = LayoutInflater.from(context).inflate(R.layout.live_sport_panel_settings, null)
        val dialog = BottomSheetDialog(context)
        dialog.setContentView(view)

        PlayerSettingsBinder.bind(
            context = context,
            content = view,
            state = state,
            // Portrait picks the protocol via a child BottomSheet.
            protocolPicker = PlayerSettingsBinder.bottomSheetProtocolPicker(context),
            onClose = { dialog.dismiss() },
            onApply = {
                callback.onApply(it)
                dialog.dismiss()
            },
        )

        dialog.show()
    }
}

/**
 * Pure binding logic for the player-settings panel. Shared between the portrait
 * BottomSheet ([PlayerSettingsPanel]) and the landscape side-slide panel
 * ([com.byteplus.live.sport.fullscreen.LandscapePlayerSettingsPanel]).
 *
 * The same `live_sport_panel_settings` layout is inflated by both shells; this
 * binder owns the staged state and the RTM/ABR gating Toasts.
 */
object PlayerSettingsBinder {

    private const val DISABLED_ALPHA = 0.4f

    /**
     * Snapshot fed to [bind]. The binder never mutates the original instance —
     * it copies the values into mutable locals and only reports the final
     * staged state via the apply callback.
     */
    data class State(
        /** Currently active option (drives the row's value text + picker selection). */
        val protocol: PullProtocolOption,
        /** Whether the channel exposes an RTM URL; RTM option is disabled otherwise. */
        val rtmSupported: Boolean,
        /** Whether the channel carries multiple FLV tiers; ABR is greyed out otherwise. */
        val multiTierFlv: Boolean,
        val abrOn: Boolean,
        val srOn: Boolean,
        val sharpenOn: Boolean,
    )

    /** Final values committed when Save is tapped. */
    data class Result(
        val protocol: PullProtocolOption,
        val abrOn: Boolean,
        val srOn: Boolean,
        val sharpenOn: Boolean,
    )

    /**
     * Presents the protocol picker UI. The portrait shell injects a child
     * BottomSheet implementation; the landscape shell injects a right-side
     * slide panel. Given the currently-staged [selected] option, it presents
     * the picker and reports the user's choice via [onPicked].
     */
    fun interface ProtocolPicker {
        fun present(
            rtmSupported: Boolean,
            selected: PullProtocolOption,
            onPicked: (PullProtocolOption) -> Unit,
        )
    }

    /**
     * Wire the inflated `live_sport_panel_settings` view onto [state] and the
     * supplied close / apply callbacks.
     *
     * @param protocolPicker how the protocol picker is presented (BottomSheet
     *   for portrait, side panel for landscape).
     * @param onClose invoked when the user taps the close button.
     * @param onApply invoked when the user taps Save with the final result.
     */
    fun bind(
        context: Context,
        content: View,
        state: State,
        protocolPicker: ProtocolPicker,
        onClose: () -> Unit,
        onApply: (Result) -> Unit,
    ) {
        // Staged snapshot — all toggles mutate these locals, never the input.
        var protocol = state.protocol
        var abrOn = state.abrOn && state.multiTierFlv && protocol != PullProtocolOption.RTM
        var srOn = state.srOn
        var sharpenOn = state.sharpenOn

        val protocolValue = content.findViewById<TextView>(R.id.settings_protocol_value)
        val protocolRow = content.findViewById<LinearLayout>(R.id.settings_protocol_row)
        val abrRow = content.findViewById<LinearLayout>(R.id.settings_abr_row)
        val abrSwitch = content.findViewById<SwitchCompat>(R.id.switch_abr)
        val srSwitch = content.findViewById<SwitchCompat>(R.id.switch_sr)
        val sharpenSwitch = content.findViewById<SwitchCompat>(R.id.switch_sharpen)
        val closeBtn = content.findViewById<ImageButton>(R.id.btn_settings_close)
        val saveBtn = content.findViewById<TextView>(R.id.btn_settings_save)

        protocolValue.text = labelOf(context, protocol)

        // ABR row availability is a function of (protocol, multiTierFlv). We
        // recompute it whenever the protocol changes so the gating stays in
        // sync with the staged state.
        fun refreshAbrRow() {
            val abrAvailable = state.multiTierFlv && protocol != PullProtocolOption.RTM
            abrRow.alpha = if (abrAvailable) 1f else DISABLED_ALPHA
            abrSwitch.isEnabled = abrAvailable
        }
        refreshAbrRow()
        abrSwitch.isChecked = abrOn

        // ABR row click — defensive guard for RTM + ABR.
        abrRow.setOnClickListener {
            if (!state.multiTierFlv) return@setOnClickListener
            if (protocol == PullProtocolOption.RTM) {
                Toast.makeText(
                    context,
                    R.string.live_sport_watch_abr_unavailable_rtm,
                    Toast.LENGTH_SHORT,
                ).show()
                abrSwitch.isChecked = false
                return@setOnClickListener
            }
            abrOn = !abrOn
            abrSwitch.isChecked = abrOn
        }

        srSwitch.isChecked = srOn
        srSwitch.setOnCheckedChangeListener { _, checked -> srOn = checked }
        sharpenSwitch.isChecked = sharpenOn
        sharpenSwitch.setOnCheckedChangeListener { _, checked -> sharpenOn = checked }

        // Pull protocol row → injected picker (BottomSheet or side panel).
        protocolRow.setOnClickListener {
            protocolPicker.present(
                rtmSupported = state.rtmSupported,
                selected = protocol,
            ) { picked ->
                if (picked == protocol) return@present
                protocol = picked
                protocolValue.text = labelOf(context, protocol)
                if (protocol == PullProtocolOption.RTM && abrOn) {
                    abrOn = false
                    abrSwitch.isChecked = false
                    Toast.makeText(
                        context,
                        R.string.live_sport_watch_abr_unavailable_rtm,
                        Toast.LENGTH_SHORT,
                    ).show()
                }
                refreshAbrRow()
            }
        }

        closeBtn.setOnClickListener { onClose() }
        saveBtn.setOnClickListener {
            onApply(
                Result(
                    protocol = protocol,
                    abrOn = abrOn,
                    srOn = srOn,
                    sharpenOn = sharpenOn,
                )
            )
        }
    }

    private fun labelOf(context: Context, option: PullProtocolOption): String {
        val resId = labelResOf(option)
        return context.getString(resId)
    }

    private fun labelResOf(option: PullProtocolOption): Int = when (option) {
        PullProtocolOption.RTM -> R.string.live_sport_watch_protocol_rtm
        PullProtocolOption.FLV_LOW_LATENCY -> R.string.live_sport_watch_protocol_flv_ll
        PullProtocolOption.FLV_NORMAL -> R.string.live_sport_watch_protocol_flv_normal
    }

    /** Portrait protocol picker: a child BottomSheet over the settings sheet. */
    fun bottomSheetProtocolPicker(context: Context): ProtocolPicker =
        ProtocolPicker { rtmSupported, selected, onPicked ->
            val view = LayoutInflater.from(context)
                .inflate(R.layout.live_sport_panel_protocol_picker, null)
            val dialog = BottomSheetDialog(context)
            dialog.setContentView(view)

            val container = view.findViewById<LinearLayout>(R.id.protocol_picker_container)
            view.findViewById<ImageButton>(R.id.btn_protocol_picker_close)
                .setOnClickListener { dialog.dismiss() }

            populateProtocolRows(
                context = context,
                container = container,
                rtmSupported = rtmSupported,
                selected = selected,
            ) { picked ->
                onPicked(picked)
                dialog.dismiss()
            }

            dialog.show()
        }

    /**
     * Populate [container] with one `live_sport_panel_protocol_item` per
     * protocol option. Reused by both the portrait BottomSheet picker and the
     * landscape side-panel picker so the rows stay identical.
     */
    fun populateProtocolRows(
        context: Context,
        container: LinearLayout,
        rtmSupported: Boolean,
        selected: PullProtocolOption,
        onPicked: (PullProtocolOption) -> Unit,
    ) {
        container.removeAllViews()
        PullProtocolOption.entries.forEach { option ->
            val enabled = option != PullProtocolOption.RTM || rtmSupported
            container.addView(
                buildProtocolRow(
                    context = context,
                    parent = container,
                    option = option,
                    selected = selected,
                    enabled = enabled,
                ) { onPicked(option) }
            )
        }
    }

    private fun buildProtocolRow(
        context: Context,
        parent: ViewGroup,
        option: PullProtocolOption,
        selected: PullProtocolOption,
        enabled: Boolean,
        onClick: () -> Unit,
    ): View {
        val row = LayoutInflater.from(context)
            .inflate(R.layout.live_sport_panel_protocol_item, parent, false)

        val label = row.findViewById<TextView>(R.id.protocol_item_label)
        val subtitle = row.findViewById<TextView>(R.id.protocol_item_subtitle)
        val check = row.findViewById<ImageView>(R.id.protocol_item_check)

        label.setText(labelResOf(option))

        if (option == selected) {
            check.visibility = ImageView.VISIBLE
        }

        if (!enabled && option == PullProtocolOption.RTM) {
            subtitle.setText(R.string.live_sport_watch_protocol_rtm_unsupported)
            subtitle.visibility = TextView.VISIBLE
            row.alpha = DISABLED_ALPHA
            row.isClickable = false
        } else {
            row.setOnClickListener { onClick() }
        }

        return row
    }
}
