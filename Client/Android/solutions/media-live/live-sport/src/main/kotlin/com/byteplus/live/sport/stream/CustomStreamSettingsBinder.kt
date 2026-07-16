// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.stream

import android.content.ClipboardManager
import android.content.Context
import android.view.View
import android.widget.CompoundButton
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.widget.SwitchCompat
import androidx.core.widget.doAfterTextChanged
import com.byteplus.live.sport.R

object CustomStreamSettingsBinder {

    data class State(
        val url: String = "",
        val lowLatencyFlv: Boolean = false,
        val srOn: Boolean = false,
        val sharpenOn: Boolean = false,
    )

    data class Result(
        val streamUrl: CustomStreamUrl,
        val lowLatencyFlv: Boolean,
        val srOn: Boolean,
        val sharpenOn: Boolean,
    )

    class Binding(
        private val context: Context,
        private val root: View,
        state: State,
    ) {
        private val urlInput = root.findViewById<EditText>(R.id.custom_stream_url_input)
        private val inputBox = root.findViewById<View>(R.id.custom_stream_input_box)
        private val errorText = root.findViewById<TextView>(R.id.custom_stream_url_error)
        private val clearBtn = root.findViewById<TextView>(R.id.custom_stream_clear)
        private val pasteBtn = root.findViewById<TextView>(R.id.custom_stream_paste)
        private val lowLatencyRow = root.findViewById<LinearLayout>(R.id.custom_stream_low_latency_row)
        private val lowLatencySwitch = root.findViewById<SwitchCompat>(R.id.custom_stream_low_latency_switch)
        private val srSwitch = root.findViewById<SwitchCompat>(R.id.custom_stream_sr_switch)
        private val sharpenSwitch = root.findViewById<SwitchCompat>(R.id.custom_stream_sharpen_switch)

        init {
            urlInput.setText(state.url)
            lowLatencySwitch.isChecked = state.lowLatencyFlv
            srSwitch.isChecked = state.srOn
            sharpenSwitch.isChecked = state.sharpenOn
            refreshLowLatencyVisibility()

            urlInput.doAfterTextChanged {
                hideError()
                refreshLowLatencyVisibility()
            }
            clearBtn.setOnClickListener { urlInput.setText("") }
            pasteBtn.setOnClickListener { pasteFromClipboard() }
            lowLatencyRow.setOnClickListener {
                if (lowLatencyRow.visibility == View.VISIBLE) {
                    lowLatencySwitch.isChecked = !lowLatencySwitch.isChecked
                }
            }
            srSwitch.setOnCheckedChangeListener { _: CompoundButton, _: Boolean -> }
            sharpenSwitch.setOnCheckedChangeListener { _: CompoundButton, _: Boolean -> }
        }

        fun validate(): Result? {
            val parsed = CustomStreamUrlParser.parse(urlInput.text?.toString().orEmpty())
            if (parsed == null) {
                showError()
                return null
            }
            return Result(
                streamUrl = parsed,
                lowLatencyFlv = parsed.format == CustomStreamFormat.FLV && lowLatencySwitch.isChecked,
                srOn = srSwitch.isChecked,
                sharpenOn = sharpenSwitch.isChecked,
            )
        }

        private fun pasteFromClipboard() {
            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val text = clipboard.primaryClip
                ?.takeIf { it.itemCount > 0 }
                ?.getItemAt(0)
                ?.coerceToText(context)
                ?.toString()
                .orEmpty()
            if (text.isNotEmpty()) {
                urlInput.setText(text)
                urlInput.setSelection(urlInput.text?.length ?: 0)
            }
        }

        private fun refreshLowLatencyVisibility() {
            val parsed = CustomStreamUrlParser.parse(urlInput.text?.toString().orEmpty())
            val isFlv = parsed?.format == CustomStreamFormat.FLV
            lowLatencyRow.visibility = if (isFlv) View.VISIBLE else View.GONE
            if (!isFlv) lowLatencySwitch.isChecked = false
        }

        private fun showError() {
            errorText.visibility = View.VISIBLE
            inputBox.setBackgroundResource(R.drawable.live_sport_custom_stream_input_bg_error)
        }

        private fun hideError() {
            errorText.visibility = View.GONE
            inputBox.setBackgroundResource(R.drawable.live_sport_custom_stream_input_bg)
        }
    }

    fun bind(context: Context, root: View, state: State): Binding =
        Binding(context, root, state)
}
