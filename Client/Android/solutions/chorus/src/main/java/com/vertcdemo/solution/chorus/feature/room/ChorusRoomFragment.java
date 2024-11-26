// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room;

import static com.vertcdemo.core.chat.ChatConfig.SEND_MESSAGE_COUNT_LIMIT;
import static com.vertcdemo.core.chat.input.MessageInputDialog.REQUEST_KEY_MESSAGE_INPUT;
import static com.vertcdemo.solution.chorus.feature.ChorusActivity.EXTRA_REFERRER;
import static com.vertcdemo.solution.chorus.feature.ChorusActivity.EXTRA_ROOM_INFO;
import static com.vertcdemo.solution.chorus.feature.ChorusActivity.EXTRA_RTC_TOKEN;
import static com.vertcdemo.solution.chorus.feature.ChorusActivity.EXTRA_USER_INFO;
import static com.vertcdemo.solution.chorus.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.Manifest;
import android.app.Dialog;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.activity.OnBackPressedCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentResultListener;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.RecyclerView;

import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.FragmentChorusRoomBinding;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.chat.ChatAdapter;
import com.vertcdemo.core.chat.input.MessageInputDialog;
import com.vertcdemo.core.event.AudioRouteChangedEvent;
import com.vertcdemo.core.event.ClearUserEvent;
import com.vertcdemo.core.event.JoinRTSRoomErrorEvent;
import com.vertcdemo.core.event.RTCReconnectToRoomEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.solution.chorus.bean.FinishLiveInform;
import com.vertcdemo.solution.chorus.bean.FinishSingInform;
import com.vertcdemo.solution.chorus.bean.MessageInform;
import com.vertcdemo.solution.chorus.bean.PickedSongInfo;
import com.vertcdemo.solution.chorus.bean.PickedSongInform;
import com.vertcdemo.solution.chorus.bean.RoomInfo;
import com.vertcdemo.solution.chorus.bean.StartSingInform;
import com.vertcdemo.solution.chorus.bean.UserInfo;
import com.vertcdemo.solution.chorus.bean.WaitSingInform;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;
import com.vertcdemo.solution.chorus.core.ErrorCodes;
import com.vertcdemo.solution.chorus.event.AudienceChangedEvent;
import com.vertcdemo.solution.chorus.event.DownloadStatusChanged;
import com.vertcdemo.solution.chorus.event.PlayFinishEvent;
import com.vertcdemo.solution.chorus.feature.room.state.CaptureControl;
import com.vertcdemo.solution.chorus.feature.room.state.SingState;
import com.vertcdemo.solution.chorus.feature.room.state.UserRoleState;
import com.vertcdemo.solution.chorus.http.ChorusService;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Objects;

public class ChorusRoomFragment extends Fragment {
    private static final String TAG = "ChorusRoomFragment";

    private ChorusRoomViewModel mViewModel;

    public ChorusRoomFragment() {
        super(R.layout.fragment_chorus_room);
    }

    private final Handler mHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = navGraphViewModelProvider(this, R.id.chorus_room_graph).get(ChorusRoomViewModel.class);

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
            mViewModel.hostJoinRTCRoom(rtcToken);
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

    private final ActivityResultLauncher<String> cameraLauncher = registerForActivityResult(new ActivityResultContracts.RequestPermission(), result -> {
        if (result == Boolean.TRUE) {
            mViewModel.toggleCamera();
        } else {
            CenteredToast.show(R.string.toast_chorus_no_camera_permission);
        }
    });

