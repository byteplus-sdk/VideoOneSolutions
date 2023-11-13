// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.content.Context;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;
import androidx.core.util.Consumer;

import com.videoone.avatars.Avatars;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveAudienceBinding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveHostAudience2Binding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveHostAudienceBinding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutLiveHostVideoBinding;
import com.vertcdemo.solution.interactivelive.event.PublishVideoStreamEvent;
import com.vertcdemo.solution.interactivelive.util.MutableBoolean;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AudienceVideoRenderHelper extends AudienceVideoPlayer {

    private final AudienceFragment mFragment;

    public AudienceVideoRenderHelper(AudienceFragment fragment, FragmentLiveAudienceBinding binding) {
        super(binding);
        this.mFragment = fragment;
    }

    public void showPlayer() {
        showLinkView(null, Collections.emptyList());
    }

    public void showLinkView(@Nullable LiveUserInfo host, @NonNull List<LiveUserInfo> users) {
        if (host == null || users.isEmpty()) { // Audience Mode
            setLayoutMode(LayoutMode.PLAYER);
            mBinding.groupLinkMultiple.setVisibility(View.GONE);
            mBinding.groupLinkSingle.setVisibility(View.GONE);
            mBinding.playerContainer.setVisibility(View.VISIBLE);

            clearObservable();
        } else if (users.size() == 1) { // Only Host & Self, One-One mode
            setLayoutMode(LayoutMode.LINK1v1);
            mBinding.playerContainer.setVisibility(View.GONE);

            mBinding.groupLinkMultiple.setVisibility(View.GONE);
            mBinding.groupLinkSingle.setVisibility(View.VISIBLE);

            showOneOneLinkView(host, users);
        } else { // Multi Link Mode
            setLayoutMode(LayoutMode.LINK1vN);
            mBinding.playerContainer.setVisibility(View.GONE);

            mBinding.groupLinkSingle.setVisibility(View.GONE);
            mBinding.groupLinkMultiple.setVisibility(View.VISIBLE);

            showMultiLinkView(host, users);
        }
    }

    private void showOneOneLinkView(LiveUserInfo host, @Size(value = 1) List<LiveUserInfo> users) {
        clearObservable();

        final LiveUserInfo self = users.get(0);

        final MutableBoolean isHostBig = new MutableBoolean(true);

        final LayoutLiveHostVideoBinding bigView = mBinding.linkSingleBig;
        final LayoutLiveHostAudience2Binding smallView = mBinding.linkSingleSmall;

        final Context context = bigView.root.getContext();
        final String myName = context.getString(R.string.name_suffix_me, self.userName);

        final Runnable updater = () -> {
            if (isHostBig.value) {
                setRemoteVideoView(host.userId, bigView.texture);
                renderUserVideoContent(host, bigView);

                LiveRTCManager.ins().setLocalVideoView(smallView.texture);
                renderUserVideoContent(self, smallView);
                smallView.userName.setText(myName); // Override my user name with a suffix
            } else {
                LiveRTCManager.ins().setLocalVideoView(bigView.texture);
                renderUserVideoContent(self, bigView);

                setRemoteVideoView(host.userId, smallView.texture);
                renderUserVideoContent(host, smallView);
            }
        };

        updater.run();

        smallView.root.setOnClickListener(v -> { // Click to toggle switch View
            isHostBig.value = !isHostBig.value;
            updater.run();
        });

        smallView.more.setVisibility(View.VISIBLE);
        smallView.more.setOnClickListener(mFragment::onAudienceLinkClicked);
    }

    private void showMultiLinkView(LiveUserInfo host, @Size(min = 2) List<LiveUserInfo> users) {
        clearObservable();

        final LayoutLiveHostAudienceBinding[] positions = {
                mBinding.position1,
                mBinding.position2,
                mBinding.position3,
                mBinding.position4,
                mBinding.position5,
                mBinding.position6,
        };

        final LayoutLiveHostVideoBinding linkHost = mBinding.linkHost;
        setRemoteVideoView(host.userId, linkHost.texture);
        renderUserVideoContent(host, linkHost);

        final String myId = SolutionDataManager.ins().getUserId();
        final String selfUserName = SolutionDataManager.ins().getUserName();
        final Context context = linkHost.root.getContext();
        final String myName = context.getString(R.string.name_suffix_me, selfUserName);

        final int renderCount = Math.min(positions.length, users.size());
        for (int i = 0; i < renderCount; i++) {
            final LiveUserInfo info = users.get(i);
            final LayoutLiveHostAudienceBinding position = positions[i];

            renderUserVideoContent(info, position);

            if (myId.equals(info.userId)) {
                LiveRTCManager.ins().setLocalVideoView(position.texture);
                position.userName.setText(myName); // Override my user name with a suffix
            } else {
                setRemoteVideoView(info.userId, position.texture);
            }
        }

        for (int i = renderCount; i < positions.length; i++) { // Hide empty positions
            final LayoutLiveHostAudienceBinding position = positions[i];
            position.root.setVisibility(View.INVISIBLE);
        }
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

    private void renderUserVideoContent(LiveUserInfo info, LayoutLiveHostVideoBinding binding) {
        binding.userAvatar.setImageResource(Avatars.byUserId(info.userId));
        binding.userAvatar.setVisibility(info.isCameraOn() ? View.GONE : View.VISIBLE);

        putObservable(info.userId, event -> {
            info.mic = event.mic;
            info.camera = event.camera;

            binding.userAvatar.setVisibility(event.isCameraOn() ? View.GONE : View.VISIBLE);
        });
    }

    private final Map<String, Consumer<PublishVideoStreamEvent>> mPublishStreamActions = new HashMap<>();

    public void onPublishStreamEvent(PublishVideoStreamEvent event) {
        final Consumer<PublishVideoStreamEvent> consumer = mPublishStreamActions.get(event.uid);
        if (consumer != null) {
            consumer.accept(event);
        }
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
}
