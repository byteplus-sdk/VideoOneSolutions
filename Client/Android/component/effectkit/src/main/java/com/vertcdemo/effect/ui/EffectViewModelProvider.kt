// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui

import androidx.annotation.MainThread

interface EffectViewModelProvider {
    @MainThread
    fun getEffectViewModel(): EffectViewModel
}
