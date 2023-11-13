// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.widgets;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.bytedance.vod.scenekit.utils.TimeUtils;
import com.bytedance.vod.scenekit.R;


public class MediaSeekBar extends RelativeLayout {

    public enum TimeMode {
        DURATION, REMINDING
    }

    private final TextView text1;
    private final SeekBar seekBar;
    private final TextView text2;

    private boolean mTouchSeeking;
    private long mDuration;

    private OnUserSeekListener mOnUserSeekListener;

    private TimeMode mTimeMode = TimeMode.DURATION;

    public interface OnUserSeekListener {
        void onUserSeekStart(long startPosition);

        void onUserSeekPeeking(long peekPosition);

        void onUserSeekStop(long startPosition, long seekToPosition);
    }

    public MediaSeekBar(Context context) {
        this(context, null);
    }

    public MediaSeekBar(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MediaSeekBar(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        LayoutInflater.from(getContext()).inflate(R.layout.vevod_media_player_seekbar, this);
        text1 = findViewById(R.id.text1);
        text2 = findViewById(R.id.text2);
        seekBar = findViewById(R.id.seekBar);

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {

            int mStartSeekProgress = 0;

            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                final float percent = progress / (float) seekBar.getMax();
                final long currentPosition = (int) (percent * mDuration);
                text1.setText(TimeUtils.time2String(currentPosition));
                if (mTimeMode == TimeMode.REMINDING) {
                    final long remaining = mDuration - currentPosition;
                    text2.setText(TimeUtils.time2String(remaining));
                } else {
                    text2.setText(TimeUtils.time2String(mDuration));
                }

                if (!mTouchSeeking) return;
                if (mOnUserSeekListener != null && fromUser) {
                    mOnUserSeekListener.onUserSeekPeeking(currentPosition);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                if (mTouchSeeking) return;
                mTouchSeeking = true;
                mStartSeekProgress = seekBar.getProgress();
                final float startSeekPercent = mStartSeekProgress / (float) seekBar.getMax();
                final long startSeekPosition = (long) (startSeekPercent * mDuration);

                if (mOnUserSeekListener != null) {
                    mOnUserSeekListener.onUserSeekStart(startSeekPosition);
                }
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (!mTouchSeeking) return;
                mTouchSeeking = false;
                final float startSeekPercent = mStartSeekProgress / (float) seekBar.getMax();
                final float currentPercent = seekBar.getProgress() / (float) seekBar.getMax();

                final long startSeekPosition = (long) (startSeekPercent * mDuration);
                final long currentPosition = (long) (currentPercent * mDuration);

                if (mOnUserSeekListener != null) {
                    mOnUserSeekListener.onUserSeekStop(startSeekPosition, currentPosition);
                }
            }
        });
    }

    public void setDuration(long duration) {
        this.mDuration = duration;
        this.seekBar.setMax(Math.max((int) (mDuration / 1000), 100));
    }

    public void setCurrentPosition(long currentPosition) {
        if (!mTouchSeeking) {
            final int progress = (int) (currentPosition / (float) mDuration * seekBar.getMax());
            seekBar.setProgress(progress);
        }
    }

    public void setCachePercent(int cachePercent) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            // Android 5 (21,22) SeekBar render issue, so we disable the secondary progress
            return;
        }
        seekBar.setSecondaryProgress((int) (cachePercent * (seekBar.getMax() / 100f)));
    }

    public void setOnSeekListener(OnUserSeekListener listener) {
        this.mOnUserSeekListener = listener;
    }

    public void setSeekEnabled(boolean enabled) {
        seekBar.setEnabled(enabled);
    }

    public void setTextVisibility(boolean visibility) {
        text1.setVisibility(visibility ? VISIBLE : GONE);
        text2.setVisibility(visibility ? VISIBLE : GONE);
    }

    @SuppressLint("ClickableViewAccessibility")
    public void enableHideThumb() {
        seekBar.setSplitTrack(false);
        seekBar.getThumb().mutate().setAlpha(0);
        seekBar.setOnTouchListener((v, event) -> {
            int actionMasked = event.getActionMasked();
            if (actionMasked == MotionEvent.ACTION_DOWN) {
                seekBar.getThumb().mutate().setAlpha(255);
            } else if (actionMasked == MotionEvent.ACTION_UP || actionMasked == MotionEvent.ACTION_CANCEL) {
                seekBar.getThumb().mutate().setAlpha(0);
            }
            return false;
        });
    }

    public void setTimeMode(TimeMode mode) {
        mTimeMode = mode;
    }
}
