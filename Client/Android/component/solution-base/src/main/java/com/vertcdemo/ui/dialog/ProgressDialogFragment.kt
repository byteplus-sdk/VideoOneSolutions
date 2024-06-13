// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.ui.dialog

import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.DialogFragment
import androidx.lifecycle.lifecycleScope
import com.vertcdemo.base.R
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class SolutionProgressDialog : DialogFragment() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setCancelable(false)
        setStyle(STYLE_NO_TITLE, R.style.SolutionProgressDialog)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View = inflater.inflate(R.layout.dialog_solution_progress, container, false)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        lifecycleScope.launch {
            delay(5000)
            setCancelable(true)
        }
    }

    override fun onCancel(dialog: DialogInterface) {
        parentFragmentManager.setFragmentResult(REQUEST_KEY, Bundle().apply {
            putBoolean(KEY_CANCELED, true)
        })
    }

    companion object {
        const val REQUEST_KEY = "solution-progress-dialog"
        const val KEY_CANCELED = "extra_canceled"
    }
}