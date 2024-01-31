// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.vod.scenekit.ui.video.layer.base;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.os.Handler;
import android.os.Looper;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.utils.L;


public abstract class AnimateLayer extends BaseLayer {
    public static final long DEFAULT_ANIMATE_DURATION = 300;
    public static final long DEFAULT_ANIMATE_DISMISS_DELAY = 4000;

    public enum State {
        IDLE, SHOWING, DISMISSING;
    }


    private Animator mAnimator;
    private State mState = State.IDLE;

    protected final Handler mH = new Handler(Looper.getMainLooper());
    protected final Runnable animateDismissRunnable = this::animateDismiss;

    public Animator.AnimatorListener mAnimateShowListener;
    public Animator.AnimatorListener mAnimateDismissListener;

    public void setAnimateShowListener(Animator.AnimatorListener listener) {
        this.mAnimateShowListener = listener;
    }

    public void setAnimateDismissListener(Animator.AnimatorListener listener) {
        this.mAnimateDismissListener = listener;
    }

    protected Animator createAnimator() {
        ObjectAnimator animator = new ObjectAnimator();
        animator.setPropertyName("alpha");
        return animator;
    }

    protected void resetViewAnimateProperty() {
        View view = getView();
        if (view != null) {
            view.setAlpha(1);
        }
    }

    protected void initAnimateShowProperty(Animator animator) {
        if (animator instanceof ObjectAnimator) {
            ((ObjectAnimator) animator).setFloatValues(0f, 1f);
        }
    }

    protected void initAnimateDismissProperty(Animator animator) {
        if (animator instanceof ObjectAnimator) {
            ((ObjectAnimator) animator).setFloatValues(1f, 0f);
        }
    }

    public final void animateToggle(boolean autoDismiss) {
        switch (mState) {
            case IDLE:
                if (isShowing()) {
                    animateDismiss();
                } else {
                    animateShow(autoDismiss);
                }
                break;
            case SHOWING:
                animateDismiss();
                break;
            case DISMISSING:
                animateShow(autoDismiss);
                break;
        }
    }

    public boolean isAnimateShowing() {
        return mState == State.SHOWING;
    }

    public boolean isAnimateDismissing() {
        return mState == State.DISMISSING;
    }

    public void animateShow(boolean autoDismiss) {
        animateShow(autoDismiss, null);
    }

    public void animateShow(
            boolean autoDismiss,
            @Nullable Animator.AnimatorListener showListener) {

        animateShow(0, DEFAULT_ANIMATE_DURATION, autoDismiss, showListener);
    }

