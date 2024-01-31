// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.protocol;

import android.content.Context;
import android.content.DialogInterface;

import androidx.fragment.app.FragmentManager;

import com.ss.bytertc.engine.video.IVideoEffect;


public interface IEffect {

    void init(IVideoEffect videoEffect);

    void showEffectDialog(Context context,
                          DialogInterface.OnDismissListener dismissListener,
                          FragmentManager fragmentManager);

    void destroyEffectDialog();

    void destroy();
}
