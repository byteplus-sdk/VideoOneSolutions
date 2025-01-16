// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;

import java.util.Collection;

public class CollectionUtils {

    public static boolean isEmpty(Collection<?> c) {
        return c == null || c.isEmpty();
    }
}
