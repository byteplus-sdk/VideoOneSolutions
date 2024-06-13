// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.common

import com.google.gson.Gson
import com.google.gson.GsonBuilder

object GsonUtils {
    private val sGson = GsonBuilder().create()

    @JvmStatic
    fun gson(): Gson = sGson
}
