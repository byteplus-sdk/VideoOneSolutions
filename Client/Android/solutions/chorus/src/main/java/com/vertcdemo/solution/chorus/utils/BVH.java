// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.utils;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class BVH<T> extends RecyclerView.ViewHolder {
    public final T binding;

    public BVH(@NonNull View itemView, T t) {
        super(itemView);
        this.binding = t;
    }
}
