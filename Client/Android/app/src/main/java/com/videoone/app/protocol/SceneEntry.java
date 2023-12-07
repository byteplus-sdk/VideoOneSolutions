// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.AnyRes;
import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.core.content.res.ResourcesCompat;
import androidx.core.util.Consumer;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

/**
 * @see InteractiveLiveEntry
 * @see PlaybackEditEntry
 */
public class SceneEntry {
    private static final String TAG = "SceneEntry";

    private static final List<Entry> ENTRY = Arrays.asList(
            Entry.create("com.videoone.app.protocol.InteractiveLiveEntry", false),
            Entry.create("com.videoone.app.protocol.PlaybackEditEntry", true)
    );

    public static void forEach(@NonNull Consumer<SceneEntry> consumer) {
        for (Entry entry : ENTRY) {
            final String entryClass = entry.className;
            try {
                Class<?> clazz = Class.forName(entryClass);
                Object instance = clazz.newInstance();
                consumer.accept(new SceneEntry(clazz, instance, entry.isNew));
            } catch (ReflectiveOperationException e) {
                Log.w(TAG, "Entry not found: " + entryClass);
            }
        }
    }

    private final Class<?> entryClass;
    private final Object entryInstance;

    private final boolean isNew;

    public SceneEntry(Class<?> clazz, Object instance, boolean isNew) {
        this.entryClass = clazz;
        this.entryInstance = instance;
        this.isNew = isNew;
    }


    /**
     * Entry card title
     * <p>
     * Required
     *
     * @return
     */
    @StringRes
    public int title() {
        return invokeMethod("title");
    }

    /**
     * Entry card icon image
     * <p>
     * Required
     *
     * @return
     */
    @DrawableRes
    public int icon() {
        return invokeMethod("icon");
    }

    /**
     * Entry card entry
     * <p>
     * Required
     *
     * @param activity
     */
    public void startup(@NonNull Activity activity) {
        try {
            Method method = entryClass.getDeclaredMethod("startup", Activity.class);
            method.invoke(entryInstance, activity);
        } catch (ReflectiveOperationException e) {
            Log.w(TAG, "startup failed", e);
            throw new RuntimeException(e);
        }
    }

    /**
     * Entry card description, default to empty
     * <p>
     * Optional
     *
     * @return
     */
    @StringRes
    public int description() {
        return invokeMethod("description");
    }

    /**
     * Entry card action button text, {@link com.vertcdemo.app.R.string#try_it_now }
     * <p>
     * Optional
     *
     * @return
     */
    @StringRes
    public int action() {
        return invokeMethod("action");
    }

    public boolean isNew() {
        return isNew;
    }

    @AnyRes
    private int invokeMethod(String methodName) {
        try {
            Method method = entryClass.getDeclaredMethod(methodName);
            Object result = method.invoke(entryInstance);
            return result == null ? ResourcesCompat.ID_NULL : (int) result;
        } catch (ReflectiveOperationException e) {
            Log.w(TAG, "Not implement" + methodName);
            return ResourcesCompat.ID_NULL;
        }
    }

    static class Entry {
        public final String className;
        public final boolean isNew;

        private Entry(String className, boolean isNew) {
            this.className = className;
            this.isNew = isNew;
        }

        public static Entry create(String className, boolean isNew) {
            return new Entry(className, isNew);
        }
    }
}
