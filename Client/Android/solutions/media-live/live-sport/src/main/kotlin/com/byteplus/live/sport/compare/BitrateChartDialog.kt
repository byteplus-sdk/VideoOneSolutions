// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.compare

import android.content.Context
import android.view.LayoutInflater
import android.widget.TextView
import com.byteplus.live.sport.R
import com.google.android.material.bottomsheet.BottomSheetDialog

/**
 * Bottom-sheet showing the last-minute bitrate waveform for a single player.
 * Backfilled from the player's [BitrateHistory] on open, then kept live: the
 * host calls [onSample] from its `onStats` callback while the sheet is up.
 */
class BitrateChartDialog(context: Context) {

    private val dialog = BottomSheetDialog(context)
    private val chart: BitrateChartView
    private val currentText: TextView
    private val peakText: TextView
    private val context = context

    init {
        val view = LayoutInflater.from(context)
            .inflate(R.layout.live_sport_compare_chart_sheet, null)
        chart = view.findViewById(R.id.bitrate_chart)
        currentText = view.findViewById(R.id.chart_current)
        peakText = view.findViewById(R.id.chart_peak)
        dialog.setContentView(view)
    }

    fun show(history: List<Long>) {
        chart.setSamples(history)
        refreshLabels()
        dialog.show()
    }

    /** Push a live tick; ignored when the sheet isn't visible. */
    fun onSample(value: Long) {
        if (!dialog.isShowing) return
        chart.addSample(value)
        refreshLabels()
    }

    val isShowing: Boolean get() = dialog.isShowing

    fun setOnDismiss(action: () -> Unit) {
        dialog.setOnDismissListener { action() }
    }

    fun dismiss() = dialog.dismiss()

    private fun refreshLabels() {
        currentText.text = context.getString(
            R.string.live_sport_compare_chart_current, chart.current().toString(),
        )
        peakText.text = context.getString(
            R.string.live_sport_compare_chart_peak, chart.peak().toString(),
        )
    }
}
