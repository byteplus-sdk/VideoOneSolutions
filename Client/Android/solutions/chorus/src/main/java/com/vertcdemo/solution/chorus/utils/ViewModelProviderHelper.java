// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.utils;

import androidx.annotation.IdRes;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavBackStackEntry;
import androidx.navigation.NavController;
import androidx.navigation.fragment.NavHostFragment;

public class ViewModelProviderHelper {
    public static ViewModelProvider navGraphViewModelProvider(Fragment fragment, @IdRes int id) {
        NavController navController = NavHostFragment.findNavController(fragment);
        NavBackStackEntry backStackEntry = navController.getBackStackEntry(id);
        return new ViewModelProvider(backStackEntry);
    }
}
