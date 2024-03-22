// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.room;

import static com.vertcdemo.core.chat.ChatConfig.SEND_MESSAGE_COUNT_LIMIT;
import static com.vertcdemo.core.dialog.MessageInputDialog.REQUEST_KEY_MESSAGE_INPUT;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_REFERRER;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_ROOM_INFO;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_RTC_TOKEN;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_USER_INFO;
import static com.vertcdemo.solution.ktv.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.Manifest;
import android.app.Application;
import android.app.Dialog;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentResultListener;
import androidx.navigation.NavOptions;
import androidx.navigation.Navigation;
import androidx.navigation.fragment.NavHostFragment;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.ss.bytertc.engine.data.AudioMixingState;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.chat.ChatAdapter;
import com.vertcdemo.core.dialog.MessageInputDialog;
import com.vertcdemo.core.eventbus.RTCReconnectToRoomEvent;
import com.vertcdemo.core.eventbus.RTSLogoutEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.bean.SongItem;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.common.SolutionToast;
import com.vertcdemo.solution.ktv.core.ErrorCodes;
import com.vertcdemo.solution.ktv.core.KTVRTCManager;
import com.vertcdemo.solution.ktv.core.KTVRTSClient;
import com.vertcdemo.solution.ktv.core.MusicDownloadManager;
import com.vertcdemo.solution.ktv.core.rts.annotation.DownloadType;
import com.vertcdemo.solution.ktv.core.rts.annotation.FinishType;
import com.vertcdemo.solution.ktv.core.rts.annotation.ReplyType;
import com.vertcdemo.solution.ktv.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.ktv.databinding.FragmentKtvRoomBinding;
import com.vertcdemo.solution.ktv.databinding.LayoutKtvBottomOptionsBinding;
import com.vertcdemo.solution.ktv.event.AudienceApplyBroadcast;
import com.vertcdemo.solution.ktv.event.AudienceChangedBroadcast;
import com.vertcdemo.solution.ktv.event.AudioMixingStateEvent;
import com.vertcdemo.solution.ktv.event.AudioRouteChangedEvent;
import com.vertcdemo.solution.ktv.event.ClearUserBroadcast;
import com.vertcdemo.solution.ktv.event.DownloadStatusChanged;
import com.vertcdemo.solution.ktv.event.FinishLiveBroadcast;
import com.vertcdemo.solution.ktv.event.FinishSingBroadcast;
import com.vertcdemo.solution.ktv.event.InteractChangedBroadcast;
import com.vertcdemo.solution.ktv.event.InteractResultBroadcast;
import com.vertcdemo.solution.ktv.event.JoinRTSRoomErrorEvent;
import com.vertcdemo.solution.ktv.event.MediaOperateBroadcast;
import com.vertcdemo.solution.ktv.event.MessageBroadcast;
import com.vertcdemo.solution.ktv.event.MusicLibraryInitEvent;
import com.vertcdemo.solution.ktv.event.ReceivedInteractBroadcast;
import com.vertcdemo.solution.ktv.event.RequestSongBroadcast;
import com.vertcdemo.solution.ktv.event.StartSingBroadcast;
import com.vertcdemo.solution.ktv.feature.main.state.SingState;
import com.vertcdemo.solution.ktv.feature.main.state.Singing;
import com.vertcdemo.solution.ktv.feature.main.state.UserRoleState;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;
import com.vertcdemo.solution.ktv.lrc.LrcView;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

public class KTVRoomFragment extends Fragment {
    private static final String TAG = "KTVRoomFragment";

    public KTVRoomFragment() {
        super(R.layout.fragment_ktv_room);
    }

    static final int START_SING_WAITING_INTERVAL = 5000;
    static final int MSG_START_NEXT_SONG = 1;

