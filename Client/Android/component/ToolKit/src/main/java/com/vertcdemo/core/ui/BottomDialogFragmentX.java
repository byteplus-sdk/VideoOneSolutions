// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.ui;

import android.graphics.Color;
import android.os.Bundle;
import android.view.Window;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.core.R;

/**
 * A Bottom sheet dialog automatic change the Navigation Bar Color
 */
public class BottomDialogFragmentX extends BottomSheetDialogFragment {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final FragmentActivity activity = requireActivity();
        final Window window = activity.getWindow();
        final int barColorOld = window.getNavigationBarColor();
        if (barColorOld == Color.TRANSPARENT) {
            final int color = ContextCompat.getColor(activity, R.color.bottom_sheet_panel);
            getLifecycle().addObserver(new DefaultLifecycleObserver() {
                @Override
                public void onStart(@NonNull LifecycleOwner owner) {
                    window.setNavigationBarColor(color);
                }

                @Override
                public void onStop(@NonNull LifecycleOwner owner) {
                    window.setNavigationBarColor(Color.TRANSPARENT);
                }
            });
        }
    }
}