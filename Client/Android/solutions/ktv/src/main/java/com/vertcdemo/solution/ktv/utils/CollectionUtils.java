// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.utils;

import java.util.HashSet;

public class CollectionUtils {
    public static <T> HashSet<T> setOf(T item) {
        HashSet<T> result = new HashSet<>();
        result.add(item);
        return result;
    }
}