    public final void animateShow(
            long startDelay,
            long duration,
            boolean autoDismiss,
            @Nullable Animator.AnimatorListener showListener) {

        removeDismissRunnable();
        if (mState == State.SHOWING || isShowing()) {
            L.v(this, "animateShow", mState, State.SHOWING, "ignore");
            if (autoDismiss) {
                postDismissRunnable();
            }
            return;
        }

        if (mState == State.DISMISSING) {
            L.v(this, "animateShow", mState, State.SHOWING, "cancel");
            if (mAnimator != null && mAnimator.isStarted()) {
                mAnimator.cancel();
            }
        }

        L.v(this, "animateShow", "start");
        show();

        if (!isShowing()) return; // support lock

        if (mAnimator == null) {
            mAnimator = createAnimator();
            mAnimator.setTarget(getView());
        }
        mAnimator.removeAllListeners();
        mAnimator.setStartDelay(startDelay);
        mAnimator.setDuration(duration);
        initAnimateShowProperty(mAnimator);
        mAnimator.start();
        mAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationCancel(Animator animation) {
                resetViewAnimateProperty();
                L.v(AnimateLayer.this, "animateShow", "cancel");
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                resetViewAnimateProperty();
                setState(State.IDLE);
                L.v(AnimateLayer.this, "animateShow", "end");
            }
        });
        if (showListener != null) {
            mAnimator.addListener(showListener);
        }
        if (mAnimateShowListener != null) {
            mAnimator.addListener(mAnimateShowListener);
        }
        setState(State.SHOWING);

        if (autoDismiss) {
            postDismissRunnable();
        }
    }

    public void requestAnimateDismiss(@NonNull String reason) {
        animateDismiss();
    }

    public void animateDismiss() {
        animateDismiss(false);
    }

    public void animateDismiss(boolean force) {
        final long startDelay = 0;
        final long duration = DEFAULT_ANIMATE_DURATION;

        removeDismissRunnable();
        if (mState == State.DISMISSING) {
            L.v(this, "animateDismiss", mState, State.DISMISSING, "ignore");
            return;
        } else if (mState == State.SHOWING) {
            L.v(this, "animateDismiss", mState, State.DISMISSING, "cancel");
            if (mAnimator != null && mAnimator.isStarted()) {
                mAnimator.cancel();
            }
        } else {
            if (!isShowing()) {
                L.v(this, "animateDismiss", mState, State.DISMISSING, "ignore");
                return;
            }
        }
        if (force) {
            L.v(this, "animateDismiss", "force/start");
            dismiss();
            L.v(AnimateLayer.this, "animateDismiss", "end");
            return;
        }
        if (preventAnimateDismiss()) {
            L.v(AnimateLayer.this, "animateDismiss", "preventAnimateDismiss");
            return;
        }
        L.v(this, "animateDismiss", "start");
        if (mAnimator == null) {
            mAnimator = createAnimator();
        }
        mAnimator.removeAllListeners();
        mAnimator.setStartDelay(startDelay);
        mAnimator.setDuration(duration);
        initAnimateDismissProperty(mAnimator);
        mAnimator.start();
        mAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationCancel(Animator animation) {
                resetViewAnimateProperty();
                L.v(AnimateLayer.this, "animateDismiss", "cancel");
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                if (preventAnimateDismiss()) {
                    resetViewAnimateProperty();
                    setState(State.IDLE);
                    L.v(AnimateLayer.this, "animateDismiss", "preventAnimateDismiss");
                } else {
                    dismiss();
                    L.v(AnimateLayer.this, "animateDismiss", "end");
                }
            }
        });
        if (mAnimateDismissListener != null) {
            mAnimator.addListener(mAnimateDismissListener);
        }
        setState(State.DISMISSING);
    }

    protected boolean preventAnimateDismiss() {
        return false;
    }

    @Override
    public void show() {
        removeDismissRunnable();
        if (mAnimator != null && mAnimator.isStarted()) {
            mAnimator.removeAllListeners();
            mAnimator.cancel();
        }
        super.show();
        resetViewAnimateProperty();
        setState(State.IDLE);
    }

    @Override
    public void dismiss() {
        removeDismissRunnable();
        if (mAnimator != null && mAnimator.isStarted()) {
            mAnimator.removeAllListeners();
            mAnimator.cancel();
        }
        super.dismiss();
        resetViewAnimateProperty();
        setState(State.IDLE);
    }

    @Override
    public void hide() {
        removeDismissRunnable();
        if (mAnimator != null && mAnimator.isStarted()) {
            mAnimator.removeAllListeners();
            mAnimator.cancel();
        }
        super.hide();
        resetViewAnimateProperty();
        setState(State.IDLE);
    }

    protected long animateDismissDelay() {
        return DEFAULT_ANIMATE_DISMISS_DELAY;
    }

    private void removeDismissRunnable() {
        mH.removeCallbacks(animateDismissRunnable);
    }

    private void postDismissRunnable() {
        mH.postDelayed(animateDismissRunnable, animateDismissDelay());
    }

    private void setState(State state) {
        if (this.mState != state) {
            L.v(this, "setState", mState, state);
            this.mState = state;
        }
    }
}
