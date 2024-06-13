// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.protocol;

import androidx.annotation.Nullable;

public class EffectFactory {

    /**
     * @see com.vertcdemo.effect.rtc.IEffectImpl
     */
    public static @Nullable IEffect create() {
        try {
            Class<?> clazz = Class.forName("com.vertcdemo.effect.rtc.IEffectImpl");
            Object obj = clazz.newInstance();
            if (obj instanceof IEffect) {
                return (IEffect) obj;
            } else {
                return null;
            }
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException e) {
            e.printStackTrace();
            return null;
        }
    }
}
