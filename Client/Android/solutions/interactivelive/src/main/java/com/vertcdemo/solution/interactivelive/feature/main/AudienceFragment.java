// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import static android.appwidget.AppWidgetManager.EXTRA_HOST_ID;
import static com.vertcdemo.core.chat.ChatConfig.SEND_MESSAGE_COUNT_LIMIT;
import static com.vertcdemo.core.chat.input.MessageInputDialog.REQUEST_KEY_MESSAGE_INPUT;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_ROOM_ID;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentResultListener;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.chat.ChatAdapter;
import com.vertcdemo.core.chat.gift.GiftDialog;
import com.vertcdemo.core.chat.annotation.GiftType;
import com.vertcdemo.core.chat.gift.GiftAnimateHelper;
import com.vertcdemo.core.chat.input.MessageInputDialog;
import com.vertcdemo.core.event.RTCReconnectToRoomEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.callback.OnFailure;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.annotation.InviteReply;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveFinishType;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveLinkMicStatus;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;
import com.vertcdemo.solution.interactivelive.core.annotation.LivePermitType;
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
import com.vertcdemo.solution.interactivelive.feature.main.audiencelink.RequestAudienceLinkDialog;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.solution.interactivelive.http.response.JoinRoomResponse;
import com.vertcdemo.solution.interactivelive.http.response.ReconnectResponse;
import com.vertcdemo.ui.CenteredToast;
import com.videoone.avatars.Avatars;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;


public class AudienceFragment extends Fragment implements GiftDialog.IGiftSender {
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

    private ChatAdapter mLiveChatAdapter;

    private int mSendMessageCount = 0;

