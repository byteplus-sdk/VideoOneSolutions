// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import static android.appwidget.AppWidgetManager.EXTRA_HOST_ID;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_ROOM_ID;

import android.content.Context;
import android.os.Bundle;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.bumptech.glide.Glide;
import com.vertcdemo.solution.interactivelive.feature.main.audiencelink.RequestAudienceLinkDialog;
import com.vertcdemo.solution.interactivelive.feature.main.chat.LiveChatAdapter;
import com.vertcdemo.solution.interactivelive.feature.main.chat.LiveChatItemDecoration;
import com.videoone.avatars.Avatars;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.RTCReconnectToRoomEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.JoinLiveRoomResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveReconnectResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.annotation.InviteReply;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveFinishType;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveLinkMicStatus;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;
import com.vertcdemo.solution.interactivelive.core.annotation.LivePermitType;
import com.vertcdemo.solution.interactivelive.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.core.annotation.MessageType;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveAudienceBinding;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkInviteEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkKickEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkPermitEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkStatusEvent;
import com.vertcdemo.solution.interactivelive.event.InviteAudienceEvent;
import com.vertcdemo.solution.interactivelive.event.LinkMicStatusEvent;
import com.vertcdemo.solution.interactivelive.event.LiveFinishEvent;
import com.vertcdemo.solution.interactivelive.event.LiveKickUserEvent;
import com.vertcdemo.solution.interactivelive.event.LiveModeChangeEvent;
import com.vertcdemo.solution.interactivelive.event.LiveRTSUserEvent;
import com.vertcdemo.solution.interactivelive.event.LocalUpdatePullStreamEvent;
import com.vertcdemo.solution.interactivelive.event.MessageEvent;
import com.vertcdemo.solution.interactivelive.event.PublishVideoStreamEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaControlEvent;
import com.vertcdemo.solution.interactivelive.util.CenteredToast;
import com.vertcdemo.solution.interactivelive.util.ViewUtils;
import com.vertcdemo.solution.interactivelive.view.LiveSendMessageInputDialog;
import com.vertcdemo.core.utils.DebounceClickListener;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;


public class AudienceFragment extends Fragment {
    private static final String TAG = "AudienceFragment";

    @RoomStatus
    private int mRoomStatus = RoomStatus.LIVE;

    @RoomStatus
    int getRoomStatus() {
        return mRoomStatus;
    }

    public void setRoomStatus(@RoomStatus int status) {
        mRoomStatus = status;

    }

    private String mRTSToken;
    // Own information
    private LiveUserInfo mSelfInfo;

    public void setSelfInfo(LiveUserInfo self) {
        mSelfInfo = self;
    }

    @LiveLinkMicStatus
    int getLinkMicStatus() {
        return mSelfInfo == null ? LiveLinkMicStatus.OTHER : mSelfInfo.linkMicStatus;
    }

    void setLinkMicStatus(@LiveLinkMicStatus int linkMicStatus) {
        mBinding.audienceLink.setSelected(linkMicStatus == LiveLinkMicStatus.AUDIENCE_INTERACTING);
        // Beauty Effect disabled for audience
        // mBinding.liveBeauty.setVisibility(linkMicStatus == LiveLinkMicStatus.AUDIENCE_INTERACTING ? VISIBLE : View.GONE);
        if (mSelfInfo != null) {
            mSelfInfo.linkMicStatus = linkMicStatus;
        }
    }
    // The user information of the current room owner
    private LiveUserInfo mHostInfo;
    // room information
    private LiveRoomInfo mLiveRoomInfo;

    public String getRTSRoomId() {
        return mLiveRoomInfo.roomId;
    }

    private final String mSelfUserId = SolutionDataManager.ins().getUserId();

    public String getMyUserId() {
        return mSelfUserId;
    }

    public String getAnchorUserId() {
        return mLiveRoomInfo.anchorUserId;
    }

