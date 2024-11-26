// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.chat.like;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.TimeInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.LinearInterpolator;

import java.util.ArrayDeque;
import java.util.Queue;

public class AnimatorableFactory {

    private static final Queue<Animatorable> sPool = new ArrayDeque<>();

    /**
     * Return a new LikeObject instance from the global pool. Allows us to
     * avoid allocating new objects in many cases.
     */
    public static Animatorable obtain() {
        Animatorable heart = sPool.poll();

        if (heart == null) {
            heart = createAnimator();
        }

        return heart;
    }

    public static void recycle(Animatorable obj) {
        if (sPool.size() <= 32) {
            obj.setListener(null);
            sPool.add(obj);
        }
    }

    public static Animatorable createAnimator() {
        AnimatorSet animator = new AnimatorSet();
        Animatorable animatorable = new Animatorable(animator);
        SpeedInterpolator speedInterpolator = new SpeedInterpolator();
        LinearInterpolator line = new LinearInterpolator();
        AccelerateInterpolator accelerate = new AccelerateInterpolator();
        ObjectAnimator value = ObjectAnimator.ofFloat(animatorable, "value", 1F, 0F);
        value.setDuration(2000);
        value.addListener(animatorable);
        value.setInterpolator(speedInterpolator);
        value.addUpdateListener(animatorable);
        ObjectAnimator scaleLarge = ObjectAnimator.ofFloat(animatorable, "scale", .3F, 1.2F);
        scaleLarge.setInterpolator(accelerate);
        scaleLarge.setDuration(100);
        ObjectAnimator scaleSmall = ObjectAnimator.ofFloat(animatorable, "scale", 1.2F, 1F);
        scaleSmall.setInterpolator(accelerate);
        scaleSmall.setStartDelay(100);
        scaleSmall.setDuration(100);

        ObjectAnimator alpha = ObjectAnimator.ofInt(animatorable, "alpha", 255, 0);
        alpha.setInterpolator(line);
        alpha.setStartDelay(900);
        alpha.setDuration(1000);

        animator.playTogether(value, scaleLarge, scaleSmall, alpha);

        return animatorable;
    }

    private static class SpeedInterpolator implements TimeInterpolator {
        @Override
        public float getInterpolation(float input) {
            if (input < 1f / 10f) {
                return 2.5f * input;
            } else {
                return 5f / 6f * input + 1f / 6f;
            }
        }
    }
}
