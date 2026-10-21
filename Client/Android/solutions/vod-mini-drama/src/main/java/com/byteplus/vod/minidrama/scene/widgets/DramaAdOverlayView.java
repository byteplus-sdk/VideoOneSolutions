// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.MotionEvent;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.byteplus.minidrama.R;

import java.util.Locale;

/**
 * Display-only overlay shown on top of an in-stream ad. Owns a display-only progress bar,
 * a "mm:ss / mm:ss" progress-time label, and a non-interactive "Advertising" banner.
 * All touches pass through to the underlying ad view.
 */
public class DramaAdOverlayView extends FrameLayout {

    private static final int BANNER_HEIGHT_DP = 24;
    private static final int BANNER_HORIZONTAL_PADDING_DP = 14;
    private static final int BANNER_MARGIN_DP = 12;
    private static final int BANNER_TOP_MARGIN_DP = 8;
    private static final int PROGRESS_BAR_HEIGHT_DP = 2;
    private static final int PROGRESS_BAR_THUMB_DIAMETER_DP = 8;
    private static final int PROGRESS_BAR_SIDE_INSET_DP = 12;
    private static final int TIME_LABEL_BOTTOM_MARGIN_DP = 6;
    private static final int TIME_LABEL_HORIZONTAL_PADDING_DP = 8;
    private static final int TIME_LABEL_VERTICAL_PADDING_DP = 2;

    private SeekBar mProgressBar;
    private TextView mTimeLabel;
    private TextView mBannerLabel;

    public DramaAdOverlayView(@NonNull Context context) {
        super(context);
        init();
    }

    private void init() {
        // touches pass through to the underlying ad view
        setClickable(false);
        setFocusable(false);

        // "Advertising" banner: pill-shaped translucent background, top-left
        mBannerLabel = new TextView(getContext());
        mBannerLabel.setText(R.string.vevod_mini_drama_ad_advertising);
        mBannerLabel.setTextColor(Color.WHITE);
        mBannerLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        mBannerLabel.setGravity(Gravity.CENTER);
        mBannerLabel.setBackground(
                ContextCompat.getDrawable(getContext(), R.drawable.vevod_mini_drama_ad_overlay_banner_bg));
        final int hPad = dp(BANNER_HORIZONTAL_PADDING_DP);
        mBannerLabel.setPadding(hPad, 0, hPad, 0);
        LayoutParams bannerParams = new LayoutParams(
                LayoutParams.WRAP_CONTENT, dp(BANNER_HEIGHT_DP), Gravity.START | Gravity.TOP);
        bannerParams.leftMargin = dp(BANNER_MARGIN_DP);
        bannerParams.topMargin = dp(BANNER_TOP_MARGIN_DP);
        addView(mBannerLabel, bannerParams);

        // display-only progress bar pinned to the bottom
        mProgressBar = new SeekBar(getContext()) {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouchEvent(MotionEvent event) {
                return false; // never consume: display-only, let touches fall through
            }
        };
        mProgressBar.setMax(1000);
        mProgressBar.setProgress(0);
        mProgressBar.setFocusable(false);
        mProgressBar.setSplitTrack(false);
        mProgressBar.setProgressDrawable(
                ContextCompat.getDrawable(getContext(), R.drawable.vevod_mini_drama_ad_overlay_progress));
        mProgressBar.setThumb(
                ContextCompat.getDrawable(getContext(), R.drawable.vevod_mini_drama_ad_overlay_thumb));
        mProgressBar.setThumbOffset(0);
        mProgressBar.setMinimumHeight(dp(PROGRESS_BAR_HEIGHT_DP));
        mProgressBar.setPadding(0, 0, 0, 0);
        LayoutParams progressParams = new LayoutParams(
                LayoutParams.MATCH_PARENT, dp(PROGRESS_BAR_THUMB_DIAMETER_DP), Gravity.BOTTOM);
        progressParams.leftMargin = dp(PROGRESS_BAR_SIDE_INSET_DP);
        progressParams.rightMargin = dp(PROGRESS_BAR_SIDE_INSET_DP);
        addView(mProgressBar, progressParams);

        // "mm:ss / mm:ss" time label above the progress bar, left-aligned to the track.
        // translucent rounded pill background as the banner so the white
        // text stays legible over bright ad content
        mTimeLabel = new TextView(getContext());
        mTimeLabel.setTextColor(Color.WHITE);
        mTimeLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        mTimeLabel.setText(formatTime(0) + " / " + formatTime(0));
        mTimeLabel.setBackground(
                ContextCompat.getDrawable(getContext(), R.drawable.vevod_mini_drama_ad_overlay_banner_bg));
        final int timePad = dp(TIME_LABEL_HORIZONTAL_PADDING_DP);
        mTimeLabel.setPadding(timePad, dp(TIME_LABEL_VERTICAL_PADDING_DP), timePad, dp(TIME_LABEL_VERTICAL_PADDING_DP));
        LayoutParams timeParams = new LayoutParams(
                LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.BOTTOM | Gravity.START);
        timeParams.leftMargin = dp(PROGRESS_BAR_SIDE_INSET_DP);
        timeParams.bottomMargin = dp(PROGRESS_BAR_THUMB_DIAMETER_DP) + dp(TIME_LABEL_BOTTOM_MARGIN_DP);
        addView(mTimeLabel, timeParams);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        applyBottomInset();
    }

    private void applyBottomInset() {
        WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(this);
        if (insets != null) {
            int bottom = insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom;
            setPadding(getPaddingLeft(), getPaddingTop(), getPaddingRight(), bottom);
        }
    }

    // touches fall through to the ad view below
    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return false;
    }

    /**
     * Updates the progress bar and the "mm:ss / mm:ss" label
     */
    public void updateProgress(long currentTimeMs, long totalTimeMs) {
        if (totalTimeMs <= 0) {
            return;
        }
        int progress = (int) (mProgressBar.getMax() * currentTimeMs / (double) totalTimeMs);
        mProgressBar.setProgress(Math.max(0, Math.min(mProgressBar.getMax(), progress)));
        mTimeLabel.setText(formatTime(currentTimeMs) + " / " + formatTime(totalTimeMs));
    }

    /**
     * Resets progress
     */
    public void reset() {
        mProgressBar.setProgress(0);
        mTimeLabel.setText(formatTime(0) + " / " + formatTime(0));
    }

    private int dp(int value) {
        return (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, value, getResources().getDisplayMetrics());
    }

    private static String formatTime(long timeMs) {
        if (timeMs < 0) {
            timeMs = 0;
        }
        long timeS = timeMs / 1000;
        return String.format(Locale.US, "%02d:%02d", timeS / 60, timeS % 60);
    }
}
