// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;



import android.animation.TimeInterpolator;


public class EaseBounceOutInterpolator implements TimeInterpolator {

    public EaseBounceOutInterpolator() {}

    public float getInterpolation(float input) {
        if (input < (1 / 2.75))
            return (7.5625f * input * input);
        else if (input < (2 / 2.75))
            return (7.5625f * (input -= (1.5f / 2.75f)) * input + 0.75f);
        else if (input < (2.5 / 2.75))
            return (7.5625f * (input -= (2.25f / 2.75f)) * input + 0.9375f);
        else
            return (7.5625f * (input -= (2.625f / 2.75f)) * input + 0.984375f);
    }
}
