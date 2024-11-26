// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.settingskit;

import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import com.google.gson.Gson;

import java.util.List;

public class Option {

    public enum Strategy {
        IMMEDIATELY,
        RESTART_APP
    }

    public static final int TYPE_RATIO_BUTTON = 1;
    public static final int TYPE_SELECTABLE_ITEMS = 2;
    public static final int TYPE_EDITABLE_TEXT = 3;

    public final int type;
    public final String category;
    @StringRes
    public final int title;
    public final String key;
    public final Strategy strategy;
    public final Class<?> clazz;
    public final Object defaultValue;
    public final List<Object> candidates;

    private Object value;

    private Options.UserValues mUserValues;

    public Option(int type,
                  String category,
                  String key,
                  @StringRes int title,
                  Class<?> clazz,
                  Object defaultValue) {
        this(type, category, key, title, clazz, defaultValue, null);
    }

    public Option(int type,
                  String category,
                  String key,
                  @StringRes int title,
                  Class<?> clazz,
                  Object defaultValue,
                  List<Object> candidates) {
        this.type = type;
        this.category = category;
        this.key = key;
        this.title = title;
        this.strategy = Strategy.IMMEDIATELY;
        this.clazz = clazz;
        this.defaultValue = defaultValue;
        this.candidates = candidates;
    }

    public void setup(Options.UserValues userValues) {
        this.mUserValues = userValues;
    }

    public Options.UserValues userValues() {
        return mUserValues;
    }

    public Object userValue() {
        if (mUserValues != null) {
            return mUserValues.getValue(this);
        }
        return null;
    }

    public void saveUserValue(@Nullable Object value) {
        if (mUserValues != null) {
            mUserValues.saveValue(this, value);
        }
    }

    public Object value() {
        if (value == null || strategy == Strategy.IMMEDIATELY) {
            Object userValue = userValue();
            if (userValue != null) {
                value = userValue;
                return value;
            }
            value = defaultValue;
        }
        return value;
    }

    public <T> T value(Class<T> clazz) {
        if (this.clazz != clazz) {
            throw new IllegalArgumentException(this.clazz + " is not compare with " + clazz);
        }
        if (value == null || strategy == Strategy.IMMEDIATELY) {
            T userValue = userValue(clazz);
            if (userValue != null) {
                value = userValue;
                return clazz.cast(value);
            }
            value = defaultValue;
            return clazz.cast(value);
        }
        return clazz.cast(value);
    }

    public <T> T userValue(Class<T> clazz) {
        if (this.clazz != clazz) {
            throw new IllegalArgumentException(this.clazz + " is not compare with " + clazz);
        }
        return clazz.cast(userValue());
    }

    public int intValue() {
        return value(Integer.class);
    }

    public boolean booleanValue() {
        return value(Boolean.class);
    }

    public long longValue() {
        return value(Long.class);
    }

    public float floatValue() {
        return value(Float.class);
    }

    @Nullable
    public String stringValue() {
        return value(String.class);
    }

    public static String obj2String(Object o, Class<?> clazz) {
        final String valueStr;
        if (clazz == Integer.class ||
                clazz == Long.class ||
                clazz == Float.class ||
                clazz == Double.class ||
                clazz == Boolean.class ||
                clazz == String.class) {
            valueStr = String.valueOf(o);
        } else {
            valueStr = new Gson().toJson(o);
        }
        return valueStr;
    }

    public static Object string2Obj(String value, Class<?> clazz) {
        if (value == null) return null;
        if (clazz == Integer.class) {
            return Integer.parseInt(value);
        } else if (clazz == Long.class) {
            return Long.parseLong(value);
        } else if (clazz == Float.class) {
            return Float.parseFloat(value);
        } else if (clazz == Double.class) {
            return Double.parseDouble(value);
        } else if (clazz == Boolean.class) {
            return Boolean.parseBoolean(value);
        } else if (clazz == String.class) {
            return value;
        } else {
            return new Gson().fromJson(value, clazz);
        }
    }
}
