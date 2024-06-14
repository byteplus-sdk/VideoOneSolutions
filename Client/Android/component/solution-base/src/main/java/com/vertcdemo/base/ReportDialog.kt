// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.base

import android.app.AlertDialog
import android.content.Context
import android.util.Log
import android.widget.AdapterView
import android.widget.Toast
import com.vertcdemo.core.utils.AppUtil
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

object ReportDialog {
    private const val TAG = "ReportDialog"
    private val uiScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    @JvmStatic
    fun show(context: Context) {
        val position = IntArray(1) { AdapterView.INVALID_POSITION }
        val items = context.resources.getStringArray(R.array.report_options)
        AlertDialog.Builder(context)
            .setSingleChoiceItems(
                items,
                AdapterView.INVALID_POSITION
            ) { _, which: Int -> position[0] = which }
            .setTitle(R.string.report_title)
            .setPositiveButton(R.string.confirm) { dialog, _ ->
                if (AdapterView.INVALID_POSITION != position[0]) {
                    val selectedItem = items[position[0]]
                    doReportProcess(selectedItem)
                }
                dialog.dismiss()
            }
            .setNegativeButton(R.string.cancel) { dialog, _: Int -> dialog.dismiss() }
            .show()
    }

    private fun doReportProcess(choice: String) {
        Log.d(TAG, "You report: $choice")
        // TODO Handle report to server
        uiScope.launch {
            delay(250)
            Toast.makeText(
                AppUtil.applicationContext,
                R.string.report_success,
                Toast.LENGTH_SHORT
            ).show()
        }
    }
}