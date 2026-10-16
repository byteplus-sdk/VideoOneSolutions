// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.stream

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageButton
import android.widget.TextView
import com.byteplus.live.sport.R
import com.google.android.material.bottomsheet.BottomSheetDialog

class CustomStreamSettingsPanel(
    private val context: Context,
    private val state: CustomStreamSettingsBinder.State,
    private val onApply: (CustomStreamSettingsBinder.Result) -> Unit,
) {

    fun show() {
        val view = LayoutInflater.from(context)
            .inflate(R.layout.live_sport_panel_custom_stream_settings, null)
        val dialog = BottomSheetDialog(context)
        dialog.setContentView(view)

        val binding = CustomStreamSettingsBinder.bind(
            context = context,
            root = view.findViewById(R.id.custom_stream_form),
            state = state,
        )
        view.findViewById<ImageButton>(R.id.btn_custom_stream_settings_close)
            .setOnClickListener { dialog.dismiss() }
        view.findViewById<TextView>(R.id.btn_custom_stream_settings_save)
            .setOnClickListener {
                val result = binding.validate() ?: return@setOnClickListener
                onApply(result)
                dialog.dismiss()
            }

        dialog.show()
    }
}
