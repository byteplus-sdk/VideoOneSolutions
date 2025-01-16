// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.scene.shortvideo;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.res.Resources;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.BounceInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.widget.ImageView;

import androidx.annotation.NonNull;

import com.byteplus.vod.scenekit.R;

import java.util.Random;

public class DoubleTapHeartHelper {

    private static int heartSize = -1;
    private static int upDistance = 0;

    private static final Random mRandom = new Random();


    public static void show(@NonNull ViewGroup parent, int x, int y) {
        Context context = parent.getContext();

        if (heartSize < 0) {
            Resources resources = context.getResources();
            heartSize = resources.getDimensionPixelSize(R.dimen.vevod_heart_view_size);
            upDistance = resources.getDimensionPixelSize(R.dimen.vevod_heart_view_up_distance);
        }

        ImageView image = new ImageView(context);
        image.setImageResource(R.drawable.vevod_heart);
        final float translationY = y - heartSize / 2.F;
        image.setTranslationX(x - heartSize / 2.F);
        image.setTranslationY(translationY);

        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(heartSize, heartSize);
        parent.addView(image, params);

        // Initialized Rotate [-30, 30]
        image.setRotation(mRandom.nextInt(61) - 30);

        AnimatorSet show = new AnimatorSet();
        show.setDuration(300);
        show.setInterpolator(new BounceInterpolator());
        show.playTogether(
                ObjectAnimator.ofFloat(image, View.SCALE_X, 1.8F, 1.0F),
                ObjectAnimator.ofFloat(image, View.SCALE_Y, 1.8F, 1.0F)
        );

        // Dismiss Scale [2.0, 3.0]
        final float scaleTarget = 2.F + mRandom.nextFloat();

        AnimatorSet dismiss = new AnimatorSet();
        dismiss.playTogether(
                ObjectAnimator.ofFloat(image, View.SCALE_X, 1.F, scaleTarget), /* Scale up X */
                ObjectAnimator.ofFloat(image, View.SCALE_Y, 1.F, scaleTarget), /* Scale up X */
                ObjectAnimator.ofFloat(image, View.ALPHA, 1, 0), /* Dim to dismiss */
                ObjectAnimator.ofFloat(image, View.TRANSLATION_Y, translationY, translationY - upDistance) /* Float up */
        );
        dismiss.setInterpolator(new DecelerateInterpolator());
        dismiss.setStartDelay(200);
        dismiss.setDuration(500);

        AnimatorSet animators = new AnimatorSet();
        animators.playSequentially(show, dismiss);
        animators.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                parent.removeView(image);
            }
        });
        animators.start();
    }
}
