// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.login;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.common.IAction;
import com.vertcdemo.core.protocol.ILogin;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.login.utils.CloseAccountManager;

@SuppressWarnings("unused")
@Keep
public class ILoginImpl implements ILogin {
    @Override
    public void showLoginView(@NonNull ActivityResultLauncher<Intent> launcher) {
        String token = SolutionDataManager.ins().getToken();
        if (TextUtils.isEmpty(token)) {
            Context context = AppUtil.getApplicationContext();
            launcher.launch(new Intent(context, LoginActivity.class));
        }
    }

    @Override
    public void closeAccount(IAction<Boolean> action) {
        CloseAccountManager.delete(action);
    }
}
