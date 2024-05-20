// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;

import androidx.annotation.NonNull;

import org.json.JSONException;

public interface Parser<T> {

    T parse(@NonNull String source) throws JSONException;

}