    @NonNull
    public Map<String, String> getPullStreamUrls() {
        if (mLiveRoomInfo == null || mLiveRoomInfo.streamPullStreamList == null) {
            return Collections.emptyMap();
        }
        return mLiveRoomInfo.streamPullStreamList;
    }

    private FragmentLiveAudienceBinding mBinding;
    private AudienceVideoRenderHelper mVideoRender;
    private GiftAnimateHelper mGiftAnimateHelper;

    private LiveChatAdapter mLiveChatAdapter;

    private boolean isLeaveByKickOut = false;

    boolean isHostCameraOn() {
        return mHostInfo != null && mHostInfo.isCameraOn();
    }
    // join room callback
    private final IRequestCallback<JoinLiveRoomResponse> mJoinRoomCallback = new IRequestCallback<JoinLiveRoomResponse>() {
        @Override
        public void onSuccess(JoinLiveRoomResponse data) {
            setRoomStatus(data.liveRoomInfo.status);
            mRTSToken = data.rtsToken;
            mHostInfo = data.liveHostUserInfo;
            initByJoinResponse(data.liveRoomInfo, data.liveUserInfo, Collections.emptyList());
        }

        @Override
        public void onError(int errorCode, String message) {
            String msg;
            if (errorCode != 200) {
                msg = getString(R.string.joining_room_failed);
            } else {
                msg = ErrorTool.getErrorMessageByErrorCode(errorCode, message);
            }

            CenteredToast.show(msg);
            popBackStack();
        }
    };
    // reconnect callback
    private final IRequestCallback<LiveReconnectResponse> mLiveReconnectCallback = new IRequestCallback<LiveReconnectResponse>() {
        @Override
        public void onSuccess(LiveReconnectResponse data) {
            if (data.recoverInfo == null) {
                showToast(R.string.live_ended_title);
                popBackStack();
            } else {
                initByJoinResponse(data.recoverInfo.liveRoomInfo, data.userInfo, data.getInteractUsers());
                setRoomStatus(data.interactStatus);
            }
        }

        @Override
        public void onError(int errorCode, String message) {
            showToast(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
            popBackStack();
        }
    };

    private AudienceViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mViewModel = new ViewModelProvider(this).get(AudienceViewModel.class);

        getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onResume(@NonNull LifecycleOwner owner) {
                WindowCompat.getInsetsController(requireActivity().getWindow(), requireView())
                        .setAppearanceLightStatusBars(false);
            }
        });
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_live_audience, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        final Bundle arguments = requireArguments();
        String roomId = arguments.getString(EXTRA_ROOM_ID);
        String hostId = arguments.getString(EXTRA_HOST_ID);
        if (TextUtils.isEmpty(roomId) || TextUtils.isEmpty(hostId)) {
            throw new IllegalArgumentException("roomId or hostId not set!");
        } else {
            LiveRTCManager.ins().getRTSClient().requestJoinLiveRoom(roomId, mJoinRoomCallback);
        }

        mBinding = FragmentLiveAudienceBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            mBinding.guidelineTop.setGuidelineBegin(insets.top);
            mBinding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        mVideoRender = new AudienceVideoRenderHelper(this, mBinding);
        mVideoRender.showPlayer();
        mGiftAnimateHelper = new GiftAnimateHelper(requireContext(), mBinding.giftSlot1, mBinding.giftSlot2);

        mLiveChatAdapter = new LiveChatAdapter();
        final LinearLayoutManager layoutManager = new LinearLayoutManager(requireContext());
        layoutManager.setStackFromEnd(true);
        mBinding.messagePanel.setLayoutManager(layoutManager);
        mBinding.messagePanel.addItemDecoration(new LiveChatItemDecoration(ViewUtils.dp2px(2)));
        mBinding.messagePanel.setAdapter(mLiveChatAdapter);

        mBinding.close.setOnClickListener(v -> popBackStack());

        // region bottom actions
        mBinding.comment.setOnClickListener(this::onCommentClicked);
        mBinding.audienceLink.setOnClickListener(this::onAudienceLinkClicked);
        mBinding.liveGift.setOnClickListener(this::onGiftButtonClicked);
        mBinding.liveLike.setOnClickListener(DebounceClickListener.create(this::onLikeButtonClicked, 100));
        mBinding.liveBeauty.setOnClickListener(this::onBeautyButtonClicked);
        // endregion

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
        mGiftAnimateHelper.onDestroyView();

        mVideoRender.destroyPlayer();

        final LiveRTCManager rtcManager = LiveRTCManager.ins();
        if (mLiveRoomInfo != null && mSelfInfo != null) {
            if (getLinkMicStatus() == LiveLinkMicStatus.AUDIENCE_INTERACTING) {
                showToast(getString(R.string.host_disconnected_live));
            }
            if (!isLeaveByKickOut) {
                String roomId = getRTSRoomId();
                rtcManager.getRTSClient().requestLeaveLiveRoom(roomId, null);
            }
        }

        rtcManager.leaveRTSRoom();
        rtcManager.leaveRoom();
        rtcManager.stopAllCapture();
    }

    public void initByJoinResponse(LiveRoomInfo liveRoomInfo, LiveUserInfo liveUserInfo, List<LiveUserInfo> interactUserList) {
        mLiveRoomInfo = liveRoomInfo;
        mViewModel.setLiveRoomInfo(liveRoomInfo);
        setSelfInfo(liveUserInfo);
        int audienceCount = liveRoomInfo.audienceCount;

        final LiveRTCManager rtcManager = LiveRTCManager.ins();
        rtcManager.joinRTSRoom(getRTSRoomId(), getMyUserId(), mRTSToken);
        rtcManager.startCapture(false, false);

        //UI
        String hostUserName = liveRoomInfo.anchorUserName;
        String hostUserId = liveRoomInfo.anchorUserId;
        mBinding.hostAvatar.userName.setText(hostUserName);
        Glide.with(mBinding.hostAvatar.userAvatar)
                .load(Avatars.byUserId(hostUserId))
                .circleCrop()
                .into(mBinding.hostAvatar.userAvatar);

//        Glide.with(mBinding.hostAvatarBig)
//                .load(Avatars.byUserId(hostUserId))
//                .centerCrop()
//                .into(mBinding.hostAvatarBig);

        setAudienceCount(audienceCount);

        updatePlayerStatus();

        updateOnlineGuestList(interactUserList);
    }

    private void setAudienceCount(int count) {
        mBinding.audienceNum.setText(String.format(Locale.US, "%d", count));
    }


    private void addChatMessage(CharSequence message) {
        mLiveChatAdapter.addChatMsg(message);
        mBinding.messagePanel.post(() -> mBinding.messagePanel.smoothScrollToPosition(mLiveChatAdapter.getItemCount()));
    }

    /**
     * Update TTPlayer state
     * If you are the host, or you are a guest who is connecting with the host,
     * the control of connecting with the host will be displayed, and the streaming will stop
     * Otherwise, if a single anchor is live streaming and the camera is turned off,
     * the mic-connected control will be displayed and streaming will start
     */
    private void updatePlayerStatus() {
        if (getLinkMicStatus() == LiveLinkMicStatus.AUDIENCE_INTERACTING) {
            stopPlayLiveStream();
        } else {
            playLiveStream();
            updatePlayerVisibility();
        }
    }

    /**
     * Play live rtmp live stream
     */
    private void playLiveStream() {
        Map<String, String> urls = getPullStreamUrls();
        if (urls.isEmpty()) {
            Log.d(TAG, "playLiveStream: pullStream map is empty");
            return;
        }

        mVideoRender.playUrl(urls);
    }

    private void stopPlayLiveStream() {
        mVideoRender.stopPlay();
    }

    /**
     * This method will use the list in Parameters to refresh the status information of the host,
     * Lianmai anchor, and yourself
     *
     * @param userList is used to refresh the data of users in the room
     */
    private void updateOnlineGuestList(@NonNull List<LiveUserInfo> userList) {
        for (LiveUserInfo userInfo : userList) {
            if (TextUtils.equals(userInfo.userId, getAnchorUserId())) {
                mHostInfo = userInfo;
            } else if (TextUtils.equals(userInfo.userId, getMyUserId())) {
                setSelfInfo(userInfo);
                setLinkMicStatus(LiveLinkMicStatus.AUDIENCE_INTERACTING);
            }
        }
    }


    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveRTSUserEvent(LiveRTSUserEvent event) {
        setAudienceCount(event.audienceCount);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveFinishEvent(LiveFinishEvent event) {
        if (TextUtils.equals(event.roomId, getRTSRoomId())) {
            if (event.type == LiveFinishType.TIMEOUT) {
                showToast(R.string.live_ended);
            } else if (event.type == LiveFinishType.IRREGULARITY) {
                showToast(R.string.closed_terms_service);
            } else if (event.type == LiveFinishType.NORMAL) {
                showToast(R.string.live_ended);
            }
            popBackStack();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUserMediaControlEvent(UserMediaControlEvent event) {
        if (!TextUtils.equals(getMyUserId(), event.guestUserId)) {
            return;
        }
        if (event.camera == MediaStatus.OFF) {
            showToast(getString(R.string.off_camera_title));
            LiveRTCManager.ins().startCaptureVideo(false);
        }
        if (event.mic == MediaStatus.OFF) {
            showToast(getString(R.string.off_mic_title));
            LiveRTCManager.ins().startCaptureAudio(false);
        }
        int mic = LiveRTCManager.ins().isMicOn() ? MediaStatus.ON : MediaStatus.OFF;
        int camera = LiveRTCManager.ins().isCameraOn() ? MediaStatus.ON : MediaStatus.OFF;
        LiveRTCManager.ins().getRTSClient().updateMediaStatus(event.guestRoomId, mic, camera, new IRequestCallback<LiveResponse>() {
            @Override
            public void onSuccess(LiveResponse data) {

            }

            @Override
            public void onError(int errorCode, String message) {
                showToast(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
            }
        });
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaChangedEvent(UserMediaChangedEvent event) {
        if (mHostInfo != null && TextUtils.equals(event.userId, mHostInfo.userId)) {
            mHostInfo.mic = event.mic;
            mHostInfo.camera = event.camera;
            updatePlayerVisibility();
        }

        mVideoRender.onMediaChangedEvent(event);
    }

    void updatePlayerVisibility() {
        if (getLinkMicStatus() == LiveLinkMicStatus.AUDIENCE_INTERACTING) {
            mBinding.player.setVisibility(View.INVISIBLE);
        } else {
            mBinding.player.setVisibility(View.VISIBLE);
            if (mVideoRender.getLiveMode() == LiveMode.NORMAL) {
                if (isHostCameraOn()) {
                    mBinding.hostAvatarBig.setVisibility(View.GONE);
                } else {
                    mBinding.hostAvatarBig.setImageResource(Avatars.byUserId(getAnchorUserId()));
                    mBinding.hostAvatarBig.setVisibility(View.VISIBLE);
                }
            } else {
                mBinding.hostAvatarBig.setVisibility(View.GONE);
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveReconnectEvent(RTCReconnectToRoomEvent event) {
        LiveRTCManager.ins().getRTSClient().requestLiveReconnect(getRTSRoomId(), mLiveReconnectCallback);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUpdatePullStreamEvent(LocalUpdatePullStreamEvent event) {
        updatePlayerStatus();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveKickUserEvent(LiveKickUserEvent event) {
        showToast(getString(R.string.same_logged_in));
        isLeaveByKickOut = true;
        popBackStack();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLinkMicStatusEvent(LinkMicStatusEvent event) {
        setRoomStatus(event.linkMicStatus);
        mHostInfo.linkMicStatus = event.linkMicStatus;
        updatePlayerStatus();
    }
    // Audience Lianmai Audience end Invite audience to mic notification
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkInviteEvent(AudienceLinkInviteEvent event) {

    }
    // Audience Lianmai, the audience terminal, the anchor confirms the application result of the audience
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkPermitEvent(AudienceLinkPermitEvent event) {
        if (event.permitType == LivePermitType.REJECT) {
            ToastAudienceLink.show(requireContext(),
                    R.drawable.ic_live_alert,
                    R.string.audience_link_reject_title,
                    R.string.audience_link_reject_message);
            SolutionEventBus.post(new InviteAudienceEvent(getMyUserId(), InviteReply.REJECT, event.linkerId));
        } else if (event.permitType == LivePermitType.ACCEPT) {
            ToastAudienceLink.show(requireContext(),
                    R.drawable.ic_check_green,
                    R.string.audience_link_permitted_title,
                    R.string.audience_link_permitted_message);

            SolutionEventBus.post(new InviteAudienceEvent(getMyUserId(), InviteReply.ACCEPT, event.linkerId));

            updateOnlineGuestList(event.rtcUserList);
            LiveRTCManager.ins().switchToAudienceConfig();
            LiveRTCManager.ins().joinRoom(event.rtcRoomId, getMyUserId(), event.rtcToken);
            LiveRTCManager.ins().startCapture(mSelfInfo.isCameraOn(), mSelfInfo.isMicOn());

            setRoomStatus(RoomStatus.AUDIENCE_LINK);
            setLinkMicStatus(LiveLinkMicStatus.AUDIENCE_INTERACTING);

            updatePlayerStatus();
            showLinkView(event.rtcUserList);
        }
    }

    private void showLinkView(List<LiveUserInfo> rtcUserList) {
        if (rtcUserList == null || rtcUserList.isEmpty()) {
            mVideoRender.showPlayer();
            return;
        }

        LiveUserInfo host = null;
        List<LiveUserInfo> users = new ArrayList<>();
        for (LiveUserInfo info : rtcUserList) {
            if (getAnchorUserId().equals(info.userId)) {
                host = info;
            } else {
                users.add(info);
            }
        }

        assert host != null : "Host info not found!";

        mVideoRender.showLinkView(host, users);
    }
    // Audience mic, audience join or leave
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkStatusEvent(AudienceLinkStatusEvent event) {
        if (event.isJoin()) {
            setRoomStatus(RoomStatus.AUDIENCE_LINK);
            updateOnlineGuestList(event.userList);
            showLinkView(event.userList);
        } else {
            if (TextUtils.equals(event.userId, getMyUserId())) {
                linkStatusDisconnected();
            } else {
                updateOnlineGuestList(event.userList);
                showLinkView(event.userList);
            }
        }
    }

    /**
     * @see #onAudienceLinkFinishEvent(AudienceLinkFinishEvent)
     * @see #onAudienceLinkStatusEvent(AudienceLinkStatusEvent)
     */
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkKickEvent(AudienceLinkKickEvent event) {
        // No need to call linkStatusDisconnected()
        // let onAudienceLinkStatusEvent to handle
        showToast(R.string.host_disconnected_live);
    }
    // Audiences connect to mic, Audiences mic themselves, or all guests on the anchor end mic
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkFinishEvent(AudienceLinkFinishEvent event) {
        linkStatusDisconnected();

        showToast(R.string.host_disconnected_live);
    }

    void linkStatusDisconnected() {
        setRoomStatus(RoomStatus.LIVE);
        setLinkMicStatus(LiveLinkMicStatus.OTHER);
        updateOnlineGuestList(Collections.emptyList());
        LiveRTCManager.ins().startCapture(false, false);
        LiveRTCManager.ins().leaveRoom();

        mVideoRender.showPlayer();
        updatePlayerStatus();
    }

    void popBackStack() {
        final View view = getView();
        if (view == null) {
            return;
        }
        Navigation.findNavController(view).popBackStack();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveModeChangeEvent(LiveModeChangeEvent event) {
        updatePlayerVisibility();
    }

    // region bottom action handlers
    // Audience Link
    void onCommentClicked(View view) {
        LiveSendMessageInputDialog dialog = new LiveSendMessageInputDialog();
        final Bundle args = new Bundle();
        args.putString("rtsRoomId", getRTSRoomId());
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "send-message-input-dialog");
    }

    void onAudienceLinkClicked(View view) {
        if (mSelfInfo == null) {
            return;
        }
        final int linkMicStatus = getLinkMicStatus();
        if (linkMicStatus == LiveLinkMicStatus.OTHER) {
            boolean isHostInCoHost = mHostInfo != null && mHostInfo.linkMicStatus == LiveLinkMicStatus.HOST_INTERACTING;
            if (getRoomStatus() == RoomStatus.PK || isHostInCoHost) {
                showToast(R.string.host_liveing);
                return;
            }
            RequestAudienceLinkDialog dialog = new RequestAudienceLinkDialog();
            dialog.show(getChildFragmentManager(), "request_audience_link_dialog");
        } else if (linkMicStatus == LiveLinkMicStatus.AUDIENCE_INTERACTING) {
            AudienceSettingsDialog dialog = new AudienceSettingsDialog();
            dialog.show(getChildFragmentManager(), "settings_dialog");
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInviteAudienceEvent(InviteAudienceEvent event) {
        if (TextUtils.equals(event.userId, getMyUserId())) {
            mViewModel.setLinkerId(event.linkerId);
            mViewModel.requestLinkStatus.postValue(event.reply);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onPublishStreamEvent(PublishVideoStreamEvent event) {
        mVideoRender.onPublishStreamEvent(event);
    }

    // Gift
    void onGiftButtonClicked(View view) {
        GiftDialog dialog = new GiftDialog();
        final Bundle args = new Bundle();
        args.putString("rtsRoomId", getRTSRoomId());
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "gift_dialog");
    }

    // Like/Heart

    void onLikeButtonClicked(View view) {
        LiveRTCManager.rts().sendMessage(getRTSRoomId(), MessageBody.LIKE);
    }

    // Beauty
    void onBeautyButtonClicked(View view) {
        LiveRTCManager.ins().openEffectDialog(requireContext(), getParentFragmentManager());
    }

    // endregion

    // region OnMessage
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(MessageEvent event) {
        LiveUserInfo user = event.user;
        MessageBody body = event.getBody();

        switch (body.type) {
            case MessageType.MSG:
                onNormalMessage(user, body.content);
                break;
            case MessageType.GIFT:
                onGiftMessage(event);
                break;
            case MessageType.LIKE:
                onLikeMessage(user);
                break;
        }
    }

    private void onNormalMessage(LiveUserInfo user, String content) {
        final Context context = getContext();
        if (context == null) {
            return;
        }
        String userName = user.userName;
        boolean isHost = TextUtils.equals(mLiveRoomInfo.anchorUserId, user.userId);

        SpannableStringBuilder ssb = new SpannableStringBuilder();

        if (isHost) {
            ssb.append(" ");
            ImageSpan imageSpan = new ImageSpan(context, R.drawable.ic_message_host);
            ssb.setSpan(imageSpan, 0, 1, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            ssb.append(" ");
        }
        { // Change User Name Color
            final int start = ssb.length();
            ssb.append(userName);
            final int end = ssb.length();

            final ForegroundColorSpan colorSpan = new ForegroundColorSpan(LiveChatAdapter.USER_NAME_COLOR);
            ssb.setSpan(colorSpan, start, end, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
        }
        ssb.append(": ");
        ssb.append(content);

        addChatMessage(ssb);
    }

    private void onGiftMessage(MessageEvent event) {
        mGiftAnimateHelper.post(event);
    }

    private void onLikeMessage(LiveUserInfo user) {
        mBinding.likeArea.startAnimation();
    }
    // endregion

    static void showToast(String message) {
        CenteredToast.show(message);
    }

    static void showToast(@StringRes int message) {
        CenteredToast.show(message);
    }
}