// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.protocol;

import androidx.annotation.Nullable;

public class ProtocolUtil {

    private static volatile IEffect sIEffect = null;

    public static @Nullable IEffect getIEffect() {
        if (sIEffect != null) {
            return sIEffect;
        }
        try {
            Class<?> clazz = Class.forName("com.vertcdemo.effect.IEffectImpl");
            Object obj = clazz.newInstance();
            if (obj instanceof IEffect) {
                sIEffect = (IEffect) obj;
                return sIEffect;
            } else {
                return null;
            }
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void destroyEffect() {
        if (sIEffect != null) {
            sIEffect.destroy();
        }
        sIEffect = null;
    }
}
