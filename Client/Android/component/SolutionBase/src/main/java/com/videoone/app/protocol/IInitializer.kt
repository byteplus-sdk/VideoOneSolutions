// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import android.app.Application

interface IInitializer {
    fun initialize(application: Application)
}
