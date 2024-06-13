// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.utils

import android.content.Context
import android.view.View
import android.view.inputmethod.InputMethodManager

object InputMethodUtils {

    @JvmStatic
    fun showInputMethod(ctx: Context?) {
        val inputMethod: InputMethodManager =
            ctx?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputMethod.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
    }

    @JvmStatic
    fun hideInputMethod(ctx: Context?, view: View?) {
        val inputMethod: InputMethodManager =
            ctx?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputMethod.hideSoftInputFromWindow(view?.windowToken, 0)
    }
}