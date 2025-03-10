// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import static com.vertcdemo.core.chat.ChatConfig.SEND_MESSAGE_COUNT_LIMIT;
import static com.vertcdemo.core.chat.input.MessageInputDialog.REQUEST_KEY_MESSAGE_INPUT;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_PUSH_URL;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_ROOM_INFO;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_RTC_ROOM_ID;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_RTC_TOKEN;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_RTS_TOKEN;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_USER_INFO;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_NEGATIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_POSITIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_MESSAGE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_REQUEST_KEY;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_RESULT;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_TITLE;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
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
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentResultListener;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;

import com.bumptech.glide.Glide;
import com.ss.bytertc.engine.type.NetworkQuality;
import com.ss.bytertc.engine.type.NetworkQualityStats;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.chat.ChatAdapter;
import com.vertcdemo.core.chat.gift.GiftAnimateHelper;
import com.vertcdemo.core.chat.input.MessageInputDialog;
import com.vertcdemo.core.event.RTCNetworkQualityEvent;
import com.vertcdemo.core.event.RTCReconnectToRoomEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.callback.OnNext;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.core.utils.Streams;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveSummary;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;
import com.vertcdemo.solution.interactivelive.bean.ReconnectInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.annotation.InviteReply;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveFinishType;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveLinkMicStatus;
import com.vertcdemo.solution.interactivelive.core.annotation.LivePermitType;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveRoleType;
import com.vertcdemo.solution.interactivelive.core.annotation.MessageType;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveHostBinding;
import com.vertcdemo.solution.interactivelive.effect.InteractiveLiveEffectFragment;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkInviteEvent;
import com.vertcdemo.solution.interactivelive.event.AnchorLinkReplyEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkApplyEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkCancelEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkKickResultEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkReplyEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkStatusEvent;
import com.vertcdemo.solution.interactivelive.event.LinkMicStatusEvent;
import com.vertcdemo.solution.interactivelive.event.LiveCoreNetworkQualityEvent;
import com.vertcdemo.solution.interactivelive.event.LiveFinishEvent;
import com.vertcdemo.solution.interactivelive.event.LiveKickUserEvent;
import com.vertcdemo.solution.interactivelive.event.LiveRTSUserEvent;
import com.vertcdemo.solution.interactivelive.event.MessageEvent;
import com.vertcdemo.solution.interactivelive.event.PublishVideoStreamEvent;
import com.vertcdemo.solution.interactivelive.event.RequestFinishLiveResultEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;
import com.vertcdemo.solution.interactivelive.feature.main.audiencelink.AudienceLinkRequest;
import com.vertcdemo.solution.interactivelive.feature.main.audiencelink.ManageAudiencesDialog;
import com.vertcdemo.solution.interactivelive.feature.main.cohost.AnchorInviteHostDialog;
import com.vertcdemo.solution.interactivelive.feature.main.cohost.AnchorLinkConfirmFinishDialog;
import com.vertcdemo.solution.interactivelive.feature.main.cohost.AnchorLinkConfirmInviteDialog;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.solution.interactivelive.http.response.LinkResponse;
import com.vertcdemo.solution.interactivelive.http.response.PermitAudienceLinkResponse;
import com.vertcdemo.solution.interactivelive.http.response.ReconnectResponse;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;
import com.videoone.avatars.Avatars;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

public class HostFragment extends Fragment implements ManageAudiencesDialog.IManageAudience {
    private static final String TAG = "HostFragment";

    @RoomStatus
    private int mRoomStatus = RoomStatus.LIVE;

    public void setRoomStatus(@RoomStatus int status) {
        mRoomStatus = status;
        mBinding.audience.setSelected(status == RoomStatus.AUDIENCE_LINK);
        mBinding.livePk.setSelected(status == RoomStatus.PK);
        if (status != RoomStatus.LIVE) {
            dismissLiveInfoDialog();
        }
    }

    public int getRoomStatus() {
        return mRoomStatus;
    }

    private String mPushUrl;
    private String mRTCToken;
    private String mRTSToken;
    private String mRTCRoomId;
    private String mLinkId;
    // Own information
    private LiveUserInfo mSelfInfo;
    // The user information of the connected host
    @Nullable
    private LiveUserInfo mCoHostInfo;

    private final List<LiveUserInfo> mGuestList = new ArrayList<>();
    private long mStartAudienceLinkTime = 0;
    private final List<AudienceLinkRequest> mAudienceLinkRequests = new ArrayList<>();