    private final Handler mHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(@NonNull Message msg) {
            if (msg.what == MSG_START_NEXT_SONG) {
                KTVRTSClient rtsClient = KTVRTCManager.ins().getRTSClient();
                assert rtsClient != null;
                rtsClient.cutOffSong(mViewModel.requireRoomId(), mViewModel.myUserId());
            }
        }
    };

    /**
     * Android can't show dialogs in background, so we prepare a list pending the action to onStart()
     *
     * @see #onStart()
     */
    private final List<Runnable> mPendingActions = new ArrayList<>();

    private KTVRoomViewModel mViewModel;

    private int mSendMessageCount = 0;
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);

        Bundle arguments = requireArguments();
        String referrer = arguments.getString(EXTRA_REFERRER);

        RoomInfo roomInfo = Objects.requireNonNull(arguments.getParcelable(EXTRA_ROOM_INFO));
        mViewModel.setRoomInfo(roomInfo);

        if ("create".equals(referrer)) {
            UserInfo userInfo = Objects.requireNonNull(arguments.getParcelable(EXTRA_USER_INFO));
            mViewModel.setIsHost(true);
            mViewModel.setHostInfo(userInfo);
            mViewModel.setMyInfo(userInfo);

            mViewModel.userRoleState.setValue(UserRoleState.HOST);

            String rtcToken = arguments.getString(EXTRA_RTC_TOKEN);
            mViewModel.hostJoinLiveRoom(rtcToken);
        } else if ("list".equals(referrer)) {
            mViewModel.setIsHost(false);
            mViewModel.setMyInfo(UserInfo.self());

            mViewModel.requestJoinLiveRoom(mViewModel.requireRoomId());
        } else {
            throw new IllegalArgumentException("Unknown Referrer: " + referrer);
        }

        getChildFragmentManager()
                .setFragmentResultListener(REQUEST_KEY_LEAVE_CONFIRM, this, leaveConfirmResultListener);

        getChildFragmentManager()
                .setFragmentResultListener(REQUEST_KEY_ARGS_ERROR, this, argsErrorResultListener);

        getChildFragmentManager()
                .setFragmentResultListener(REQUEST_KEY_MESSAGE_INPUT, this, messageInputResultListener);
    }

    private FragmentKtvRoomBinding binding;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        WindowCompat.getInsetsController(requireActivity().getWindow(), view)
                .setAppearanceLightStatusBars(false);

        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(), new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                attemptLeave();
            }
        });
        binding = FragmentKtvRoomBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        mLrcView = binding.lrcView;

        // region Bottom Options
        binding.bottomOptions.actionInput.setOnClickListener(this::onInputClicked);
        binding.bottomOptions.actionMic.setOnClickListener(this::onMicClicked);
        binding.bottomOptions.actionInteract.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_manage_audience);
        });
        binding.bottomOptions.actionRequestSong.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_music_library);
        });
        mViewModel.appliedAudiences.observe(getViewLifecycleOwner(), applies -> {
            if (mViewModel.isHost()) {
                binding.bottomOptions.interactIndicator.setVisibility(
                        applies.isEmpty() ? View.GONE : View.VISIBLE
                );
            }
        });
        // endregion

        binding.tips.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_music_library);
        });

        mViewModel.singing.observe(getViewLifecycleOwner(), singing -> {
            SingState state = singing.state;
            binding.musicControls.setVisibility(state == SingState.SINGING ? View.VISIBLE : View.GONE);
            if (state == SingState.SINGING) {
                binding.groupSinging.setVisibility(View.VISIBLE);
                binding.groupTips.setVisibility(View.GONE);

                binding.tips.setEnabled(false);
                binding.tips.setText("");

                PickedSongInfo info = Objects.requireNonNull(singing.song);
                binding.musicInfo.trackTitle.setText(info.songName);
                Glide.with(binding.musicInfo.trackCover)
                        .load(info.coverUrl)
                        .placeholder(R.drawable.ic_play_original)
                        .into(binding.musicInfo.trackCover);

                bindLrcView(info);
            } else if (state == SingState.WAITING) {
                PickedSongInfo info = Objects.requireNonNull(singing.song);
                binding.groupSinging.setVisibility(View.GONE);
                binding.groupTips.setVisibility(View.VISIBLE);

                binding.tips.setEnabled(true);
                binding.tips.setText(getString(R.string.label_next_music_tip_xxx, info.songName));
            } else {
                binding.groupSinging.setVisibility(View.GONE);
                binding.groupTips.setVisibility(View.VISIBLE);

                if (mViewModel.isHost() || mViewModel.isInteract()) {
                    binding.tips.setEnabled(true);
                    binding.tips.setText(R.string.label_no_singing_host_tip);
                } else {
                    binding.tips.setEnabled(false);
                    binding.tips.setText(R.string.label_no_singing_audience_tip);
                }
            }
        });

        mViewModel.userRoleState.observe(getViewLifecycleOwner(), state -> {
            LayoutKtvBottomOptionsBinding bottomOptions = binding.bottomOptions;
            if (state == UserRoleState.HOST || state == UserRoleState.INTERACT) {
                bottomOptions.actionMic.setVisibility(View.VISIBLE);
                bottomOptions.actionInteract.setVisibility(state == UserRoleState.HOST ? View.VISIBLE : View.GONE);
                bottomOptions.groupRequestSong.setVisibility(View.VISIBLE);

                int pickedCount = mViewModel.getPickedCount();
                bottomOptions.selectCount.setText(String.valueOf(pickedCount));
                bottomOptions.selectCount.setVisibility(pickedCount > 0 ? View.VISIBLE : View.GONE);

                Singing singing = Objects.requireNonNull(mViewModel.singing.getValue());
                if (singing.state == SingState.EMPTY || singing.state == SingState.IDLE) {
                    binding.tips.setEnabled(true);
                    binding.tips.setText(R.string.label_no_singing_host_tip);
                }
            } else {
                bottomOptions.actionMic.setVisibility(View.GONE);
                bottomOptions.actionInteract.setVisibility(View.GONE);
                bottomOptions.groupRequestSong.setVisibility(View.GONE);
                bottomOptions.selectCount.setVisibility(View.GONE);

                Singing singing = Objects.requireNonNull(mViewModel.singing.getValue());
                if (singing.state == SingState.EMPTY || singing.state == SingState.IDLE) {
                    binding.tips.setEnabled(false);
                    binding.tips.setText(R.string.label_no_singing_audience_tip);
                }
            }
        });

        mViewModel.pickedSongs.observe(getViewLifecycleOwner(), pickedSongs -> {
            UserRoleState roleState = mViewModel.getUserRoleState();
            if (roleState == UserRoleState.HOST || roleState == UserRoleState.INTERACT) {
                int pickedCount = pickedSongs.size();
                binding.bottomOptions.selectCount.setText(String.valueOf(pickedCount));
                binding.bottomOptions.selectCount.setVisibility(pickedCount > 0 ? View.VISIBLE : View.GONE);
            } else {
                binding.bottomOptions.selectCount.setVisibility(View.GONE);
            }
        });

        mChatAdapter = ChatAdapter.bind(binding.messagePanel);

        KTVRTCManager.ins().setProgressCallback(this::updatePlayProgress);

        mViewModel.background.observe(getViewLifecycleOwner(), background -> {
            binding.getRoot().setBackgroundResource(background);
        });

        mViewModel.selfMicOn.observe(getViewLifecycleOwner(), selfMicOn -> {
            binding.bottomOptions.actionMic.setSelected(selfMicOn);
        });

        SolutionEventBus.register(this);
    }

    private LrcView mLrcView;

    private ChatAdapter mChatAdapter;

    private boolean isLeaveByKickOut = false;

    // region BottomActions
    private String mLastInputText;

    private final FragmentResultListener messageInputResultListener = (requestKey, result) -> {
        String content = result.getString(MessageInputDialog.EXTRA_CONTENT);
        boolean actionDone = result.getBoolean(MessageInputDialog.EXTRA_ACTION_DONE, false);
        if (actionDone) {
            mLastInputText = null;
            sendMessage(content);
        } else {
            mLastInputText = content;
        }
    };

    void onInputClicked(View view) {
        MessageInputDialog dialog = new MessageInputDialog();
        if (!TextUtils.isEmpty(mLastInputText)) {
            Bundle args = new Bundle();
            args.putString(MessageInputDialog.EXTRA_CONTENT, mLastInputText);
            dialog.setArguments(args);
        }
        dialog.show(getChildFragmentManager(), "message-input-dialog");
    }

    void onMicClicked(View view) {
        boolean current = Objects.requireNonNull(mViewModel.selfMicOn.getValue());
        boolean newValue = !current;
        if (newValue) {
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.RECORD_AUDIO)
                    != PackageManager.PERMISSION_GRANTED) {
                SolutionToast.show(R.string.toast_ktv_no_mic_permission);
            }
        }

        mViewModel.updateSelfMediaStatus(mViewModel.requireRoomId(), newValue);
    }
    // endregion

    // region Live Status
    private static final String REQUEST_KEY_LEAVE_CONFIRM = "leave_confirm";

    private final FragmentResultListener leaveConfirmResultListener = (requestKey, result) -> {
        int option = result.getInt(SolutionCommonDialog.EXTRA_RESULT);
        if (option == Dialog.BUTTON_POSITIVE) {
            leaveRoom();
        }
    };

    void attemptLeave() {
        if (!mViewModel.isHost()) {
            leaveRoom();
            return;
        }
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        Bundle args = SolutionCommonDialog.dialogArgs(
                REQUEST_KEY_LEAVE_CONFIRM,
                R.string.label_alert_live_end,
                R.string.button_alert_live_end,
                R.string.cancel
        );
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), REQUEST_KEY_LEAVE_CONFIRM);
    }

    private void leaveRoom() {
        SolutionEventBus.unregister(this);
        KTVRTCManager.ins().leaveRoom();
        KTVRTCManager.ins().stopAudioMixing();
        if (!isLeaveByKickOut) {
            KTVRTSClient rtsClient = KTVRTCManager.ins().getRTSClient();
            assert rtsClient != null;
            if (mViewModel.isHost()) {
                rtsClient.requestFinishLive(mViewModel.requireRoomId());
            } else {
                rtsClient.requestLeaveRoom(mViewModel.requireRoomId());
            }
        }

        Navigation.findNavController(requireView())
                .popBackStack(R.id.ktv_room_graph, true);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onRTSLogoutEvent(RTSLogoutEvent event) {
        leaveRoom();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onFinishLiveBroadcast(FinishLiveBroadcast event) {
        if (!TextUtils.equals(event.roomId, mViewModel.requireRoomId())) {
            return;
        }
        boolean isHost = mViewModel.isHost();
        if (event.type == FinishType.BLOCKED) {
            SolutionToast.show(R.string.toast_false_violates_rules);
        } else if (event.type == FinishType.TIMEOUT && isHost) {
            SolutionToast.show(R.string.toast_false_time_out);
        } else if (!isHost) {
            SolutionToast.show(R.string.toast_false_live_end);
        }
        leaveRoom();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onReconnectToRoom(RTCReconnectToRoomEvent event) {
        mViewModel.reconnectRoom();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onJoinRTSRoomErrorEvent(JoinRTSRoomErrorEvent event) {
        if (event.isReconnect) {
            leaveRoom();
            return;
        }
        String message = ErrorCodes.prettyMessage(event.errorCode, event.message);
        onArgsError(message);
    }

    private static final String REQUEST_KEY_ARGS_ERROR = "args_error";

    private final FragmentResultListener argsErrorResultListener = (requestKey, result) -> {
        leaveRoom();
    };

    private void onArgsError(String message) {
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        dialog.setArguments(SolutionCommonDialog.dialogArgs(REQUEST_KEY_ARGS_ERROR, message, R.string.confirm));
        dialog.show(getChildFragmentManager(), REQUEST_KEY_ARGS_ERROR);
    }
    // endregion

    // region Message
    private void sendMessage(final String message) {
        if (TextUtils.isEmpty(message)) {
            SolutionToast.show(R.string.send_empty_message_cannot_be_empty);
            return;
        }

        if (mSendMessageCount >= SEND_MESSAGE_COUNT_LIMIT) {
            SolutionToast.show(R.string.send_message_exceeded_limit);
            return;
        }
        mSendMessageCount++;

        KTVRTSClient rtsClient = KTVRTCManager.ins().getRTSClient();
        assert rtsClient != null;

        UserInfo myInfo = mViewModel.getMyInfo();
        onNormalMessage(myInfo.userId, myInfo.userName, message);

        try {
            String messageEncoded = URLEncoder.encode(message, "utf-8");
            rtsClient.sendMessage(mViewModel.requireRoomId(), messageEncoded);
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }

    private void onSystemMessage(String message) {
        mChatAdapter.addChatMsg(message);
        RecyclerView recyclerView = binding.messagePanel;
        recyclerView.post(() -> recyclerView.smoothScrollToPosition(mChatAdapter.getItemCount()));
    }

    private void onNormalMessage(String userId, String userName, String message) {
        boolean isHost = mViewModel.isHost(userId);
        mChatAdapter.onNormalMessage(
                requireContext(),
                userName,
                message,
                isHost
        );
        RecyclerView recyclerView = binding.messagePanel;
        recyclerView.post(() -> recyclerView.smoothScrollToPosition(mChatAdapter.getItemCount()));
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageBroadcast(MessageBroadcast event) {
        if (TextUtils.equals(event.userInfo.userId, mViewModel.myUserId())) {
            return;
        }
        try {
            String message = URLDecoder.decode(event.message, "UTF-8");
            onNormalMessage(
                    event.userInfo.userId,
                    event.userInfo.userName,
                    message
            );
        } catch (UnsupportedEncodingException e) {
            Log.d(TAG, "onMessageBroadcast: exception", e);
        }
    }
    // endregion

    // region User Join/Interact/Seat/Media
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceChangedBroadcast(AudienceChangedBroadcast event) {
        if (mViewModel.isHost()) {
            String roomId = mViewModel.requireRoomId();
            if (event.isJoin) {
                // User Join Room, Only need to refresh online list
                mViewModel.requestOnlineAudiences(roomId);
            } else {
                mViewModel.requestOnlineAudiences(roomId);
                mViewModel.requestApplyAudiences(roomId);
            }
        }
        if (event.isJoin) {
            onSystemMessage(getString(R.string.im_label_join_room, event.userInfo.userName));
        } else {
            onSystemMessage(getString(R.string.im_label_leave_room, event.userInfo.userName));
        }
        mViewModel.audienceCount.postValue(event.audienceCount);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInteractChangedBroadcast(InteractChangedBroadcast event) {
        if (mViewModel.isHost()) {
            String roomId = mViewModel.requireRoomId();
            mViewModel.requestOnlineAudiences(roomId);
            mViewModel.requestApplyAudiences(roomId);
        }

        if (event.isJoin()) {
            onSystemMessage(getString(R.string.toast_become_guest_xxx, event.userInfo.userName));
        } else {
            onSystemMessage(getString(R.string.toast_become_audience_xxx, event.userInfo.userName));
        }

        UserInfo myInfo = mViewModel.getMyInfo();
        boolean isSelf = TextUtils.equals(myInfo.userId, event.userInfo.userId);
        if (!isSelf) {
            return;
        }
        mViewModel.updateSelf(event.userInfo);

        if (event.isJoin()) {
            SolutionToast.show(R.string.toast_become_guest);
            mViewModel.startInteract();
            String roomId = mViewModel.requireRoomId();
            mViewModel.requestPickedSongList(roomId);
        } else {
            if (event.isByHost()) {
                SolutionToast.show(R.string.toast_passive_audience);
            } else {
                SolutionToast.show(R.string.toast_become_audience);
            }
            mViewModel.stopInteract();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInteractResultBroadcast(InteractResultBroadcast event) {
        if (mViewModel.isHost()) {
            String roomId = mViewModel.requireRoomId();
            mViewModel.requestOnlineAudiences(roomId);
            mViewModel.requestApplyAudiences(roomId);
        }
        if (event.reply == ReplyType.REJECT) {
            Application context = AppUtil.getApplicationContext();
            String message = context.getString(R.string.toast_receive_invitation_received_xxx, event.userInfo.userName);
            SolutionToast.show(message);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onReceivedInteractBroadcast(ReceivedInteractBroadcast event) {
        Runnable action = () -> {
            Bundle args = new Bundle();
            args.putInt("seat_id", event.seatId);
            NavOptions navOptions = new NavOptions.Builder()
                    .setPopUpTo(R.id.ktv_room, false)
                    .build();


            NavHostFragment.findNavController(this)
                    .navigate(R.id.action_confirm_invite, args, navOptions);
        };

        FragmentManager fragmentManager = getParentFragmentManager();
        if (fragmentManager.isStateSaved()) {
            // Pending the request
            mPendingActions.add(action);
        } else {
            action.run();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceApplyBroadcast(AudienceApplyBroadcast event) {
        if (mViewModel.isHost()) {
            String roomId = mViewModel.requireRoomId();
            mViewModel.requestOnlineAudiences(roomId);
            mViewModel.requestApplyAudiences(roomId);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaOperateBroadcast(MediaOperateBroadcast event) {
        boolean isMicOn = event.mic == MediaStatus.ON;
        SolutionToast.show(isMicOn ? R.string.toast_receive_unmute : R.string.toast_receive_mute);

        mViewModel.updateSelfMediaStatus(mViewModel.requireRoomId(), isMicOn);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onClearUserBroadcast(ClearUserBroadcast event) {
        if (TextUtils.equals(SolutionDataManager.ins().getUserId(), event.userId)) {
            SolutionToast.show(R.string.toast_receive_clear_user);
            isLeaveByKickOut = true;
            leaveRoom();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudioRouteChangedEvent(AudioRouteChangedEvent event) {
        if (!event.canOpenEarMonitor()) {
            mViewModel.setEarMonitorSwitch(false);
        }
    }
    // endregion

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMusicLibraryInitEvent(MusicLibraryInitEvent event) {
        Singing singing = Objects.requireNonNull(mViewModel.singing.getValue());
        if (singing.state == SingState.SINGING) {
            PickedSongInfo info = Objects.requireNonNull(singing.song);
            bindLrcView(info);
        }
    }

    private void bindLrcView(@NonNull PickedSongInfo info) {
        mLrcView.setToken(info.songId);
        File lrc = MusicDownloadManager.lrcFile(info.songId);
        if (lrc.exists()) {
            mLrcView.loadLrc(lrc);
        } else {
            SongItem songItem = mViewModel.getSongItem(info.songId);
            if (songItem == null) {
                Log.d(TAG, "bindLrcView: SongItem not found for: " + info);
                return;
            }
            String lrcUrl = songItem.songLrcUrl;
            MusicDownloadManager.ins().downloadLrc(
                    info.songId,
                    info.roomId,
                    lrcUrl
            );
        }
    }

    private void tryShowLrcView(@NonNull File lrcFile, String musicId) {
        if (mLrcView == null) {
            return;
        }
        if (!TextUtils.equals(mLrcView.getToken(), musicId)) {
            return;
        }

        PickedSongInfo curSong = mViewModel.getCurrentSong();
        boolean isCurSong = curSong != null && TextUtils.equals(curSong.songId, musicId);
        if (isCurSong) {
            mLrcView.loadLrc(lrcFile);
        }
    }

    @Override
    public void onStart() {
        super.onStart();

        for (Runnable action : mPendingActions) {
            action.run();
        }

        mPendingActions.clear();
    }

    @Override
    public void onDestroyView() {
        KTVRTCManager.ins().setProgressCallback(null);
        mHandler.removeCallbacksAndMessages(null);
        super.onDestroyView();
        mViewModel.resetControl();
    }

    // region Song Status
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onRequestSongBroadcast(RequestSongBroadcast event) {
        mViewModel.onRequestSongBroadcast(event);
        PickedSongInfo song = event.song;
        if (song == null) {
            Log.w(TAG, "onRequestSongBroadcast: PickedSongInfo isNull");
            return;
        }

        mViewModel.downloadSongLrc(song.songId);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onStartSingBroadcast(StartSingBroadcast event) {
        mHandler.removeMessages(MSG_START_NEXT_SONG);
        mViewModel.onStartSingBroadcast(event);
        mViewModel.resetControl();
        PickedSongInfo next = event.song;
        KTVRTCManager.ins().stopAudioMixing();
        if (next == null) {
            mViewModel.singing.postValue(Singing.EMPTY);
            return;
        }

        if (!TextUtils.equals(mViewModel.myUserId(), next.ownerUid)) {
            mViewModel.singing.postValue(Singing.singing(next));
            return;
        }

        mViewModel.startSingSong(next);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onFinishSingBroadcast(FinishSingBroadcast event) {
        mHandler.removeMessages(MSG_START_NEXT_SONG);
        mViewModel.onFinishSingBroadcast(event);

        PickedSongInfo currentSong = event.currentSong;
        assert currentSong != null;

        String myUserId = mViewModel.myUserId();
        boolean isSinger = TextUtils.equals(currentSong.ownerUid, myUserId);

        if (isSinger) {
            KTVRTCManager.ins().stopAudioMixing();
        }

        if (mViewModel.isHost()) {
            // Host or Current Singer has Permission to Start NEXT song
            // So let Host to boot the NEXT event
            mHandler.sendEmptyMessageDelayed(MSG_START_NEXT_SONG, START_SING_WAITING_INTERVAL);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onDownloadStatusChanged(DownloadStatusChanged event) {
        mViewModel.onDownloadStatusChanged(event);
        if (event.roomIds.contains(mViewModel.requireRoomId()) && event.status == SongStatus.DOWNLOADED) {
            if (event.type == DownloadType.LRC) {
                File lrcFile = MusicDownloadManager.lrcFile(event.songId);
                tryShowLrcView(lrcFile, event.songId);
            }
        }
    }

    @MainThread
    void updatePlayProgress(String musicId, long progressMs) {
        PickedSongInfo curSingSong = mViewModel.getCurrentSong();
        if (curSingSong == null) return;
        if (!TextUtils.equals(musicId, curSingSong.songId)) {
            // 检查当前歌曲id，只有同步的相同才同步
            return;
        }
        int duration = curSingSong.duration / 1000;
        int progress = (int) (progressMs / 1000);
        String text = String.format(Locale.ENGLISH, "%02d:%02d/%02d:%02d", progress / 60, progress % 60, duration / 60, duration % 60);

        binding.musicInfo.trackProgress.setText(text);
        if (mLrcView != null) {
            mLrcView.updateTime(progressMs);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudioMixingStateEvent(AudioMixingStateEvent event) {
        if (event.state == AudioMixingState.AUDIO_MIXING_STATE_FINISHED) {
            mViewModel.finishSinging();
        } else if (event.state == AudioMixingState.AUDIO_MIXING_STATE_PAUSED) {
            mViewModel.isAudioMixing.postValue(false);
        } else if (event.state == AudioMixingState.AUDIO_MIXING_STATE_PLAYING) {
            mViewModel.isAudioMixing.postValue(true);
        }
    }
    // endregion
}
