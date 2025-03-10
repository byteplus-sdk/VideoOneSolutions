// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils.event;

import java.lang.reflect.InvocationTargetException;

class Factory {
    static <T extends Event> T create(Class<T> clazz) {
        try {
            return clazz.getConstructor().newInstance();
        } catch (IllegalAccessException |
                 InstantiationException |
                 NoSuchMethodException |
                 InvocationTargetException e) {
            throw new RuntimeException(e);
        }
    }
}
