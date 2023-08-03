// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.protocol;

import android.content.Intent;

import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.NonNull;

import com.vertcdemo.core.common.IAction;

public interface ILogin {

    void showLoginView(@NonNull ActivityResultLauncher<Intent> launcher);

    void closeAccount(IAction<Boolean> action);
}
