// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.net

@JvmDefaultWithCompatibility
fun interface IRequestCallback<T> {
    fun onSuccess(data: T)

    fun onError(errorCode: Int, message: String?) {
    }
}
