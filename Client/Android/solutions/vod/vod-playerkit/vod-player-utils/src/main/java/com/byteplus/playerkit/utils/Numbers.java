// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;

public class Numbers {

    public static float safeParseFloat(String s, float defaultValue) {
        try {
            return Float.parseFloat(s);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static int safeParseInt(String s, int defaultValue) {
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
