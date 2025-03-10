// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.utils;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.viewmodel.CreationExtras;
import androidx.navigation.NavBackStackEntry;
import androidx.navigation.NavController;
import androidx.navigation.fragment.NavHostFragment;

public class ViewModelProviderHelper {
    public static ViewModelProvider navGraphViewModelProvider(Fragment fragment, @IdRes int id) {
        NavController navController = NavHostFragment.findNavController(fragment);
        NavBackStackEntry backStackEntry = navController.getBackStackEntry(id);
        return new ViewModelProvider(backStackEntry);
    }

    public static ViewModelProvider navGraphViewModelProvider(Fragment fragment,
                                                              @IdRes int id,
                                                              @NonNull ViewModelProvider.Factory factory) {
        NavController navController = NavHostFragment.findNavController(fragment);
        NavBackStackEntry backStackEntry = navController.getBackStackEntry(id);
        return new ViewModelProvider(backStackEntry, factory);
    }

    public static ViewModelProvider navGraphViewModelProvider(Fragment fragment,
                                                              @IdRes int id,
                                                              @NonNull ViewModelProvider.Factory factory,
                                                              @NonNull CreationExtras extras) {
        NavController navController = NavHostFragment.findNavController(fragment);
        NavBackStackEntry backStackEntry = navController.getBackStackEntry(id);
        return new ViewModelProvider(backStackEntry.getViewModelStore(), factory, extras);
    }
}
