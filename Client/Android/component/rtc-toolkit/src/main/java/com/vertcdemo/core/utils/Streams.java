// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.arch.core.util.Function;
import androidx.core.util.Predicate;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


public class Streams {
    @NonNull
    public static <T, R> List<R> map(@Nullable List<T> source, @NonNull Function<T, R> function) {
        if (source == null || source.isEmpty()) {
            return Collections.emptyList();
        }
        List<R> result = new ArrayList<>();
        for (T t : source) {
            result.add(function.apply(t));
        }

        return result;
    }

    @NonNull
    public static <T, R> Set<R> mapToSet(@Nullable List<T> source,
                                         @NonNull Predicate<T> predicate,
                                         @NonNull Function<T, R> function) {
        if (source == null || source.isEmpty()) {
            return Collections.emptySet();
        }

        Set<R> result = new HashSet<>();
        for (T t : source) {
            if (predicate.test(t)) {
                result.add(function.apply(t));
            }
        }

        return result;
    }
}