    private FragmentLiveHostBinding mBinding;
    private HostVideoRenderHelper mVideoRender;
    private GiftAnimateHelper mGiftAnimateHelper;

    private ChatAdapter mLiveChatAdapter;

    private int mSendMessageCount = 0;
    // Respond to the invite callback
    private final Callback<LinkResponse> mAnchorReplyInviteCallback = new Callback<LinkResponse>() {
        @Override
        public void onResponse(LinkResponse data) {
            if (data == null) {
                onFailure(HttpException.unknown("Response is null"));
                return;
            }
            for (LiveUserInfo info : data.userList) {
                if (!TextUtils.equals(info.userId, SolutionDataManager.ins().getUserId())) {
                    mCoHostInfo = info;
                    break;
                }
            }

            if (mCoHostInfo == null) {
                // status failed
                Log.e(TAG, "Status failed, No CoHostInfo found!", new Exception());
                return;
            }

            setRoomStatus(RoomStatus.PK);
            mVideoRender.setLiveUserInfo(mCoHostInfo);
            LiveRTCManager.ins().startCoHostPK(data.rtcRoomId, data.rtcToken, mCoHostInfo);
        }

        @Override
        public void onFailure(HttpException e) {
            showToast(ErrorTool.getErrorMessage(e));
        }
    };

    void handleAnchorPermitAudienceResponse(String audienceUserId, PermitAudienceLinkResponse data) {
        setRoomStatus(RoomStatus.AUDIENCE_LINK);
        updateOnlineGuestList(data.userList);

        if (mGuestList.size() == 1) {
            onFirstAudienceLink();
        }

        updateLiveTranscodingWithAudience();
    }

    private void onFirstAudienceLink() {
        if (mStartAudienceLinkTime <= 0) { // First Audience link user
            showToast(R.string.first_audience_link_message);
            mStartAudienceLinkTime = SystemClock.uptimeMillis();
        }
    }
    // reconnect callback
    private final Callback<ReconnectResponse> mLiveReconnectCallback = new Callback<ReconnectResponse>() {
        @Override
        public void onResponse(ReconnectResponse data) {
            if (data == null || data.recoverInfo == null) {
                showToast(R.string.live_ended_title);
                popBackStack(); // reconnect no recover info
            } else {
                initByJoinResponse(data.getRoomStatus(),
                        data.recoverInfo.liveRoomInfo,
                        data.userInfo,
                        data.recoverInfo);
            }
        }

        @Override
        public void onFailure(HttpException e) {
            showToast(ErrorTool.getErrorMessage(e));
            popBackStack(); // reconnect failed
        }
    };

    private static final int MSG_UPDATE_LIVE_TIME = 1;

