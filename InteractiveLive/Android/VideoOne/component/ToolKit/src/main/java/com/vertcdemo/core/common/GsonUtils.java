// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.common;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class GsonUtils {
    private static final Gson sGson = new GsonBuilder().create();

    private GsonUtils() {
    }

    public static Gson gson() {
        return sGson;
    }
}
