// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher.ui.activities;

import android.graphics.Bitmap;

public interface ILivePusherActivity {
    void choosePic(ChoosePicListener listener);

    @FunctionalInterface
    interface ChoosePicListener {
        void onChoosePic(Bitmap bm);
    }
}