    @SuppressLint("HandlerLeak")
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull Message msg) {
            if (msg.what == MSG_UPDATE_LIVE_TIME) {
                long durationInSeconds = (SystemClock.uptimeMillis() - mViewModel.getLiveStartTime()) / 1000;
                long seconds = durationInSeconds % 60;
                long minutes = durationInSeconds / 60;
                mBinding.liveTime.setText(String.format(Locale.ENGLISH, "%1$02d:%2$02d", minutes, seconds));

                mVideoRender.timeTick();
                sendEmptyMessageDelayed(MSG_UPDATE_LIVE_TIME, 1000);
            }
        }
    };

    /**
     * @see #mEndLiveCallback
     * @see #openLeaveDialog()
     */
    private static final String REQUEST_KEY_END_LIVE = "request_end_live";

    HostViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mViewModel = new ViewModelProvider(this).get(HostViewModel.class);

        requireActivity().getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                openLeaveDialog();
            }
        });

        final FragmentManager childFragmentManager = getChildFragmentManager();
        childFragmentManager.setFragmentResultListener(AnchorLinkConfirmInviteDialog.REQUEST_KEY, this, mAnchorLinkInviteCallback);

        childFragmentManager.setFragmentResultListener(REQUEST_KEY_END_LIVE, this, mEndLiveCallback);

        childFragmentManager.setFragmentResultListener(REQUEST_KEY_MESSAGE_INPUT, this, messageInputResultListener);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_live_host, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mBinding = FragmentLiveHostBinding.bind(view);
        mVideoRender = new HostVideoRenderHelper(mBinding, v -> onAudienceLinkClicked());
        mGiftAnimateHelper = new GiftAnimateHelper(requireContext(), mBinding.giftSlot1, mBinding.giftSlot2);

        mBinding.power.setOnClickListener(v -> openLeaveDialog());

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            mBinding.guidelineTop.setGuidelineBegin(insets.top);
            mBinding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        mLiveChatAdapter = ChatAdapter.bind(mBinding.messagePanel);

        Bundle args = requireArguments();
        LiveRoomInfo roomInfo = (LiveRoomInfo) args.getSerializable(EXTRA_ROOM_INFO);
        LiveUserInfo userInfo = (LiveUserInfo) args.getSerializable(EXTRA_USER_INFO);
        mPushUrl = args.getString(EXTRA_PUSH_URL);
        mRTSToken = args.getString(EXTRA_RTS_TOKEN);
        mRTCToken = args.getString(EXTRA_RTC_TOKEN);
        mRTCRoomId = args.getString(EXTRA_RTC_ROOM_ID);

        mSelfInfo = userInfo;
        LiveRTCManager.ins().startCapture(true, true);
        initByJoinResponse(roomInfo, mSelfInfo);
        mViewModel.setLiveStartTime();

        getLifecycle().addObserver((LifecycleEventObserver) (source, event) -> {
            switch (event) {
                case ON_START:
                    mHandler.sendEmptyMessage(MSG_UPDATE_LIVE_TIME);
                    break;
                case ON_STOP:
                    mHandler.removeMessages(MSG_UPDATE_LIVE_TIME);
                    break;
            }
        });

        mViewModel.showAudienceDot.observe(getViewLifecycleOwner(), hasApplication -> {
            mBinding.audienceDot.setVisibility(hasApplication ? View.VISIBLE : View.GONE);
        });

        // region bottom actions
        mBinding.audience.setOnClickListener(v -> onAudienceLinkClicked());
        mBinding.livePk.setOnClickListener(v -> {
            if (getRoomStatus() == RoomStatus.PK) {
                openFinishCoHostDialog();
            } else {
                openInviteCoHostDialog();
            }
        });
        mBinding.comment.setOnClickListener(v -> {
            openInputDialog();
        });
        mBinding.magic.setOnClickListener(v -> openVideoEffectDialog());
        mBinding.liveMore.setOnClickListener(v -> openSettingDialog());
        // endregion

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
        mGiftAnimateHelper.onDestroyView();

        if (mViewModel.finishRequested) {
            LiveRTCManager.ins().stopLive();
            LiveRTCManager.ins().leaveRTSRoom();
        }
    }

    public void initByJoinResponse(LiveRoomInfo liveRoomInfo, LiveUserInfo liveUserInfo) {
        initByJoinResponse(mRoomStatus,
                liveRoomInfo,
                liveUserInfo,
                null);
    }

    public void initByJoinResponse(@RoomStatus int newRoomStatus,
                                   LiveRoomInfo liveRoomInfo,
                                   LiveUserInfo liveUserInfo,
                                   ReconnectInfo reconnectInfo) {
        int audienceCount = reconnectInfo == null ? 0 : reconnectInfo.audienceCount;
        final boolean reconnect = (reconnectInfo != null);

        final int oldRoomStatus = getRoomStatus();
        setRoomStatus(newRoomStatus);
        mViewModel.roomInfo = liveRoomInfo;
        mSelfInfo = liveUserInfo;

        //UI
        String userName = liveRoomInfo == null ? null : liveRoomInfo.anchorUserName;
        String userId = liveRoomInfo == null ? null : liveRoomInfo.anchorUserId;
        mBinding.hostAvatar.userName.setText(userName);
        Glide.with(mBinding.hostAvatar.userAvatar)
                .load(Avatars.byUserId(userId))
                .into(mBinding.hostAvatar.userAvatar);
        setAudienceCount(audienceCount);

        if (getRoomStatus() == RoomStatus.PK) {
            updateOnlineGuestList(Collections.emptyList());
            mVideoRender.setLiveUserInfo(mCoHostInfo);
        } else {
            List<LiveUserInfo> users = reconnectInfo == null ? null : reconnectInfo.getLinkMicUsers();
            updateOnlineGuestList(users);
            mVideoRender.setLiveUserInfo();
            mVideoRender.addLinkUserInfo(mGuestList);
        }

        if (reconnect) {
            Log.d(TAG, "initByJoinResponse: RECONNECT: status: " + oldRoomStatus + " -> " + newRoomStatus);
            if (oldRoomStatus != RoomStatus.PK && newRoomStatus == RoomStatus.PK) {
                // Enter co host PK
                // but missed CoHostInfo caused by DISCONNECTED
                // so ignore server status, set to LIVE
                Log.w(TAG, "initByJoinResponse: Can't handle into PK mode.");
                setRoomStatus(RoomStatus.LIVE);

                String linkerId = reconnectInfo.getLinkerId();
                if (!TextUtils.isEmpty(linkerId)) {
                    String roomId = mViewModel.rtsRoomId();
                    LiveService.get()
                            .finishAnchorLink(linkerId, roomId, OnNext.empty());
                }
            } else if (oldRoomStatus == RoomStatus.PK && newRoomStatus != RoomStatus.PK) {
                // Leave co host PK
                //
                // Need notify LiveRTCManager to stop co host PK
                LiveRTCManager.ins().stopCoHostPK(); // reconnect
            } else if (newRoomStatus == RoomStatus.AUDIENCE_LINK || newRoomStatus == RoomStatus.LIVE) {
                updateLiveTranscodingWithAudience();
            }
        } else {
            final LiveRTCManager rtcManager = LiveRTCManager.ins();
            rtcManager.joinRTSRoom(mViewModel.rtsRoomId(), mSelfInfo.userId, mRTSToken);
            rtcManager.startLive(mRTCRoomId, mRTCToken, mPushUrl, mSelfInfo);

            final int role = LiveRoleType.HOST;
            final int width = rtcManager.getWidth(role);
            final int height = rtcManager.getHeight(role);
            LiveService.get().updateResolution(mViewModel.rtsRoomId(), width, height);
        }
    }

    private void setAudienceCount(int count) {
        mBinding.audienceNum.setText(String.format(Locale.US, "%d", count));
    }

    // region bottom action handlers

    /**
     * Manager Audience Link Apply Events
     */
    void onAudienceLinkClicked() {
        if (mSelfInfo == null) {
            return;
        }
        if (getRoomStatus() == RoomStatus.PK) {
            showToast(R.string.unable_to_audience_link_during_pk);
            return;
        }

        ManageAudiencesDialog dialog = new ManageAudiencesDialog();
        final Bundle args = new Bundle();
        args.putSerializable("roomInfo", mViewModel.roomInfo);
        args.putLong("startAudienceLinkTime", mStartAudienceLinkTime);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "manage-guests-dialog");
    }

    private void openInviteCoHostDialog() {
        if (getRoomStatus() == RoomStatus.AUDIENCE_LINK) {
            showToast(R.string.unable_to_pk_during_audience_link);
            return;
        }
        AnchorInviteHostDialog dialog = new AnchorInviteHostDialog();
        final Bundle arguments = new Bundle();
        arguments.putSerializable("roomInfo", mViewModel.roomInfo);
        dialog.setArguments(arguments);
        dialog.show(getChildFragmentManager(), "invite_co_host_dialog");
    }

    private void openFinishCoHostDialog() {
        if (mCoHostInfo == null) {
            Log.e(TAG, "Status failed, No CoHostInfo found!", new Exception());
            final String linkId = mLinkId;
            mLinkId = null;
            if (linkId == null) {
                return;
            }
            AnchorLinkConfirmFinishDialog.finishLink(linkId, mViewModel.rtsRoomId());
            return;
        }
        AnchorLinkConfirmFinishDialog dialog = new AnchorLinkConfirmFinishDialog();
        final Bundle args = new Bundle();
        args.putSerializable("linkId", mLinkId);
        args.putSerializable("rtsRoomId", mViewModel.rtsRoomId());
        args.putSerializable("host", mSelfInfo);
        args.putSerializable("coHost", mCoHostInfo);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "anchor_link_confirm_finish");
    }

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
            LiveService.get().sendMessage(mViewModel.rtsRoomId(), body);
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

    // region Effect
    void openVideoEffectDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        Fragment fragment = fragmentManager.findFragmentByTag("effect-dialog");
        if (fragment != null) {
            return;
        }

        DialogFragment dialog = new InteractiveLiveEffectFragment();
        dialog.showNow(fragmentManager, "effect-dialog");
    }

    // endregion Effect

    private void openSettingDialog() {
        if (mViewModel.roomInfo == null || mSelfInfo == null) {
            return;
        }

        HostMoreActionDialog dialog = new HostMoreActionDialog();
        final Bundle args = new Bundle();
        args.putString("roomId", mViewModel.rtsRoomId());
        args.putInt("room_status", getRoomStatus());
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "more_action_dialog");
    }

    void openLiveInfoDialog() {
        LiveInfoDialog dialog = new LiveInfoDialog();
        dialog.show(getChildFragmentManager(), "live_info");
    }

    void dismissLiveInfoDialog() {
        final LiveInfoDialog dialog = (LiveInfoDialog) getChildFragmentManager()
                .findFragmentByTag("live_info");
        if (dialog != null) {
            dialog.dismiss();
        }
    }

    // endregion bottom action handlers

    private void openLeaveDialog() {
        if (mViewModel.roomInfo == null || mSelfInfo == null) {
            popBackStack(); // leave room status error
            return;
        }

        SolutionCommonDialog dialog = new SolutionCommonDialog();
        final Bundle args = new Bundle();
        args.putString(EXTRA_REQUEST_KEY, REQUEST_KEY_END_LIVE);
        args.putInt(EXTRA_TITLE, R.string.end_live_title);
        args.putInt(EXTRA_MESSAGE, R.string.end_live_message);
        args.putInt(EXTRA_BUTTON_POSITIVE, R.string.confirm);
        args.putInt(EXTRA_BUTTON_NEGATIVE, R.string.cancel);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "leave_confirm_dialog");
    }

    private final FragmentResultListener mEndLiveCallback = (requestKey, result) -> {
        final int button = result.getInt(EXTRA_RESULT);
        if (button == Dialog.BUTTON_POSITIVE) {
            mViewModel.requestFinishLive();
        }
    };

    /**
     * This method will use the list in Parameters to refresh the status information of the host,
     * Lianmai anchor, and yourself
     *
     * @param userList is used to refresh the data of users in the room
     */
    private void updateOnlineGuestList(List<LiveUserInfo> userList) {
        userList = userList == null ? Collections.emptyList() : userList;
        mGuestList.clear();

        for (LiveUserInfo userInfo : userList) {
            if (TextUtils.equals(userInfo.userId, mSelfInfo.userId)) {
                // I am a host, Filter OUT
                mSelfInfo = userInfo;

                if (getRoomStatus() == RoomStatus.PK) {
                    mSelfInfo.linkMicStatus = LiveLinkMicStatus.HOST_INTERACTING;
                } else {
                    mSelfInfo.linkMicStatus = LiveLinkMicStatus.AUDIENCE_INTERACTING;
                }
            } else {
                if (getRoomStatus() == RoomStatus.PK) {
                    mCoHostInfo = userInfo;
                } else {
                    mGuestList.add(userInfo);
                }
            }
        }

        mVideoRender.addLinkUserInfo(mGuestList);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveRTSUserEvent(LiveRTSUserEvent event) {
        if (!event.isJoin()) {
            removeAudienceLinkRequestByUerId(event.audienceUserId);
        }
        setAudienceCount(event.audienceCount);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveFinishEvent(LiveFinishEvent event) {
        if (TextUtils.equals(event.roomId, mViewModel.rtsRoomId())) {
            mViewModel.finishRequested = true;

            if (event.type == LiveFinishType.NORMAL) {
                showSummary(event.getLiveSummary());
                return;
            }
            if (event.type == LiveFinishType.TIMEOUT) {
                showToast(com.vertcdemo.rtc.toolkit.R.string.minutes_error_message);
            } else if (event.type == LiveFinishType.IRREGULARITY) {
                showToast(com.vertcdemo.rtc.toolkit.R.string.closed_terms_service);
            }
            popBackStack();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onRequestFinishLiveResult(RequestFinishLiveResultEvent event) {
        if (event.isSuccess()) {
            // Let onLiveFinishEvent handle the success event
        } else {
            popBackStack();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaChangedEvent(UserMediaChangedEvent event) {
        // ui, mic host interface changes, audience list status changes
        if (getRoomStatus() == RoomStatus.PK) {
            if (mCoHostInfo != null && TextUtils.equals(event.userId, mCoHostInfo.userId)) {
                mCoHostInfo.mic = event.mic;
                mCoHostInfo.camera = event.camera;
                mVideoRender.setLiveUserInfo(mCoHostInfo);
            } else if (TextUtils.equals(event.userId, mSelfInfo.userId)) {
                mSelfInfo.mic = event.mic;
                mSelfInfo.camera = event.camera;
                mVideoRender.setLiveUserInfo(mCoHostInfo);
            }
        }

        mVideoRender.onMediaChangedEvent(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveReconnectEvent(RTCReconnectToRoomEvent event) {
        LiveService.get().reconnect(mViewModel.rtsRoomId(), mLiveReconnectCallback);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveKickUserEvent(LiveKickUserEvent event) {
        showToast(getString(R.string.same_logged_in));
        popBackStack(); // kick by same uid login
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onNetworkQualityEvent(RTCNetworkQualityEvent event) {
        // local stats
        final NetworkQualityStats stats = event.localQuality;
        if (stats.txQuality <= NetworkQuality.NETWORK_QUALITY_GOOD) {
            // GOOD
            mBinding.networkState.setText(R.string.net_quality_good);
            mBinding.networkState.setCompoundDrawablesRelativeWithIntrinsicBounds(R.drawable.ic_network_quality_good, 0, 0, 0);
        } else if (stats.txQuality <= NetworkQuality.NETWORK_QUALITY_VERY_BAD) {
            // POOR
            mBinding.networkState.setText(R.string.net_quality_poor);
            mBinding.networkState.setCompoundDrawablesRelativeWithIntrinsicBounds(R.drawable.ic_network_quality_poor, 0, 0, 0);
        } else {
            // DISCONNECTED
            mBinding.networkState.setText(R.string.net_quality_disconnect);
            mBinding.networkState.setCompoundDrawablesRelativeWithIntrinsicBounds(R.drawable.ic_network_quality_disconnect, 0, 0, 0);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onNetworkQualityEvent(LiveCoreNetworkQualityEvent event) {
        final LiveCoreNetworkQualityEvent.Quality networkQuality = event.quality;
        if (networkQuality == LiveCoreNetworkQualityEvent.Quality.GOOD) {
            // GOOD
            mBinding.networkState.setText(R.string.net_quality_good);
            mBinding.networkState.setCompoundDrawablesRelativeWithIntrinsicBounds(R.drawable.ic_network_quality_good, 0, 0, 0);
        } else if (networkQuality == LiveCoreNetworkQualityEvent.Quality.POOR) {
            // POOR
            mBinding.networkState.setText(R.string.net_quality_poor);
            mBinding.networkState.setCompoundDrawablesRelativeWithIntrinsicBounds(R.drawable.ic_network_quality_poor, 0, 0, 0);
        } else if (networkQuality == LiveCoreNetworkQualityEvent.Quality.BAD) {
            // BAD
            mBinding.networkState.setText(R.string.net_quality_disconnect);
            mBinding.networkState.setCompoundDrawablesRelativeWithIntrinsicBounds(R.drawable.ic_network_quality_disconnect, 0, 0, 0);
        } else {
            // OTHERS to hide
            mBinding.networkState.setText("");
            mBinding.networkState.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLinkMicStatusEvent(LinkMicStatusEvent event) {
        int oldStatus = getRoomStatus();
        setRoomStatus(event.linkMicStatus);

        if (oldStatus == RoomStatus.PK && event.linkMicStatus != RoomStatus.PK) {
            // Server missed event: AnchorLinkFinishEvent, so we fake one
            onAnchorLinkFinishEvent(new AnchorLinkFinishEvent());
        }
    }

    public void addAudienceLinkRequest(AudienceLinkApplyEvent event) {
        final Iterator<AudienceLinkRequest> iterator = mAudienceLinkRequests.iterator();
        while (iterator.hasNext()) {
            final AudienceLinkRequest request = iterator.next();
            if (request.sameUser(event)) {
                iterator.remove();
                break;
            }
        }

        mAudienceLinkRequests.add(new AudienceLinkRequest(event));

        final ManageAudiencesDialog fragment = (ManageAudiencesDialog) getChildFragmentManager()
                .findFragmentByTag("manage-guests-dialog");
        if (fragment != null && fragment.isApplicationTab()) {
            mViewModel.showAudienceDot.postValue(false);
        } else {
            mViewModel.showAudienceDot.postValue(true);
        }
    }

    /**
     * Remove from Audience Link Request Queue
     *
     * @param userId updated user id
     * @see #onAudienceLinkStatusEvent
     */
    public void removeAudienceLinkRequestByUerId(String userId) {
        final Iterator<AudienceLinkRequest> iterator = mAudienceLinkRequests.iterator();
        while (iterator.hasNext()) {
            final AudienceLinkRequest request = iterator.next();
            if (request.sameUser(userId)) {
                iterator.remove();
                break;
            }
        }

        boolean hasRequest = mAudienceLinkRequests.size() > 0;
        if (!hasRequest) {
            mViewModel.showAudienceDot.postValue(false);
        }
    }
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkApplyEvent(AudienceLinkApplyEvent event) {
        addAudienceLinkRequest(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkCancelEvent(AudienceLinkCancelEvent event) {
        removeAudienceLinkRequestByUerId(event.userId);
    }

    @Override
    public List<LiveUserInfo> getLinkedAudiences() {
        return mGuestList;
    }

    @Override
    public List<AudienceLinkRequest> getAudienceLinkRequests() {
        return mAudienceLinkRequests;
    }

    @Override
    public void replyAudienceRequestByHost(AudienceLinkApplyEvent event, @LivePermitType int permitType) {
        Callback<PermitAudienceLinkResponse> callback;

        if (permitType == LivePermitType.ACCEPT) {
            LiveRTCManager.ins().joinRoom(mRTCRoomId, mSelfInfo.userId, mRTCToken);

            callback = new Callback<PermitAudienceLinkResponse>() {
                @Override
                public void onResponse(PermitAudienceLinkResponse data) {
                    handleAnchorPermitAudienceResponse(event.applicant.userId, data);
                }

                @Override
                public void onFailure(HttpException e) {
                    showToast(ErrorTool.getErrorMessage(e));
                }
            };
        } else {
            callback = OnNext.empty();
        }

        LiveService.get()
                .permitAudienceLink(
                        event.linkerId,
                        mViewModel.rtsRoomId(), mViewModel.anchorUserId(),
                        mViewModel.rtsRoomId(), event.applicant.userId,
                        permitType,
                        callback);

        if (permitType == LivePermitType.REJECT) {
            // No subsequence Event, so remove the request manually.
            removeAudienceLinkRequestByUerId(event.applicant.userId);
        }
    }
    // Audience Lianmai anchor side viewer reply anchor invitation result
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkReplyEvent(AudienceLinkReplyEvent event) {
        if (event.replyType == InviteReply.REJECT) {
            showToast(getString(R.string.xxx_declines_invite, event.userInfo.userName));
        } else if (event.replyType == InviteReply.ACCEPT) {
            updateOnlineGuestList(event.rtcUserList);
            if (mGuestList.size() == 1) {
                onFirstAudienceLink();
            }

            updateLiveTranscodingWithAudience();
        }
    }
    // Anchor Lianmai, the anchor side, received the host Lianmai invitation
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAnchorLinkInviteEvent(AnchorLinkInviteEvent event) {
        showAnchorLinkConfirmInviteDialog(event);
    }

    private void showAnchorLinkConfirmInviteDialog(AnchorLinkInviteEvent event) {
        AnchorLinkConfirmInviteDialog dialog = new AnchorLinkConfirmInviteDialog();
        Bundle args = new Bundle();
        args.putSerializable("userInfo", event.userInfo);
        args.putString("linkerId", event.linkerId);
        args.putString("extra", event.extra);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "anchor_link_invite");
    }

    private final FragmentResultListener mAnchorLinkInviteCallback = new FragmentResultListener() {
        @Override
        public void onFragmentResult(@NonNull String requestKey, @NonNull Bundle result) {
            boolean isAccept = result.getBoolean("accept");
            String linkerId = result.getString("linkerId");
            LiveUserInfo userInfo = (LiveUserInfo) result.getSerializable("userInfo");
            assert userInfo != null;

            final int reply = isAccept ? LivePermitType.ACCEPT : LivePermitType.REJECT;
            if (isAccept) {
                mLinkId = linkerId;
            }

            final Callback<LinkResponse> callback = isAccept ? mAnchorReplyInviteCallback : OnNext.empty();
            LiveService.get()
                            .replyAnchorLink(linkerId,
                            userInfo.roomId,
                            userInfo.userId,
                            mViewModel.rtsRoomId(),
                            mViewModel.anchorUserId(),
                            reply,
                            callback);
        }
    };
    // Anchor Lianmai, the anchor side, received the result of the host Lianmai invitation
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAnchorLinkReplyEvent(AnchorLinkReplyEvent event) {
        if (!TextUtils.equals(event.userInfo.userId, mSelfInfo.userId) && event.replyType == InviteReply.REJECT) {
            setRoomStatus(RoomStatus.LIVE);
            showToast(R.string.pk_invitation_reject);
        } else if (event.replyType == InviteReply.ACCEPT) {
            setRoomStatus(RoomStatus.PK);
            mLinkId = event.linkerId;
            for (LiveUserInfo info : event.rtcUserList) {
                if (!TextUtils.equals(info.userId, SolutionDataManager.ins().getUserId())) {
                    mCoHostInfo = info;
                    break;
                }
            }
            mVideoRender.setLiveUserInfo(mCoHostInfo);

            LiveRTCManager.ins().startCoHostPK(event.rtcRoomId, event.rtcToken, mCoHostInfo);
        }
    }
    // Audience mic, audience join or leave
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkStatusEvent(AudienceLinkStatusEvent event) {
        mLinkId = event.linkerId;
        if (event.isJoin()) {
            removeAudienceLinkRequestByUerId(event.userId);
            setRoomStatus(RoomStatus.AUDIENCE_LINK);
            updateOnlineGuestList(event.userList);
            if (mGuestList.size() == 1) {
                onFirstAudienceLink();
            }
            updateLiveTranscodingWithAudience();
        } else {
            for (LiveUserInfo userInfo : mGuestList) {
                if (TextUtils.equals(userInfo.userId, event.userId)) {
                    // showToast(getString(R.string.xxxdisconnected_live, userInfo.userName));
                    showToast(R.string.audience_link_disconnect_one);
                    break;
                }
            }

            updateOnlineGuestList(event.userList);
            updateLiveTranscodingWithAudience();
        }
    }
    // After the local interface request is successful,
    // it needs to send a local broadcast to update the user view
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkKickResultEvent(AudienceLinkKickResultEvent event) {
        final Iterator<LiveUserInfo> iterator = mGuestList.iterator();
        while (iterator.hasNext()) {
            final LiveUserInfo next = iterator.next();
            if (event.userId.equals(next.userId)) {
                iterator.remove();
            }
        }

        mVideoRender.addLinkUserInfo(mGuestList);
    }
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkFinishEvent(AudienceLinkFinishEvent event) {
        mRoomStatus = RoomStatus.LIVE;
        mStartAudienceLinkTime = 0;
        mSelfInfo.linkMicStatus = LiveLinkMicStatus.OTHER;
        updateOnlineGuestList(Collections.emptyList());

        LiveRTCManager.ins().stopLinkWithAudiences();
    }

    private void updateLiveTranscodingWithAudience() {
        final List<String> audienceIds = Streams.map(mGuestList, info -> info.userId);
        LiveRTCManager.ins().updateLinkWithAudiences(audienceIds);
    }
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAnchorLinkFinishEvent(AnchorLinkFinishEvent event) {
        setRoomStatus(RoomStatus.LIVE);
        showToast(getString(R.string.pk_has_ended));
        LiveRTCManager.ins().stopCoHostPK(); // onAnchorLinkFinishEvent
        updateOnlineGuestList(Collections.emptyList());
        mVideoRender.setLiveUserInfo();
        mCoHostInfo = null;
        mLinkId = null;
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onPublishStreamEvent(PublishVideoStreamEvent event) {
        mVideoRender.onPublishStreamEvent(event);
    }

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
        boolean isHost = TextUtils.equals(mViewModel.anchorUserId(), user.userId);

        mLiveChatAdapter.onNormalMessage(context, userName, content, isHost);
        mBinding.messagePanel.post(() -> mBinding.messagePanel.smoothScrollToPosition(mLiveChatAdapter.getItemCount()));
    }

    private void onGiftMessage(MessageEvent event) {
        mGiftAnimateHelper.post(event);
    }

    private void onLikeMessage(LiveUserInfo user) {
        mBinding.likeArea.startAnimation();
    }

    void popBackStack() {
        mViewModel.finishRequested = true;
        final View view = getView();
        if (view == null) {
            return;
        }
        Navigation.findNavController(view).popBackStack();
    }

    void showSummary(LiveSummary summary) {
        Bundle args = new Bundle();
        args.putParcelable("summary", summary);
        args.putLong("duration", SystemClock.uptimeMillis() - mViewModel.getLiveStartTime());
        Navigation.findNavController(requireView()).navigate(R.id.live_summary, args);
    }


    static void showToast(String message) {
        CenteredToast.show(message);
    }

    static void showToast(@StringRes int message) {
        CenteredToast.show(message);
    }
}