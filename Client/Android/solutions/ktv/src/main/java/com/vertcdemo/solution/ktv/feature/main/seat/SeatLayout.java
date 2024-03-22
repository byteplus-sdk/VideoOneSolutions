// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.seat;

import android.animation.Keyframe;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.bumptech.glide.Glide;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.SeatInfo;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.databinding.LayoutKtvSeatBinding;
import com.videoone.avatars.Avatars;

public class SeatLayout extends ConstraintLayout {
    private static final String TAG = "SeatLayout";

    public SeatLayout(@NonNull Context context) {
        super(context);
    }

    public SeatLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public SeatLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public SeatLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    private LayoutKtvSeatBinding mBinding;

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        mBinding = LayoutKtvSeatBinding.bind(this);
    }

    private final SeatInfo mSeatInfo = new SeatInfo();

    private int mSeatId = -1;

    public void setSeatId(int index) {
        mSeatId = index;
    }

    public int getSeatId() {
        return mSeatId;
    }

    public SeatInfo getSeatInfo() {
        return mSeatInfo;
    }

    public void setSeatInfo(@NonNull SeatInfo info) {
        UserInfo userInfo = info.userInfo;
        mSeatInfo.setStatusAndUser(info.status, userInfo);
        if (userInfo != null) {
            updateUserView(userInfo);
        } else {
            updateEmptyView(info);
        }
    }

    public void clearSeat() {
        endSpeakingIndicatorAnimator();
        mSeatInfo.clearUser();
        updateEmptyView(mSeatInfo);
    }

    private void updateUserView(@NonNull UserInfo userInfo) {
        Glide.with(mBinding.seatIcon)
                .load(Avatars.byUserId(userInfo.userId))
                .into(mBinding.seatIcon);

        mBinding.seatName.setText(userInfo.userName);
        mBinding.seatMuted.setVisibility(userInfo.isMicOn() ? View.GONE : View.VISIBLE);
    }

    private void updateEmptyView(SeatInfo info) {
        mBinding.seatMuted.setVisibility(View.GONE);
        if (info.isLocked()) {
            mBinding.seatIcon.setImageResource(R.drawable.ic_ktv_seat_locked);
        } else {
            mBinding.seatIcon.setImageResource(R.drawable.ic_ktv_seat_empty);
        }
        mBinding.seatName.setText(String.valueOf(mSeatId));
        mBinding.singerLabel.setVisibility(View.GONE);
    }

    public void initWithIndex(int index) {
        setSeatId(index);
        updateEmptyView(mSeatInfo);
    }

    public boolean updateMicStatus(String userId, boolean micOn) {
        UserInfo userInfo = mSeatInfo.userInfo;
        if (userInfo != null && userInfo.userId.equals(userId)) {
            userInfo.setMicStatus(micOn);
            if (micOn) {
                mBinding.seatMuted.setVisibility(View.GONE);
            } else {
                mBinding.seatMuted.setVisibility(View.VISIBLE);
                updateSpeakingStatus(userId, false);
            }
            return true;
        } else {
            return false;
        }
    }

    public void updateSeatLockStatus(int status) {
        mSeatInfo.status = status;
        if (mSeatInfo.userInfo == null) {
            updateEmptyView(mSeatInfo);
        }
    }

    private ObjectAnimator startSpeakingIndicatorAnimator() {
        PropertyValuesHolder scaleX = PropertyValuesHolder.ofKeyframe(View.SCALE_X,
                Keyframe.ofFloat(0F, 0.81F),
                Keyframe.ofFloat(0.27F, 1F),
                Keyframe.ofFloat(1F, 1F));

        PropertyValuesHolder scaleY = PropertyValuesHolder.ofKeyframe(View.SCALE_Y,
                Keyframe.ofFloat(0F, 0.81F),
                Keyframe.ofFloat(0.27F, 1F),
                Keyframe.ofFloat(1F, 1F));

        PropertyValuesHolder alpha = PropertyValuesHolder.ofKeyframe(View.ALPHA,
                Keyframe.ofFloat(0F, 0F),
                Keyframe.ofFloat(0.27F, .4F),
                Keyframe.ofFloat(1F, .2F));

        ObjectAnimator animator = ObjectAnimator.ofPropertyValuesHolder(
                mBinding.seatSpeakingIndicator,
                scaleX, scaleY, alpha);
        animator.setRepeatMode(ObjectAnimator.RESTART);
        animator.setRepeatCount(ObjectAnimator.INFINITE);
        animator.setDuration(1100);
        animator.start();
        return animator;
    }

    private void endSpeakingIndicatorAnimator() {
        if (mSpeakingAnimator != null) {
            mSpeakingAnimator.cancel();
            mSpeakingAnimator = null;
        }
        mBinding.seatSpeakingIndicator.setVisibility(View.GONE);
    }

    @Nullable
    private ObjectAnimator mSpeakingAnimator;

    public boolean updateSpeakingStatus(String userId, boolean isSpeaking) {
        UserInfo userInfo = mSeatInfo.userInfo;
        if (userInfo != null && userInfo.userId.equals(userId)) {
            // Upon joining the RTC room, BytePlus will consistently trigger the
            // onRemoteAudioPropertiesReport/onLocalAudioPropertiesReport callbacks every 500ms.
            // Therefore, it's also necessary to verify the Microphone status on the Business Server.
            if (isSpeaking && userInfo.isMicOn()) {
                if (mSpeakingAnimator == null) {
                    mBinding.seatSpeakingIndicator.setVisibility(View.VISIBLE);
                    mSpeakingAnimator = startSpeakingIndicatorAnimator();
                } else {
                    // Animating, skip
                }
            } else {
                endSpeakingIndicatorAnimator();
            }
            return true;
        } else {
            return false;
        }
    }

    public void updateSingStatus(@Nullable String ownerUid) {
        int index = mSeatId;
        if (index == -1) {
            mBinding.singerLabel.setVisibility(View.GONE);
            return;
        }
        UserInfo userInfo = mSeatInfo.userInfo;
        if (userInfo == null) {
            mBinding.singerLabel.setVisibility(View.GONE);
            return;
        }

        String positionUId = userInfo.userId;
        if (!TextUtils.isEmpty(positionUId) && TextUtils.equals(positionUId, ownerUid)) {
            mBinding.seatName.setText(R.string.label_seat_singer);
            mBinding.singerLabel.setVisibility(View.VISIBLE);
        } else if (!TextUtils.isEmpty(userInfo.userName)) {
            mBinding.seatName.setText(userInfo.userName);
            mBinding.singerLabel.setVisibility(View.GONE);
        } else {
            mBinding.seatName.setText(String.valueOf(index));
            mBinding.singerLabel.setVisibility(View.GONE);
        }
    }
}
