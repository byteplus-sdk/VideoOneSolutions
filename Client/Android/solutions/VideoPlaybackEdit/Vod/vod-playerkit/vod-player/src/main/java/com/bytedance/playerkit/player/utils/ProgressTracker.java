// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.utils;

import android.os.Handler;
import android.os.Looper;

import com.bytedance.playerkit.utils.L;

public class ProgressTracker {
    private final Handler mHandler;
    private ProgressTaskListener mProgressTaskListener;
    private boolean mTrackingProgress = false;

    private final Runnable mTrackingProgressRunnable = new Runnable() {
        @Override
        public void run() {
            if (mProgressTaskListener == null) {
                stopTrackingProgress();
                return;
            }

            final long delay = mProgressTaskListener.onTrackingProgress();
            if (delay >= 0) {
                mHandler.postDelayed(this, delay);
            } else {
                stopTrackingProgress();
            }
        }
    };

    public ProgressTracker(final Looper looper, final ProgressTaskListener progressTaskListener) {
        mHandler = new Handler(looper);
        mProgressTaskListener = progressTaskListener;
    }

    public void startTrackingProgress() {
        if (mTrackingProgress) {
            return;
        }
        mTrackingProgress = true;
        L.d(this, "startTrackingProgress");
        mHandler.removeCallbacks(mTrackingProgressRunnable);
        mHandler.post(mTrackingProgressRunnable);
    }

    public void stopTrackingProgress() {

        if (!mTrackingProgress) {
            return;
        }
        mTrackingProgress = false;

        L.d(this, "stopTrackingProgress");
        mHandler.removeCallbacks(mTrackingProgressRunnable);
    }

    public void release() {
        L.d(this, "release");
        mTrackingProgress = false;
        mHandler.removeCallbacksAndMessages(null);
        mProgressTaskListener = null;
    }

    public interface ProgressTaskListener {
        long onTrackingProgress();
    }
}