    boolean isHostCameraOn() {
        return mHostInfo != null && mHostInfo.isCameraOn();
    }
    // join room callback
    private final Callback<JoinRoomResponse> mJoinRoomCallback = new Callback<JoinRoomResponse>() {
        @Override
        public void onResponse(JoinRoomResponse data) {
            if (data == null) {
                onFailure(HttpException.unknown("Response is null"));
                return;
            }
            setRoomStatus(data.getRoomStatus()); // Join room success
            mRTSToken = data.rtsToken;
            mHostInfo = data.liveHostUserInfo;
            initByJoinResponse(data.liveRoomInfo, data.liveUserInfo);
        }

        @Override
        public void onFailure(HttpException e) {
            CenteredToast.show(ErrorTool.getErrorMessage(e));
            leaveRoom(false); // Join room failed, leave room
        }
    };
    // reconnect callback
    private final Callback<ReconnectResponse> mLiveReconnectCallback = new Callback<ReconnectResponse>() {
        @Override
        public void onResponse(ReconnectResponse data) {
            if (data == null || data.recoverInfo == null) {
                showToast(R.string.live_ended_title);
                leaveRoom(false); // Reconnect failed
            } else {
                initByJoinResponse(
                        data.recoverInfo.liveRoomInfo,
                        data.userInfo, data.getLinkMicUsers(),
                        true);
                setRoomStatus(data.getRoomStatus());
            }
        }

        @Override
        public void onFailure(HttpException e) {
            showToast(ErrorTool.getErrorMessage(e));
            leaveRoom(false); // Reconnect exception
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

        getChildFragmentManager()
                .setFragmentResultListener(REQUEST_KEY_MESSAGE_INPUT, this, messageInputResultListener);

        requireActivity().getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                leaveRoom(); // On Back pressed
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
            LiveService.get().joinRoom(roomId, mJoinRoomCallback);
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

        mLiveChatAdapter = ChatAdapter.bind(mBinding.messagePanel);

        mBinding.close.setOnClickListener(v -> leaveRoom());

        // region bottom actions
        mBinding.comment.setOnClickListener(v -> openInputDialog());
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
        rtcManager.leaveRTSRoom();
        rtcManager.leaveRoom();
        rtcManager.stopAllCapture();
    }

    /**
     * Leave Room & call server api
     */
    private void leaveRoom() {
        leaveRoom(true);
    }

    /**
     * Leave Room
     *
     * @param callServer if need call server api to leave room
     */
    private void leaveRoom(boolean callServer) {
        SolutionEventBus.unregister(this);

        if (mLiveRoomInfo != null && mSelfInfo != null) {
            if (getLinkMicStatus() == LiveLinkMicStatus.AUDIENCE_INTERACTING) {
                showToast(getString(R.string.host_disconnected_live));
            }
            if (callServer) {
                String roomId = getRTSRoomId();
                LiveService.get().leaveRoom(roomId);
            }
        }

        Navigation.findNavController(requireView())
                .popBackStack();
    }

    public void initByJoinResponse(
            LiveRoomInfo liveRoomInfo,
            LiveUserInfo liveUserInfo) {
        initByJoinResponse(liveRoomInfo, liveUserInfo, Collections.emptyList(), false);
    }

    public void initByJoinResponse(
            LiveRoomInfo liveRoomInfo,
            LiveUserInfo liveUserInfo,
            List<LiveUserInfo> interactUserList,
            boolean isReconnect) {
        final int oldLinkMicStatus = getLinkMicStatus();
        mLiveRoomInfo = liveRoomInfo;
        mViewModel.setLiveRoomInfo(liveRoomInfo);
        setSelfInfo(liveUserInfo);
        int audienceCount = liveRoomInfo.audienceCount;

        if (!isReconnect) {
            final LiveRTCManager rtcManager = LiveRTCManager.ins();
            rtcManager.joinRTSRoom(getRTSRoomId(), getMyUserId(), mRTSToken);
            rtcManager.startCapture(false, false);
        }

        //UI
        String hostUserName = liveRoomInfo.anchorUserName;
        String hostUserId = liveRoomInfo.anchorUserId;
        mBinding.hostAvatar.userName.setText(hostUserName);
        Glide.with(mBinding.hostAvatar.userAvatar)
                .load(Avatars.byUserId(hostUserId))
                .into(mBinding.hostAvatar.userAvatar);

        setAudienceCount(audienceCount);

        updatePlayerStatus();

        updateOnlineGuestList(interactUserList);

        if (isReconnect) {
            // Check if current user is interacting
            int newLinkMicStatus = getLinkMicStatus();
            if (oldLinkMicStatus == LiveLinkMicStatus.AUDIENCE_INTERACTING
                    && newLinkMicStatus != LiveLinkMicStatus.AUDIENCE_INTERACTING) {
                // Update to live watching mode
                linkStatusDisconnected();
            }
        }
    }

    private void setAudienceCount(int count) {
        mBinding.audienceNum.setText(String.format(Locale.US, "%d", count));
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
                showToast(com.vertcdemo.rtc.toolkit.R.string.live_ended);
            } else if (event.type == LiveFinishType.IRREGULARITY) {
                showToast(com.vertcdemo.rtc.toolkit.R.string.closed_terms_service);
            } else if (event.type == LiveFinishType.NORMAL) {
                showToast(com.vertcdemo.rtc.toolkit.R.string.live_ended);
            }
            leaveRoom(false); // Live End
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
        LiveService.get().updateMediaStatus(getRTSRoomId(), mic, camera, OnFailure.of(e -> {
            showToast(ErrorTool.getErrorMessage(e));
        }));
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
        LiveService.get().reconnect(getRTSRoomId(), mLiveReconnectCallback);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUpdatePullStreamEvent(LocalUpdatePullStreamEvent event) {
        updatePlayerStatus();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveKickUserEvent(LiveKickUserEvent event) {
        showToast(getString(R.string.same_logged_in));
        leaveRoom(false); // Same user login
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLinkMicStatusEvent(LinkMicStatusEvent event) {
        setRoomStatus(event.linkMicStatus); // onLinkMicStatusEvent
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

            setRoomStatus(RoomStatus.AUDIENCE_LINK); // onAudienceLinkPermitEvent
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
            setRoomStatus(RoomStatus.AUDIENCE_LINK); // onAudienceLinkStatusEvent
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
        setRoomStatus(RoomStatus.LIVE); // linkStatusDisconnected
        setLinkMicStatus(LiveLinkMicStatus.OTHER);
        updateOnlineGuestList(Collections.emptyList());
        LiveRTCManager.ins().startCapture(false, false);
        LiveRTCManager.ins().leaveRoom();

        mVideoRender.showPlayer();
        updatePlayerStatus();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveModeChangeEvent(LiveModeChangeEvent event) {
        updatePlayerVisibility();
    }

    // region bottom action handlers
    // Audience Link
    private String mLastInputText = null;
    private final FragmentResultListener messageInputResultListener = (requestKey, result) -> {
        String content = result.getString(MessageInputDialog.EXTRA_CONTENT);
        boolean actionDone = result.getBoolean(MessageInputDialog.EXTRA_ACTION_DONE, false);
        if (actionDone) {
            mLastInputText = null;

            if (mSendMessageCount >= SEND_MESSAGE_COUNT_LIMIT) {
                showToast(com.vertcdemo.rtc.toolkit.R.string.send_message_exceeded_limit);
                return;
            }
            mSendMessageCount++;

            MessageBody body = MessageBody.createMessage(content);
            LiveService.get().sendMessage(getRTSRoomId(), body);
        } else {
            mLastInputText = content;
        }
    };

    void openInputDialog() {
        MessageInputDialog dialog = new MessageInputDialog();
        if (!TextUtils.isEmpty(mLastInputText)) {
            Bundle args = new Bundle();
            args.putString(MessageInputDialog.EXTRA_CONTENT, mLastInputText);
            dialog.setArguments(args);
        }
        dialog.show(getChildFragmentManager(), "message-input-dialog");
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
        dialog.show(getChildFragmentManager(), "gift_dialog");
    }

    @Override
    public void sendGift(int giftType) {
        MessageBody body;
        switch (giftType) {
            case GiftType.LIKE:
                body = MessageBody.GIFT_LIKE;
                break;
            case GiftType.SUGAR:
                body = MessageBody.GIFT_SUGAR;
                break;
            case GiftType.DIAMOND:
                body = MessageBody.GIFT_DIAMOND;
                break;
            case GiftType.FIREWORKS:
                body = MessageBody.GIFT_FIREWORKS;
                break;
            default:
                throw new IllegalStateException("Unexpected value: " + giftType);
        }

        LiveService.get().sendMessage(getRTSRoomId(), body, sGiftCallback);
    }

    private static final Callback<Void> sGiftCallback = OnFailure.of(e -> {
        CenteredToast.show(ErrorTool.getErrorMessage(e));
    });

    // Like/Heart

    void onLikeButtonClicked(View view) {
        LiveService.get().sendMessage(getRTSRoomId(), MessageBody.LIKE);
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

        mLiveChatAdapter.onNormalMessage(context, userName, content, isHost);
        mBinding.messagePanel.post(() -> mBinding.messagePanel.smoothScrollToPosition(mLiveChatAdapter.getItemCount()));
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