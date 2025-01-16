// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;

import android.text.TextUtils;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;


public class ReflectUtils {

    public static Class<?> getInnerClass(Class<?> outerClazz, String innerClassName) {
        try {
            Class<?> innerClass = Class.forName(outerClazz.getName() + "$" + innerClassName);
            return innerClass;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static <T> T getField(Object o, Class<?> clazz, String fieldName) {
        try {
            Field field = clazz.getDeclaredField(fieldName);
            field.setAccessible(true);
            Object object = field.get(o);
            if (object != null) {
                return (T) object;
            }
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static <T> T invokeMethod(Object o, Class<?> clazz, String methodName) {
        try {
            Method method = clazz.getMethod(methodName);
            return (T) method.invoke(o);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        return null;
    }
    public static void setStaticFiledValue(Class<?> owner, Class<?> filedClass, String filedName, Object staticFiled) {
        Field targetField = null;
        Field[] fields = owner.getDeclaredFields();
        for (Field field : fields) {
            if (field.getType() == filedClass && Modifier.isStatic(field.getModifiers())) {
                if (TextUtils.equals(field.getName(), filedName)) {
                    targetField = field;
                    break;
                }
            }
        }
        if (targetField != null) {
            targetField.setAccessible(true);
            try {
                targetField.set(null, staticFiled);
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
    }
}
