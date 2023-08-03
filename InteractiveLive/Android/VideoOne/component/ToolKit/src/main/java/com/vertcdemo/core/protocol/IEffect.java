// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.protocol;

import android.content.Context;
import android.content.DialogInterface;

import androidx.fragment.app.FragmentManager;

import com.ss.bytertc.engine.RTCVideo;

public interface IEffect {

    void initWithRTCVideo(RTCVideo rtcVideo);

    void showEffectDialog(Context context, DialogInterface.OnDismissListener dismissListener, FragmentManager fragmentManager);

    void destroyEffectDialog();

    void destroy();
}
