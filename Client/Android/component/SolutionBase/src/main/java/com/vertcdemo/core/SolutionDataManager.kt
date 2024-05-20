// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core

import android.content.Context
import android.content.SharedPreferences
import android.text.TextUtils
import com.vertcdemo.core.utils.AppUtil.applicationContext
import java.util.UUID
import kotlin.math.abs

object SolutionDataManager {
    private const val PREFS_NAME = "solution_data_manager"
    private const val KEY_USER_ID = "user_id"
    private const val KEY_USER_NAME = "user_name"
    private const val KEY_TOKEN = "token"
    private const val KEY_DEVICE_ID = "device_id"
    private const val KEY_OPEN_UDID = "openudid"

    var userId: String?
        get() = prefs.getString(KEY_USER_ID, "")
        set(userId) = prefs.edit()
            .putString(KEY_USER_ID, userId)
            .apply()
    var userName: String?
        get() = prefs.getString(KEY_USER_NAME, "")
        set(userName) = prefs.edit()
            .putString(KEY_USER_NAME, userName)
            .apply()
    var token: String?
        get() = prefs.getString(KEY_TOKEN, "")
        set(token) = prefs.edit()
            .putString(KEY_TOKEN, token)
            .apply()

    @get:Synchronized
    val deviceId: String
        get() {
            val did = prefs.getString(KEY_DEVICE_ID, "")
            return if (did.isNullOrEmpty()) {
                "${abs(UUID.randomUUID().hashCode())}".also {
                    prefs.edit().putString(KEY_DEVICE_ID, it).apply()
                }
            } else {
                did
            }
        }

    fun logout() = prefs.edit()
        .remove(KEY_USER_ID)
        .remove(KEY_USER_NAME)
        .remove(KEY_TOKEN)
        .apply()

    @JvmStatic
    fun ins(): SolutionDataManager = this

    private val prefs: SharedPreferences by lazy {
        applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
}
