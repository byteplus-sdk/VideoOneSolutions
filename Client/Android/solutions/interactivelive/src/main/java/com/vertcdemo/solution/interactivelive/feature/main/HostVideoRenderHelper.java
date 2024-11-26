// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.content.Context;
import android.os.SystemClock;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.Size;
import androidx.core.util.Consumer;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveHostBinding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveCoHostVideoBinding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveHostAudience2Binding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveHostAudienceBinding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveHostVideoBinding;
import com.vertcdemo.solution.interactivelive.event.PublishVideoStreamEvent;
import com.vertcdemo.solution.interactivelive.util.MutableBoolean;
import com.videoone.avatars.Avatars;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class HostVideoRenderHelper extends MediaStatusObservable {
    private final FragmentLiveHostBinding mBinding;

    private final Map<String, Consumer<PublishVideoStreamEvent>> mPublishStreamActions = new HashMap<>();

    private final LayoutLiveHostAudienceBinding[] mPositions;

    public HostVideoRenderHelper(FragmentLiveHostBinding binding, @Nullable View.OnClickListener onAddListener) {
        this.mBinding = binding;
        mPositions = new LayoutLiveHostAudienceBinding[]{
                mBinding.position1,
                mBinding.position2,
                mBinding.position3,
                mBinding.position4,
                mBinding.position5,
                mBinding.position6,
        };
        setupOnAddListener(onAddListener);
    }

    private void setupOnAddListener(View.OnClickListener onAddListener) {
        for (LayoutLiveHostAudienceBinding position : mPositions) {
            position.empty.setOnClickListener(onAddListener);
            position.emptyTips.setText(R.string.add_guest);
        }
    }

    private long mPkStartTime = -1;

    public void onPublishStreamEvent(PublishVideoStreamEvent event) {
        final Consumer<PublishVideoStreamEvent> consumer = mPublishStreamActions.get(event.uid);
        if (consumer != null) {
            consumer.accept(event);
        }
    }

    public void setLiveUserInfo() {
        setLiveUserInfo(null);
    }

    public void setLiveUserInfo(@Nullable LiveUserInfo coHost) {
        if (coHost == null) { 
            clearObservable();
            stopPkTiming();

            mBinding.groupPk.setVisibility(View.GONE);
            mBinding.groupLink.setVisibility(View.GONE);
            mBinding.main.root.setVisibility(View.VISIBLE);

            LayoutLiveHostVideoBinding main = mBinding.main;

            final LiveUserInfo self = selfLiveUserInfo();
            renderUserVideoContent(self, main);

            LiveRTCManager.ins().setLocalVideoView(main.texture);
        } else {
            clearObservable();
            mBinding.main.root.setVisibility(View.GONE);
            mBinding.groupLink.setVisibility(View.GONE);
            mBinding.groupPk.setVisibility(View.VISIBLE);

            startPkTiming();

            final LiveUserInfo self = selfLiveUserInfo();
            showPKView(self, coHost);
        }
    }

    private void showPKView(LiveUserInfo self, LiveUserInfo coHost) {
        final LayoutLiveHostVideoBinding selfPosition = mBinding.pkHost;
        renderUserVideoContent(self, selfPosition);
        LiveRTCManager.ins().setLocalVideoView(selfPosition.texture);

        clearPublishStreamActions();
        final LayoutLiveCoHostVideoBinding position = mBinding.pkCoHost;
        renderUserVideoContent(coHost, position);
        setRemoteVideoView(coHost.userId, position.texture);
    }

    public void addLinkUserInfo(@Nullable List<LiveUserInfo> users) {
        clearPublishStreamActions();

        if (users == null || users.isEmpty()) {
            stopPkTiming();
            clearObservable();

            mBinding.groupPk.setVisibility(View.GONE);
            mBinding.groupLink.setVisibility(View.GONE);
            mBinding.main.root.setVisibility(View.VISIBLE);

            LayoutLiveHostVideoBinding main = mBinding.main;

            final LiveUserInfo self = selfLiveUserInfo();
            renderUserVideoContent(self, main);
            LiveRTCManager.ins().setLocalVideoView(main.texture);
        } else {
            stopPkTiming();
            if (users.size() == 1) {
                mBinding.groupPk.setVisibility(View.GONE);
                mBinding.groupLinkMultiple.setVisibility(View.GONE);

                mBinding.main.root.setVisibility(View.VISIBLE);
                mBinding.groupLinkSingle.setVisibility(View.VISIBLE);

                showOneOneLinkView(users);
            } else {
                mBinding.groupPk.setVisibility(View.GONE);
                mBinding.main.root.setVisibility(View.GONE);
                mBinding.groupLinkSingle.setVisibility(View.GONE);

                mBinding.groupLinkMultiple.setVisibility(View.VISIBLE);

                showMultiLinkView(users);
            }
        }
    }

    private LiveUserInfo selfLiveUserInfo() {
        final LiveUserInfo info = new LiveUserInfo();
        info.userId = SolutionDataManager.ins().getUserId();
        info.userName = SolutionDataManager.ins().getUserName();
        info.mic = LiveRTCManager.ins().isMicOn() ? MediaStatus.ON : MediaStatus.OFF;
        info.camera = LiveRTCManager.ins().isCameraOn() ? MediaStatus.ON : MediaStatus.OFF;
        return info;
    }

    private void showOneOneLinkView(@Size(value = 1) List<LiveUserInfo> users) {
        final LiveUserInfo self = selfLiveUserInfo();
        final LiveUserInfo audience = users.get(0);

        final MutableBoolean isHostBig = new MutableBoolean(true);

        final LayoutLiveHostVideoBinding bigView = mBinding.main;
        final LayoutLiveHostAudience2Binding smallView = mBinding.linkSingleSmall;

        final Context context = bigView.root.getContext();
        final String myName = context.getString(R.string.name_suffix_me, self.userName);

        final Runnable updater = () -> {
            clearObservable();

            if (isHostBig.value) {
                LiveRTCManager.ins().setLocalVideoView(bigView.texture);
                renderUserVideoContent(self, bigView);

                setRemoteVideoView(audience.userId, smallView.texture);
                renderUserVideoContent(audience, smallView);
            } else {
                setRemoteVideoView(audience.userId, bigView.texture);
                renderUserVideoContent(audience, bigView);

                LiveRTCManager.ins().setLocalVideoView(smallView.texture);

                renderUserVideoContent(self, smallView);
                smallView.userName.setText(myName); // rewrite user name with a '(me)' suffix
            }
        };

        updater.run();

        smallView.root.setOnClickListener(v -> { // Click to toggle switch View
            isHostBig.value = !isHostBig.value;
            updater.run();
        });
    }

    private void showMultiLinkView(@Size(min = 2) List<LiveUserInfo> users) {
        clearObservable();
        final LiveUserInfo self = selfLiveUserInfo();
        LayoutLiveHostVideoBinding linkHost = mBinding.linkHost;
        LiveRTCManager.ins().setLocalVideoView(mBinding.linkHost.texture);
        renderUserVideoContent(self, linkHost);

        for (int i = 0; i < mPositions.length; i++) {
            LayoutLiveHostAudienceBinding position = mPositions[i];
            if (i >= users.size()) {
                position.noneEmpty.setVisibility(View.INVISIBLE);
                position.empty.setVisibility(View.VISIBLE);
            } else {
                position.empty.setVisibility(View.GONE);
                position.userName.setVisibility(View.VISIBLE);
                position.texture.setVisibility(View.VISIBLE);

                final LiveUserInfo info = users.get(i);
                setRemoteVideoView(info.userId, position.texture);
                renderUserVideoContent(info, position);
            }
        }
    }

    public void startPkTiming() {
        if (mPkStartTime < 0) {
            mPkStartTime = SystemClock.uptimeMillis();
        }
    }

    public void stopPkTiming() {
        mPkStartTime = -1;
        mBinding.pkTiming.setText(R.string.duration_zero);
    }

    public void timeTick() {
        if (mPkStartTime <= 0) {
            return;
        }
        long durationInSeconds = (SystemClock.uptimeMillis() - mPkStartTime) / 1000;
        long seconds = durationInSeconds % 60;
        long minutes = durationInSeconds / 60;
        mBinding.pkTiming.setText(String.format(Locale.ENGLISH, "%1$02d:%2$02d", minutes,
                seconds));
    }

    public void setRemoteVideoView(String uid, TextureView view) {
        final LiveRTCManager manager = LiveRTCManager.ins();
        manager.setRemoteVideoView(uid, view);
        registerPublishStreamAction(uid, event -> manager.setRemoteVideoView(uid, view));
    }

    void clearPublishStreamActions() {
        mPublishStreamActions.clear();
    }

    void registerPublishStreamAction(String userId, Consumer<PublishVideoStreamEvent> action) {
        mPublishStreamActions.put(userId, action);
    }

    private void renderUserVideoContent(LiveUserInfo info, LayoutLiveHostVideoBinding binding) {
        binding.userAvatar.setImageResource(Avatars.byUserId(info.userId));
        binding.userAvatar.setVisibility(info.isCameraOn() ? View.GONE : View.VISIBLE);

        putObservable(info.userId, event -> {
            info.mic = event.mic;
            info.camera = event.camera;

            binding.userAvatar.setVisibility(event.isCameraOn() ? View.GONE : View.VISIBLE);
        });
    }

    private void renderUserVideoContent(LiveUserInfo info, LayoutLiveHostAudience2Binding position) {
        position.userName.setText(info.userName);

        position.userAvatar.setImageResource(Avatars.byUserId(info.userId));
        position.userAvatar.setVisibility(info.isCameraOn() ? View.GONE : View.VISIBLE);

        position.mute.setVisibility(info.isMicOn() ? View.GONE : View.VISIBLE);
        putObservable(info.userId, event -> {
            info.camera = event.camera;
            info.mic = event.mic;
            position.mute.setVisibility(event.isMicOn() ? View.GONE : View.VISIBLE);
            position.userAvatar.setVisibility(event.isCameraOn() ? View.GONE : View.VISIBLE);
        });
    }

    private void renderUserVideoContent(LiveUserInfo info, LayoutLiveHostAudienceBinding position) {
        position.userName.setText(info.userName);

        position.userAvatar.setImageResource(Avatars.byUserId(info.userId));
        position.userAvatar.setVisibility(info.isCameraOn() ? View.GONE : View.VISIBLE);

        position.mute.setVisibility(info.isMicOn() ? View.GONE : View.VISIBLE);
        putObservable(info.userId, event -> {
            info.camera = event.camera;
            info.mic = event.mic;
            position.mute.setVisibility(event.isMicOn() ? View.GONE : View.VISIBLE);
            position.userAvatar.setVisibility(event.isCameraOn() ? View.GONE : View.VISIBLE);
        });
    }

    private void renderUserVideoContent(LiveUserInfo info, LayoutLiveCoHostVideoBinding position) {
        final int userAvatar = Avatars.byUserId(info.userId);
        Glide.with(position.userAvatar)
                .load(userAvatar)
                .centerCrop()
                .into(position.userAvatar);

        Glide.with(position.userAvatarSmall)
                .load(userAvatar)
                .into(position.userAvatarSmall);
        position.userName.setText(info.userName);

        position.mute.setVisibility(info.isMicOn() ? View.GONE : View.VISIBLE);
        position.userAvatar.setVisibility(info.isCameraOn() ? View.GONE : View.VISIBLE);

        putObservable(info.userId, event -> {
            info.mic = event.mic;
            info.camera = event.camera;

            position.mute.setVisibility(event.isMicOn() ? View.GONE : View.VISIBLE);
            position.userAvatar.setVisibility(event.isCameraOn() ? View.GONE : View.VISIBLE);
        });
    }
}
