// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.core.chat.like;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.graphics.Path;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

public class Animatorable extends AnimatorListenerAdapter implements ValueAnimator.AnimatorUpdateListener {

    public interface UpdateListener {
        void onAnimationEnd(Animatorable obj);

        void onAnimationUpdate(Animatorable obj);
    }

    public int colorIndex;
    private boolean needRotate;
    private int rotate;
    private final Animator mAnimator;
    private UpdateListener mListener;
    private float scale;
    private Path path;
    private float value;
    private int alpha = 255;

    public Animatorable(Animator animator) {
        mAnimator = animator;
    }

    public boolean hasPath() {
        return path != null;
    }

    public Path getPath() {
        return path;
    }

    public void setPath(Path path) {
        this.path = path;
    }

    @Keep
    public float getValue() {
        return value;
    }

    @Keep
    public void setValue(float value) {
        this.value = value;
    }

    @Keep
    public float getScale() {
        return scale;
    }

    @Keep
    public void setScale(float value) {
        scale = value;
    }

    @Keep
    public int getAlpha() {
        return alpha;
    }

    @Keep
    public void setAlpha(int alpha) {
        this.alpha = alpha;
    }

    public void setAnimatorDelay(long delay) {
        mAnimator.setStartDelay(delay);
    }

    public void startAnimation() {
        mAnimator.start();
    }

    public void cancel() {
        if (mAnimator.isRunning()) {
            mAnimator.cancel();
        }
    }

    public void end() {
        if (null != mAnimator && mAnimator.isStarted()) {
            mAnimator.end();
        }
    }

    @Override
    public void onAnimationEnd(Animator animation) {
        mListener.onAnimationEnd(this);
        alpha = 255;
    }

    @Override
    public void onAnimationUpdate(@NonNull ValueAnimator animation) {
        mListener.onAnimationUpdate(this);
    }

    public void setListener(UpdateListener listener) {
        mListener = listener;
    }

    public boolean isNeedRotate() {
        return needRotate;
    }

    public void setNeedRotate(boolean needRotate) {
        this.needRotate = needRotate;
    }

    public int getRotate() {
        return rotate;
    }

    public void setRotate(int rotate) {
        this.rotate = rotate;
    }
}