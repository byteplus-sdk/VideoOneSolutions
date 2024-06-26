// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.TimeInterpolator;
import android.animation.ValueAnimator;
import android.text.TextUtils;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;

import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.LayoutChorusNetworkStatusBinding;
import com.bytedance.chrous.databinding.LayoutChorusSingerBinding;
import com.vertcdemo.core.event.NetworkStatusEvent;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;
import com.vertcdemo.solution.chorus.event.SDKAudioVolumeEvent;
import com.vertcdemo.solution.chorus.feature.room.bean.SingerData;
import com.videoone.avatars.Avatars;

import java.util.Objects;

public class ChorusSingerManager {
    final ChorusRoomViewModel viewModel;

    final LayoutChorusSingerBinding binding;
    final LayoutChorusNetworkStatusBinding networkStatus;

    public ChorusSingerManager(LayoutChorusSingerBinding binding,
                               LayoutChorusNetworkStatusBinding networkStatus,
                               ChorusRoomViewModel viewModel) {
        this.binding = binding;
        this.networkStatus = networkStatus;
        this.viewModel = viewModel;
        mValueAnimator = createVolumeAnimation(binding.animation);
    }

    private final ValueAnimator mValueAnimator;

    private SingerData data;

    public String getUserId() {
        return data == null ? null : data.getUserId();
    }

    public boolean isMicOn() {
        return data != null && data.isMicOn();
    }

    public void setSingerData(SingerData data) {
        this.data = Objects.requireNonNull(data);

        if (TextUtils.isEmpty(data.getUserId())) {
            binding.avatar.setImageResource(R.drawable.ic_chorus_seat_empty);
        } else {
            binding.avatar.setImageResource(Avatars.byUserId(data.getUserId()));
        }
        binding.avatar.setSelected(data.isMicOn());

        if (data.hasVideo) {
            networkStatus.getRoot().setVisibility(View.VISIBLE);
            binding.video.setVisibility(View.VISIBLE);

            setRenderVideoView(data, binding.video);

            binding.groupAvatar.setVisibility(View.GONE);
        } else {
            binding.groupAvatar.setVisibility(View.VISIBLE);

            networkStatus.getRoot().setVisibility(View.GONE);
            binding.video.setVisibility(View.GONE);

            removeRenderVideoView(binding.video);
        }
    }

    public void setNetworkStatus(NetworkStatusEvent event) {
        String userId = getUserId();
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        NetworkStatusEvent.Quality quality = event.get(userId);
        switch (quality) {
            case GOOD:
                networkStatus.statusText.setVisibility(View.VISIBLE);
                networkStatus.statusIcon.setVisibility(View.VISIBLE);

                networkStatus.statusText.setText(R.string.net_quality_good);
                networkStatus.statusIcon.setImageLevel(2);
                break;
            case POOR:
                networkStatus.statusText.setVisibility(View.VISIBLE);
                networkStatus.statusIcon.setVisibility(View.VISIBLE);

                networkStatus.statusText.setText(R.string.net_quality_poor);
                networkStatus.statusIcon.setImageLevel(1);
                break;
            case BAD:
                networkStatus.statusText.setVisibility(View.VISIBLE);
                networkStatus.statusIcon.setVisibility(View.VISIBLE);

                networkStatus.statusText.setText(R.string.net_quality_disconnect);
                networkStatus.statusIcon.setImageLevel(0);
                break;
            case UNKNOWN:
            default: {
                networkStatus.statusText.setVisibility(View.GONE);
                networkStatus.statusIcon.setVisibility(View.GONE);
            }
        }
    }

    public void setAudioVolumeEvent(SDKAudioVolumeEvent event) {
        if (data.hasVideo || !isMicOn()) {
            return;
        }

        if (TextUtils.equals(data.getUserId(), event.userId)) {
            if (event.isSpeaking && isMicOn()) {
                mValueAnimator.start();
            }
        }
    }

    private static ObjectAnimator createVolumeAnimation(View view) {
        ObjectAnimator animator = ObjectAnimator.ofFloat(view, View.ALPHA, 0F, 0.8F, 0F);
        animator.setInterpolator(new DecelerateAccelerateInterpolator());
        animator.setDuration(1600);
        animator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                view.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(@NonNull Animator animation) {
                view.setVisibility(View.INVISIBLE);
            }
        });

        return animator;
    }

    private void setRenderVideoView(SingerData data, TextureView videoView) {
        String userId = Objects.requireNonNull(data.getUserId());
        if (viewModel.myUserId().equals(userId)) {
            ChorusRTCManager.ins().setLocalVideoCanvas(videoView);
        } else {
            ChorusRTCManager.ins().setRemoteVideoCanvas(viewModel.requireRoomId(), userId, videoView);
        }
        videoView.setTag(R.id.tag_user_id, userId);
    }

    private void removeRenderVideoView(TextureView videoView) {
        String userId = (String) videoView.getTag(R.id.tag_user_id);
        if (!TextUtils.isEmpty(userId)) {
            if (viewModel.myUserId().equals(userId)) {
                ChorusRTCManager.ins().setLocalVideoCanvas(null);
            } else {
                ChorusRTCManager.ins().setRemoteVideoCanvas(viewModel.requireRoomId(), userId, null);
            }
            videoView.setTag(R.id.tag_user_id, null);
        }
    }

    private static class DecelerateAccelerateInterpolator implements TimeInterpolator {
        @Override
        public float getInterpolation(float input) {
            float result;
            if (input <= 0.5) {
                result = (float) (Math.sin(Math.PI * input)) / 2;
            } else {
                result = (float) (2 - Math.sin(Math.PI * input)) / 2;
            }
            return result;
        }
    }
}
