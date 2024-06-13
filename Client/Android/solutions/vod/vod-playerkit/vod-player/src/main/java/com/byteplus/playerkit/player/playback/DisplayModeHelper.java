// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback;

import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;

import androidx.annotation.IntDef;

import com.byteplus.playerkit.utils.L;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

public class DisplayModeHelper {

    @IntDef({DISPLAY_MODE_DEFAULT,
            DISPLAY_MODE_ASPECT_FILL_X,
            DISPLAY_MODE_ASPECT_FILL_Y,
            DISPLAY_MODE_ASPECT_FIT,
            DISPLAY_MODE_ASPECT_FILL})
    @Retention(RetentionPolicy.SOURCE)
    public @interface DisplayMode {
    }

    public static final int DISPLAY_MODE_DEFAULT = 0;
    public static final int DISPLAY_MODE_ASPECT_FILL_X = 1;
    public static final int DISPLAY_MODE_ASPECT_FILL_Y = 2;
    public static final int DISPLAY_MODE_ASPECT_FIT = 3;
    public static final int DISPLAY_MODE_ASPECT_FILL = 4;

    private float mDisplayAspectRatio;
    @DisplayMode
    private int mDisplayMode = DISPLAY_MODE_DEFAULT;

    private FrameLayout mContainerView;
    private View mDisplayView;


    public static String map(@DisplayMode int displayMode) {
        switch (displayMode) {
            case DISPLAY_MODE_DEFAULT:
                return "default";
            case DISPLAY_MODE_ASPECT_FILL_X:
                return "aspect_fill_x";
            case DISPLAY_MODE_ASPECT_FILL_Y:
                return "aspect_fill_y";
            case DISPLAY_MODE_ASPECT_FIT:
                return "aspect_fit";
            case DISPLAY_MODE_ASPECT_FILL:
                return "aspect_fill";
            default:
                throw new IllegalArgumentException("unsupported displayMode! " + displayMode);
        }
    }

    public void setDisplayAspectRatio(float dar) {
        this.mDisplayAspectRatio = dar;
        apply();
    }

    public void setDisplayMode(@DisplayMode int displayMode) {
        mDisplayMode = displayMode;
        apply();
    }

    @DisplayMode
    public int getDisplayMode() {
        return mDisplayMode;
    }

    public void setContainerView(FrameLayout containerView) {
        mContainerView = containerView;
        apply();
    }

    public void setDisplayView(View displayView) {
        mDisplayView = displayView;
        apply();
    }

    public void apply() {
        if (mDisplayView == null) return;
        mDisplayView.removeCallbacks(applyDisplayMode);
        mDisplayView.postOnAnimation(applyDisplayMode);
    }

    private final Runnable applyDisplayMode = new Runnable() {
        @Override
        public void run() {
            applyDisplayMode();
        }
    };

    private void applyDisplayMode() {
        final View containerView = mContainerView;
        if (containerView == null) return;
        final int containerWidth = containerView.getWidth();
        final int containerHeight = containerView.getHeight();

        final View displayView = mDisplayView;
        if (displayView == null) return;

        final int displayMode = mDisplayMode;
        float displayAspectRatio = mDisplayAspectRatio;
        if (displayAspectRatio <= 0) return;

        final float containerRatio = containerWidth / (float) containerHeight;

        final int displayGravity = Gravity.CENTER;
        final int displayWidth;
        final int displayHeight;

        switch (displayMode) {
            case DISPLAY_MODE_DEFAULT:
                displayWidth = containerWidth;
                displayHeight = containerHeight;
                break;
            case DISPLAY_MODE_ASPECT_FILL_X:
                displayWidth = containerWidth;
                displayHeight = (int) (containerWidth / displayAspectRatio);
                break;
            case DISPLAY_MODE_ASPECT_FILL_Y:
                displayWidth = (int) (containerHeight * displayAspectRatio);
                displayHeight = containerHeight;
                break;
            case DISPLAY_MODE_ASPECT_FIT:
                if (displayAspectRatio >= containerRatio) {
                    displayWidth = containerWidth;
                    displayHeight = (int) (containerWidth / displayAspectRatio);
                } else {
                    displayWidth = (int) (containerHeight * displayAspectRatio);
                    displayHeight = containerHeight;
                }
                break;
            case DISPLAY_MODE_ASPECT_FILL:
                if (displayAspectRatio >= containerRatio) {
                    displayWidth = (int) (containerHeight * displayAspectRatio);
                    displayHeight = containerHeight;
                } else {
                    displayWidth = containerWidth;
                    displayHeight = (int) (containerWidth / displayAspectRatio);
                }
                break;
            default:
                throw new IllegalArgumentException("unknown displayMode = " + displayMode);
        }

        final LayoutParams displayLP = (LayoutParams) displayView.getLayoutParams();
        if (displayLP == null) return;
        if (displayLP.height != displayHeight
                || displayLP.width != displayWidth
                || displayLP.gravity != displayGravity) {
            displayLP.gravity = displayGravity;
            displayLP.width = displayWidth;
            displayLP.height = displayHeight;
            L.i(this, "applyDisplayMode", displayLP.gravity, displayLP.width, displayLP.height);
            displayView.requestLayout();
        }
    }

    public static float calDisplayAspectRatio(int videoWidth, int videoHeight, float sampleAspectRatio) {
        float ratio = calRatio(videoWidth, videoHeight);
        if (sampleAspectRatio > 0) {
            return ratio * sampleAspectRatio;
        }
        return ratio;
    }

    private static float calRatio(int videoWidth, int videoHeight) {
        if (videoWidth > 0 && videoHeight > 0) {
            return videoWidth / (float) videoHeight;
        }
        return 0;
    }
}
