// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.annotation;

import androidx.annotation.Keep;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import com.google.gson.annotations.SerializedName;

/**
 * An annotation for Sub-class of Event which does not have any field annotated with {@link SerializedName}
 * <p>
 * Generally, it is not necessary to add this annotation manually as Gson itself has <a href="https://github.com/google/gson/blob/main/examples/android-proguard-example/proguard.cfg">rules</a> to ensure that default constructors of classes will be preserved when there's field(s) annotated with {@link SerializedName}.
 * This annotation is only used for Sub-class of such Event and does NOT have any field annotated with {@link SerializedName}.
 *</p>
 *
 *
 *
 * @see SerializedName
 */
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.CLASS)
@Keep
public @interface Event {
}