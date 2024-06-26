package com.vertc.api.example.base.bean;


import android.graphics.drawable.Drawable;

import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.annotation.ApiExample;

public class ExampleInfo implements Comparable<ExampleInfo> {

    public final CharSequence label;
    public final Drawable icon;
    private final Class<?> action;
    private final int order;

    public final ExampleCategory category;

    public ExampleInfo(CharSequence label, Drawable icon, Class<?> clazz, ApiExample annotation) {
        this.label = label;
        this.icon = icon;
        this.action = clazz;
        this.order = annotation.order();
        this.category = annotation.category();
    }

    public Class<?> getAction() {
        return action;
    }

    @Override
    public int compareTo(ExampleInfo o) {
        int compared = this.category.compareTo(o.category);
        if (compared == 0) {
            return Integer.compare(this.order, o.order);
        }
        return compared;
    }
}