    FragmentChorusRoomBinding binding;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(), new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                attemptLeave();
            }
        });
        binding = FragmentChorusRoomBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        mViewModel.background.observe(getViewLifecycleOwner(), background -> {
            binding.getRoot().setBackgroundResource(background);
        });

        // region Bottom Options
        binding.bottomOptions.actionInput.setOnClickListener(this::onInputClicked);
        binding.bottomOptions.actionRequestSong.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_music_library);
        });

        mViewModel.pickedSongs.observe(getViewLifecycleOwner(), pickedSongs -> {
            int pickedCount = pickedSongs.size();
            binding.bottomOptions.selectCount.setText(String.valueOf(pickedCount));
            binding.bottomOptions.selectCount.setVisibility(pickedCount > 0 ? View.VISIBLE : View.GONE);
        });

        binding.bottomOptions.actionMic.setOnClickListener(v -> {
            mViewModel.toggleMic();
        });

        mViewModel.captureControlMic.observe(getViewLifecycleOwner(), control -> {
            binding.bottomOptions.actionMic.setVisibility(control != CaptureControl.GONE ? View.VISIBLE : View.GONE);
            binding.bottomOptions.actionMic.setEnabled(control == CaptureControl.ENABLED);
        });

        mViewModel.selfMicOn.observe(getViewLifecycleOwner(), on -> {
            binding.bottomOptions.actionMic.setSelected(on);
        });

        binding.bottomOptions.actionCamera.setOnClickListener(v -> {
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.CAMERA)
                    == PackageManager.PERMISSION_GRANTED) {
                mViewModel.toggleCamera();
            } else {
                cameraLauncher.launch(Manifest.permission.CAMERA);
            }
        });

        mViewModel.captureControlCamera.observe(getViewLifecycleOwner(), control -> {
            binding.bottomOptions.actionCamera.setVisibility(control != CaptureControl.GONE ? View.VISIBLE : View.GONE);
            binding.bottomOptions.actionCamera.setEnabled(control == CaptureControl.ENABLED);
        });

        mViewModel.selfCameraOn.observe(getViewLifecycleOwner(), on -> {
            binding.bottomOptions.actionCamera.setSelected(on);
        });
        // endregion

        mChatAdapter = ChatAdapter.bind(binding.messagePanel);

        mViewModel.singing.observe(getViewLifecycleOwner(), singing -> {
            SingState state = singing.state;
            if (state == SingState.EMPTY || state == SingState.IDLE) {
                binding.groupTips.setVisibility(View.VISIBLE);
                binding.tips.setText(R.string.label_no_singing_host_tip);

                binding.roomStage.setVisibility(View.GONE);
            } else {
                binding.groupTips.setVisibility(View.GONE);

                binding.roomStage.setVisibility(View.VISIBLE);
            }
        });

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        SolutionEventBus.unregister(this);
        mHandler.removeCallbacksAndMessages(null);
        super.onDestroyView();
    }

    // region Live Status
    private static final String REQUEST_KEY_LEAVE_CONFIRM = "leave_confirm";

    private final FragmentResultListener leaveConfirmResultListener = (requestKey, result) -> {
        int option = result.getInt(SolutionCommonDialog.EXTRA_RESULT);
        if (option == Dialog.BUTTON_POSITIVE) {
            leaveRoom(); // Confirm Leave Room
        }
    };

    public void attemptLeave() {
        if (!mViewModel.isHost()) {
            leaveRoom(); // Audience Leave Room
            return;
        }
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        Bundle args = SolutionCommonDialog.dialogArgs(
                REQUEST_KEY_LEAVE_CONFIRM,
                R.string.label_alert_live_end,
                R.string.button_alert_live_end,
                com.vertcdemo.rtc.toolkit.R.string.cancel
        );
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), REQUEST_KEY_LEAVE_CONFIRM);
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
        ChorusRTCManager.ins().leaveRoom();
        if (!callServer) {
            if (mViewModel.isHost()) {
                ChorusService.get()
                        .finishLive(mViewModel.requireRoomId());
            } else {
                ChorusService.get()
                        .leaveRoom(mViewModel.requireRoomId());
            }
        }

        Navigation.findNavController(requireView())
                .popBackStack(R.id.chorus_room_graph, true);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onReconnectToRoom(RTCReconnectToRoomEvent event) {
        mViewModel.reconnectRoom();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onJoinRTSRoomErrorEvent(JoinRTSRoomErrorEvent event) {
        String message = ErrorCodes.prettyMessage(event.errorCode, event.message);
        if (event.isReconnect) {
            CenteredToast.show(message);
            leaveRoom(false); // Reconnect Failed
            return;
        }
        onArgsError(message);
    }

    private static final String REQUEST_KEY_ARGS_ERROR = "args_error";

    private final FragmentResultListener argsErrorResultListener = (requestKey, result) -> {
        leaveRoom(false); // Confirm Join Room Error
    };

    private void onArgsError(String message) {
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        dialog.setArguments(SolutionCommonDialog.dialogArgs(REQUEST_KEY_ARGS_ERROR, message, com.vertcdemo.base.R.string.confirm));
        dialog.show(getChildFragmentManager(), REQUEST_KEY_ARGS_ERROR);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onClearUserBroadcast(ClearUserEvent event) {
        if (TextUtils.equals(SolutionDataManager.ins().getUserId(), event.userId)) {
            CenteredToast.show(R.string.same_logged_in);
            leaveRoom(false); // Same user login
        }
    }
    // endregion

    /**
     * 来自业务服务端的进房/退房通知
     */
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceChangedBroadcast(AudienceChangedEvent event) {
        if (event.isJoin) {
            onSystemMessage(getString(R.string.im_label_join_room, event.userInfo.userName));
        } else {
            onSystemMessage(getString(R.string.im_label_leave_room, event.userInfo.userName));
            // After User Leave
            // The songs which picked by them will be cleared by server.
            mViewModel.requestPickedSongList(mViewModel.requireRoomId());
        }

        mViewModel.audienceCount.postValue(event.audienceCount);
    }

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
    // endregion

    // region Message
    private int mSendMessageCount = 0;

    private ChatAdapter mChatAdapter;

    private void sendMessage(final String message) {
        if (TextUtils.isEmpty(message)) {
            CenteredToast.show(com.vertcdemo.rtc.toolkit.R.string.send_empty_message_cannot_be_empty);
            return;
        }

        if (mSendMessageCount >= SEND_MESSAGE_COUNT_LIMIT) {
            CenteredToast.show(com.vertcdemo.rtc.toolkit.R.string.send_message_exceeded_limit);
            return;
        }
        mSendMessageCount++;

        UserInfo myInfo = mViewModel.getMyInfo();
        onNormalMessage(myInfo.userId, myInfo.userName, message);

        try {
            String messageEncoded = URLEncoder.encode(message, "utf-8");

            ChorusService.get()
                    .sendMessage(mViewModel.requireRoomId(), messageEncoded);
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
    public void onMessageBroadcast(MessageInform event) {
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
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onFinishLiveInform(FinishLiveInform event) {
        if (!TextUtils.equals(event.roomId, mViewModel.requireRoomId())) {
            return;
        }
        boolean isHost = mViewModel.isHost();
        if (isHost) {
            if (event.type == FinishLiveInform.FINISH_TYPE_AGAINST) {
                CenteredToast.show(com.vertcdemo.rtc.toolkit.R.string.closed_terms_service);
            } else if (event.type == FinishLiveInform.FINISH_TYPE_TIMEOUT) {
                CenteredToast.show(R.string.finish_room_by_overtime);
            }
        } else {
            CenteredToast.show(R.string.toast_chorus_live_is_end);
        }
        leaveRoom(false); // Live End
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onDownloadStatusChanged(DownloadStatusChanged event) {
        mViewModel.onDownloadStatusChanged(event);
    }

    /***来自业务服务端的点歌通知*/
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onPickSongInform(PickedSongInform event) {
        mViewModel.onPickSongInform(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onWaitSingInform(WaitSingInform event) {
        mViewModel.onWaitSingInform(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onStartSingInform(StartSingInform event) {
        mViewModel.onStartSingInform(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onFinishSingInform(FinishSingInform event) {
        Log.d(TAG, "onFinishSingInform: ");
        // Should call before status may changed
        mViewModel.finishSinging("FinishSingInform");

        PickedSongInfo curSingSong = mViewModel.getCurrentSong();
        if (curSingSong != null && TextUtils.equals(curSingSong.ownerUid, mViewModel.myUserId())) {
            if (event.nextSong == null) { // Switch to null
                // No song left, notify Switch to empty imminently
                mViewModel.nextTrack(true);
            } else {
                // Next song exists, wait 5s to next
                mHandler.postDelayed(() -> {
                    mViewModel.nextTrack(true);
                }, 5000);
            }
        }
        mViewModel.onFinishSingInform(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onPlayFinishEvent(PlayFinishEvent event) {
        mViewModel.onPlayFinishEvent(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudioRouteChangedEvent(AudioRouteChangedEvent event) {
        if (!event.canOpenEarMonitor()) {
            mViewModel.setEarMonitorSwitch(false);
        }
    }
}
