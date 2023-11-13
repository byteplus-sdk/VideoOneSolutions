// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.util;

import androidx.annotation.NonNull;
import androidx.arch.core.util.Function;

import java.util.ArrayList;
import java.util.List;

public class CollectionUtils {
    @NonNull
    public static <T, R> List<R> map(@NonNull List<T> list, @NonNull Function<T, R> function) {
        List<R> result = new ArrayList<>();
        for (T t : list) {
            result.add(function.apply(t));
        }

        return result;
    }
}
