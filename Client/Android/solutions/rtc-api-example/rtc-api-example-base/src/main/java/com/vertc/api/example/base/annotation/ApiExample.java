package com.vertc.api.example.base.annotation;

import androidx.annotation.NonNull;

import com.vertc.api.example.base.ExampleCategory;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
public @interface ApiExample {
    int order();

    @NonNull
    ExampleCategory category();

    String title();
}
