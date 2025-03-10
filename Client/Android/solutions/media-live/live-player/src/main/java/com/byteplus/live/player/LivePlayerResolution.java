// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerResolution;

interface LivePlayerResolution {
    VeLivePlayerResolution Origin = new VeLivePlayerResolution(VeLivePlayerResolution.VeLivePlayerResolutionOrigin);
    VeLivePlayerResolution UHD = new VeLivePlayerResolution(VeLivePlayerResolution.VeLivePlayerResolutionUHD);
    VeLivePlayerResolution HD = new VeLivePlayerResolution(VeLivePlayerResolution.VeLivePlayerResolutionHD);
    VeLivePlayerResolution SD = new VeLivePlayerResolution(VeLivePlayerResolution.VeLivePlayerResolutionSD);
    VeLivePlayerResolution LD = new VeLivePlayerResolution(VeLivePlayerResolution.VeLivePlayerResolutionLD);
    VeLivePlayerResolution AO = new VeLivePlayerResolution(VeLivePlayerResolution.VeLivePlayerResolutionAO);

    static boolean equals(@Nullable VeLivePlayerResolution r1, @Nullable VeLivePlayerResolution r2) {
        if (r1 == r2) {
            return true;
        }

        if (r1 != null && r2 != null) {
            return TextUtils.equals(r1.resolutionStr, r2.resolutionStr);
        }

        return false;
    }
}
