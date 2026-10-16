// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.vod.function.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider

/**
 * [CastingViewModel] 的无依赖工厂。M2 重构后投屏 ViewModel 不再依赖任何旧 Adapter。
 */
class CastingViewModelFactory : ViewModelProvider.Factory {

    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(CastingViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return CastingViewModel() as T
        }
        throw IllegalArgumentException("Unknown ViewModel class: $modelClass")
    }
}
