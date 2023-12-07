// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.settingskit;

import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import com.google.gson.Gson;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

public class Option {

    public enum Strategy {
        IMMEDIATELY,
        RESTART_APP
    }

    public enum Source {
        DEFAULT,
        REMOTE,
        USER
    }

    public static final int TYPE_RATIO_BUTTON = 1;
    public static final int TYPE_SELECTABLE_ITEMS = 2;
    public static final int TYPE_EDITABLE_TEXT = 3;
    public static final int TYPE_ARROW = 4;

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
    private Source valueFrom;

    private Options.UserValues mUserValues;
    private Options.RemoteValues mRemoteValues;

    public Option(int type, String category, String key, @StringRes int title, Class<?> clazz, Object defaultValue, List<Object> candidates) {
        this.type = type;
        this.category = category;
        this.key = key;
        this.title = title;
        this.strategy = Strategy.IMMEDIATELY;
        this.clazz = clazz;
        this.defaultValue = defaultValue;
        this.candidates = candidates;
    }

    public void setup(Options.UserValues userValues, Options.RemoteValues remoteValues) {
        this.mUserValues = userValues;
        this.mRemoteValues = remoteValues;
    }

    public Options.UserValues userValues() {
        return mUserValues;
    }

    public Options.RemoteValues remoteValues() {
        return mRemoteValues;
    }

    public Object userValue() {
        if (mUserValues != null) {
            return mUserValues.getValue(this);
        }
        return null;
    }

    public Object remoteValue() {
        if (mRemoteValues != null) {
            return mRemoteValues.getValue(this);
        }
        return null;
    }

    public Object value() {
        if (value == null || strategy == Strategy.IMMEDIATELY) {
            Object userValue = userValue();
            if (userValue != null) {
                value = userValue;
                valueFrom = Source.USER;
                return value;
            }
            Object remoteValue = remoteValue();
            if (remoteValue != null) {
                value = remoteValue;
                valueFrom = Source.REMOTE;
                return value;
            }
            value = defaultValue;
            valueFrom = Source.DEFAULT;
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
                valueFrom = Source.USER;
                return clazz.cast(value);
            }
            T remoteValue = remoteValue(clazz);
            if (remoteValue != null) {
                value = remoteValue;
                valueFrom = Source.REMOTE;
                return clazz.cast(value);
            }
            value = defaultValue;
            valueFrom = Source.DEFAULT;
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

    public <T> T remoteValue(Class<T> clazz) {
        if (this.clazz != clazz) {
            throw new IllegalArgumentException(this.clazz + " is not compare with " + clazz);
        }
        return clazz.cast(remoteValue());
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

    @Nullable
    public JSONObject jsonObjectValue() {
        return value(JSONObject.class);
    }

    @Nullable
    public JSONArray jsonArrayValue() {
        return value(JSONArray.class);
    }

    public static String obj2String(Object o, Class<?> clazz) {
        final String valueStr;
        if (clazz == Integer.class ||
                clazz == Long.class ||
                clazz == Float.class ||
                clazz == Double.class ||
                clazz == Boolean.class ||
                clazz == String.class ||
                clazz == JSONObject.class ||
                clazz == JSONArray.class) {
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
        } else if (clazz == JSONObject.class) {
            try {
                return new JSONObject(value);
            } catch (JSONException e) {
                e.printStackTrace();
                return null;
            }
        } else if (clazz == JSONArray.class) {
            try {
                return new JSONArray(value);
            } catch (JSONException e) {
                e.printStackTrace();
                return null;
            }
        } else {
            return new Gson().fromJson(value, clazz);
        }
    }
}
