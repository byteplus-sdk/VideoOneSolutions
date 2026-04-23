// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class VersionViewModel : ViewModel() {
    val hasNew = MutableLiveData<Boolean>()
    val newVersionUrl: String? = null
}