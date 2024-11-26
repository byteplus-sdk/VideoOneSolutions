// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.seat;

import static com.vertcdemo.solution.ktv.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.Manifest;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentResultListener;
import androidx.navigation.NavOptions;
import androidx.navigation.fragment.NavHostFragment;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.SeatInfo;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.core.rts.annotation.SeatOption;
import com.vertcdemo.solution.ktv.core.rts.annotation.SeatStatus;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserRole;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserStatus;
import com.vertcdemo.solution.ktv.databinding.DialogKtvSeatOptionBinding;
import com.vertcdemo.solution.ktv.event.AudienceChangedEvent;
import com.vertcdemo.solution.ktv.event.InteractChangedBroadcast;
import com.vertcdemo.solution.ktv.event.MediaChangedBroadcast;
import com.vertcdemo.solution.ktv.event.SeatChangedBroadcast;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class SeatOptionDialog extends BottomSheetDialogFragment {
    private static final String TAG = "SeatOptionDialog";

    public static final String REQUEST_KEY_CONFIRM_LOCK = "confirm-lock-seat";

    private int mSeatId;
    @NonNull
    private SeatInfo mSeatInfo;

    @Override
    public int getTheme() {
        return R.style.KTVBottomSheetDialog;
    }

    private KTVRoomViewModel mRoomViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRoomViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);

        Bundle arguments = requireArguments();
        mSeatId = arguments.getInt("seat_id");
        SeatInfo seatInfo = arguments.getParcelable("seat_info");
        assert seatInfo != null;
        mSeatInfo = seatInfo;

        getChildFragmentManager().setFragmentResultListener(REQUEST_KEY_CONFIRM_LOCK, this, new FragmentResultListener() {
            @Override
            public void onFragmentResult(@NonNull String requestKey, @NonNull Bundle result) {
                int selection = result.getInt(SolutionCommonDialog.EXTRA_RESULT);
                if (selection == DialogInterface.BUTTON_POSITIVE) {
                    mRoomViewModel.managerSeat(mRoomViewModel.requireRoomId(), mSeatId, SeatOption.LOCK);
                }
                dismiss();
            }
        });
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_ktv_seat_option, container, false);
    }

    private DialogKtvSeatOptionBinding binding;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        binding = DialogKtvSeatOptionBinding.bind(view);

        binding.optionInteract.setOnClickListener(this::onClickInteract);
        binding.optionMic.setOnClickListener(this::onClickMicStatus);
        binding.optionSeatLock.setOnClickListener(this::onClickLockStatus);

        UserInfo myInfo = mRoomViewModel.getMyInfo();

        boolean isSelfHost = myInfo.isHost();

        UserInfo userInfo = mSeatInfo.userInfo;
        if (userInfo == null) {
            updateInteractStatus(mSeatInfo.status, UserStatus.NORMAL, myInfo.userRole);
            updateMicStatus(mSeatInfo.status, MediaStatus.ON, isSelfHost, true);
        } else {
            updateInteractStatus(mSeatInfo.status, userInfo.userStatus, myInfo.userRole);
            updateMicStatus(mSeatInfo.status, userInfo.mic, isSelfHost, false);
        }
        updateSeatStatus(mSeatInfo.status, isSelfHost);

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        SolutionEventBus.unregister(this);
        super.onDestroyView();
    }

    private void updateInteractStatus(@SeatStatus int seatStatus,
                                      @UserStatus int userStatus,
                                      @UserRole int selfRole) {

        boolean isLocked = seatStatus == SeatStatus.LOCKED;
        if (isLocked) {
            binding.optionInteract.setVisibility(View.GONE);
            return;
        }

        binding.optionInteract.setVisibility(View.VISIBLE);
        binding.optionInteract.setSelected(userStatus == UserStatus.INTERACT);

        if (selfRole == UserRole.HOST) {
            if (userStatus != UserStatus.INTERACT) {
                binding.optionInteract.setText(R.string.button_user_list_invited_guest);
            } else {
                binding.optionInteract.setText(R.string.button_sheet_remove_guest);
            }
        } else {
            if (userStatus != UserStatus.INTERACT) {
                binding.optionInteract.setText(R.string.button_sheet_become_guest);
            } else {
                binding.optionInteract.setText(R.string.button_sheet_become_audience);
            }
        }
    }

    private void updateMicStatus(@SeatStatus int seatStatus,
                                 @MediaStatus int micStatus,
                                 boolean isSelfHost,
                                 boolean isEmpty) {
        boolean isLocked = seatStatus == SeatStatus.LOCKED;
        boolean show = !isLocked && isSelfHost && !isEmpty;
        if (!show) {
            binding.optionMic.setVisibility(View.GONE);
            return;
        }

        binding.optionMic.setVisibility(View.VISIBLE);
        binding.optionMic.setSelected(micStatus == MediaStatus.ON);

        binding.optionMic.setText(micStatus == MediaStatus.ON ?
                R.string.button_sheet_mute : R.string.button_sheet_unmute);
    }

    private void updateSeatStatus(@SeatStatus int status, boolean isSelfHost) {
        if (!isSelfHost) {
            binding.optionSeatLock.setVisibility(View.GONE);
            return;
        }

        binding.optionSeatLock.setSelected(status == SeatStatus.UNLOCKED);
        binding.optionSeatLock.setText(status == SeatStatus.UNLOCKED ? R.string.button_sheet_lock : R.string.button_sheet_unlock);
    }

    void onClickInteract(View view) {
        String roomId = mRoomViewModel.requireRoomId();
        int selfStatus = mRoomViewModel.myUserStatus();

        boolean isHost = mRoomViewModel.isHost();
        if (mSeatInfo.userInfo == null) {
            if (isHost) {
                Bundle args = new Bundle();
                args.putInt("seat_id", mSeatId);
                NavOptions options = new NavOptions.Builder()
                        .setPopUpTo(R.id.ktv_room, false)
                        .build();
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_manage_audience, args, options);
            } else {
                if (selfStatus == UserStatus.APPLYING) {
                    CenteredToast.show(R.string.toast_apply_guest);
                } else if (selfStatus == UserStatus.INTERACT) {
                    CenteredToast.show(R.string.toast_error_switch_seat);
                } else if (selfStatus == UserStatus.NORMAL) {
                    if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.RECORD_AUDIO)
                            == PackageManager.PERMISSION_GRANTED) {
                        doApplySeat();
                    } else {
                        launcher.launch(Manifest.permission.RECORD_AUDIO);
                    }
                }
            }
        } else {
            boolean isSelf = TextUtils.equals(mSeatInfo.userInfo.userId, mRoomViewModel.myUserId());
            if (isHost && !isSelf) {
                mRoomViewModel.managerSeat(roomId, mSeatId, SeatOption.END_INTERACT);
            } else if (!isHost && isSelf) {
                mRoomViewModel.finishInteract(roomId, mSeatId);
                dismiss();
            }
        }
    }

    void onClickMicStatus(View view) {
        if (mSeatInfo.userInfo == null) {
            return;
        }
        UserInfo userInfo = mSeatInfo.userInfo;
        int option = userInfo.isMicOn() ? SeatOption.MIC_OFF : SeatOption.MIC_ON;
        mRoomViewModel.managerSeat(mRoomViewModel.requireRoomId(), mSeatId, option);
        dismiss();
    }

    void onClickLockStatus(View view) {
        if (mSeatInfo.isLocked()) {
            mRoomViewModel.managerSeat(mRoomViewModel.requireRoomId(), mSeatId, SeatOption.UNLOCK);
            dismiss();
        } else {
            SolutionCommonDialog dialog = new SolutionCommonDialog();
            Bundle args = SolutionCommonDialog.dialogArgs("confirm-lock-seat"
                    , R.string.toast_lock_seat,
                    com.vertcdemo.base.R.string.confirm,
                    com.vertcdemo.base.R.string.cancel);
            dialog.setArguments(args);
            dialog.show(getChildFragmentManager(), "confirm-lock-seat");
        }
    }

    private void checkIfClose(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        UserInfo userInfo = mSeatInfo.userInfo;
        if (userInfo != null && TextUtils.equals(userInfo.userId, userId)) {
            dismiss();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceChangedBroadcast(AudienceChangedEvent event) {
        checkIfClose(event.userInfo.userId);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInteractChangedBroadcast(InteractChangedBroadcast event) {
        if (event.seatId == mSeatId) {
            dismiss();
            return;
        }
        checkIfClose(event.userInfo.userId);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaChangedBroadcast(MediaChangedBroadcast event) {
        checkIfClose(event.userInfo.userId);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onSeatChangedBroadcast(SeatChangedBroadcast event) {
        if (event.seatId == mSeatId && event.type != mSeatInfo.status) {
            dismiss();
        }
    }

    void doApplySeat() {
        String roomId = mRoomViewModel.requireRoomId();
        mRoomViewModel.applySeatRequest(roomId, mSeatId);
        dismiss();
    }

    final ActivityResultLauncher<String> launcher = registerForActivityResult(new ActivityResultContracts.RequestPermission(), result -> {
        if (result != Boolean.TRUE) {
            Log.d(TAG, "No permission: " + Manifest.permission.RECORD_AUDIO);
            CenteredToast.show(R.string.toast_ktv_no_mic_permission);
        }
        doApplySeat();
    });
}
