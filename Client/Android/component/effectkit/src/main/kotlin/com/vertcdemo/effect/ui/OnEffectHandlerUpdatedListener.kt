// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui

interface OnEffectHandlerUpdatedListener {
    fun onEffectHandlerUpdated(policy: EffectHandlerUpdatePolicy)
}

enum class EffectHandlerUpdatePolicy {
    DISCARD, KEEP
}
