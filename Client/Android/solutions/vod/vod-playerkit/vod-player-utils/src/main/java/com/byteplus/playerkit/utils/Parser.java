// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;

import org.json.JSONException;

public interface Parser<T> {

    T parse() throws JSONException;

}
