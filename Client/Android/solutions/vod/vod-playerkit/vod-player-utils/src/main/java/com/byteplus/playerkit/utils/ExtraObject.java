// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.utils;

import android.os.Parcelable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.Serializable;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;


public class ExtraObject implements Serializable {

    protected final Map<String, Object> mExtras = Collections.synchronizedMap(new LinkedHashMap<>());

    public <T> T getExtra(@NonNull String key, @NonNull Class<T> clazz) {
        Object extra = mExtras.get(key);
        if (extra != null) {
            if (clazz.isInstance(extra)) {
                return (T) extra;
            }
            throw new ClassCastException(extra.getClass() + " can't be cast to + " + clazz);
        }
        return null;
    }

    public void putExtra(@NonNull String key, @Nullable Object extra) {
        if (extra == null) {
            mExtras.remove(key);
        } else {
            if (extra instanceof Serializable || extra instanceof Parcelable) {
                mExtras.put(key, extra);
            } else {
                throw new IllegalArgumentException("Unsupported type " + extra.getClass());
            }
        }
    }

    public void clearExtras() {
        mExtras.clear();
    }
}
