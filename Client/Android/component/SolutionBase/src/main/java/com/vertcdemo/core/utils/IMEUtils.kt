// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.utils

import android.content.Context
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText

object IMEUtils {
    @JvmStatic
    fun closeIME(v: View) {
        val mgr = v.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        mgr.hideSoftInputFromWindow(v.windowToken, 0)
        v.clearFocus()
    }

    @JvmStatic
    fun openIME(v: EditText) {
        v.requestFocus()
        if (v.hasFocus()) {
            v.post {
                val mgr =
                    v.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                mgr.showSoftInput(v, InputMethodManager.SHOW_FORCED)
            }
        }
    }
}
