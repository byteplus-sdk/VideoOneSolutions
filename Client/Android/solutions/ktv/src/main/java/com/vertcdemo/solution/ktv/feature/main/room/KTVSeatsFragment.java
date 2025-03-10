// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.room;

import static com.vertcdemo.core.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.NavOptions;
import androidx.navigation.Navigation;

import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;
import com.vertcdemo.solution.ktv.bean.SeatInfo;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserStatus;
import com.vertcdemo.solution.ktv.databinding.FragmentKtvSeatGroupBinding;
import com.vertcdemo.solution.ktv.event.FinishSingBroadcast;
import com.vertcdemo.solution.ktv.event.InitSeatDataEvent;
import com.vertcdemo.solution.ktv.event.InteractChangedBroadcast;
import com.vertcdemo.solution.ktv.event.MediaChangedBroadcast;
import com.vertcdemo.solution.ktv.event.SDKAudioPropertiesEvent;
import com.vertcdemo.solution.ktv.event.SeatChangedBroadcast;
import com.vertcdemo.solution.ktv.event.StartSingBroadcast;
import com.vertcdemo.solution.ktv.feature.main.seat.SeatLayout;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;
import com.vertcdemo.ui.CenteredToast;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class KTVSeatsFragment extends Fragment {
    private static final String TAG = "KTVSeatsFragment";

    private KTVRoomViewModel mViewModel;


    public KTVSeatsFragment() {
        super(R.layout.fragment_ktv_seat_group);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);
    }

    private SeatLayout mHostSeatLayout;
    private final Map<Integer, SeatLayout> mSeatIdMap = new HashMap<>();

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        FragmentKtvSeatGroupBinding binding = FragmentKtvSeatGroupBinding.bind(view);

        mHostSeatLayout = binding.seat0.getRoot();
        mSeatIdMap.put(1, binding.seat1.getRoot());
        mSeatIdMap.put(2, binding.seat2.getRoot());
        mSeatIdMap.put(3, binding.seat3.getRoot());
        mSeatIdMap.put(4, binding.seat4.getRoot());
        mSeatIdMap.put(5, binding.seat5.getRoot());
        mSeatIdMap.put(6, binding.seat6.getRoot());

        mHostSeatLayout.initWithIndex(0);

        for (int i = 1; i <= 6; i++) {
            SeatLayout layout = mSeatIdMap.get(i);
            assert layout != null;
            layout.initWithIndex(i);

            layout.setOnClickListener(DebounceClickListener.create(
                    v -> {
                        int seatId = layout.getSeatId();
                        SeatInfo seatInfo = layout.getSeatInfo();
                        if (mViewModel.isHost()) {
                            NavOptions navOptions = new NavOptions.Builder()
                                    .setPopUpTo(R.id.ktv_room, false)
                                    .build();

                            // Handle host click seat
                            Bundle args = new Bundle();
                            args.putInt("seat_id", seatId);
                            args.putParcelable("seat_info", seatInfo);
                            Navigation.findNavController(requireView())
                                    .navigate(R.id.action_manage_seat, args, navOptions);
                        } else {
                            handleAudienceClickSeat(seatId, seatInfo);
                        }
                    }
            ));
        }

        mViewModel.hostInfo.observe(getViewLifecycleOwner(), host -> {
            SeatInfo info = SeatInfo.byUserInfo(host);
            mHostSeatLayout.setSeatInfo(info);
        });

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        SolutionEventBus.unregister(this);
        super.onDestroyView();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInitSeatDataEvent(InitSeatDataEvent event) {
        Map<Integer, SeatInfo> seatMap = event.seatMap;

        for (Map.Entry<Integer, SeatInfo> entry : seatMap.entrySet()) {
            int seatId = entry.getKey();
            SeatInfo info = entry.getValue();
            assert info != null;

            SeatLayout layout = mSeatIdMap.get(seatId);
            if (layout == null) {
                Log.d(TAG, "onInitSeatDataEvent: found a unknown seatId: " + seatId);
                continue;
            }

            layout.setSeatInfo(info);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInteractChangedBroadcast(InteractChangedBroadcast event) {
        SeatLayout seat = mSeatIdMap.get(event.seatId);
        if (seat == null) {
            return;
        }

        if (event.isJoin()) {
            SeatInfo info = new SeatInfo();
            info.userInfo = event.userInfo;
            seat.setSeatInfo(info);
        } else {
            seat.clearSeat();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onSeatChangedBroadcast(SeatChangedBroadcast event) {
        SeatLayout seat = mSeatIdMap.get(event.seatId);
        if (seat != null) {
            seat.updateSeatLockStatus(event.type);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaChangedBroadcast(MediaChangedBroadcast event) {
        String userId = event.userInfo.userId;
        boolean micOn = event.mic == MediaStatus.ON;

        mHostSeatLayout.updateMicStatus(userId, micOn);

        for (SeatLayout layout : mSeatIdMap.values()) {
            if (layout.updateMicStatus(userId, micOn)) {
                break;
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onSDKAudioPropertiesEvent(SDKAudioPropertiesEvent event) {
        List<SDKAudioPropertiesEvent.AudioProperties> infos = event.audioPropertiesList;
        if (infos.isEmpty()) {
            return;
        }
        for (SDKAudioPropertiesEvent.AudioProperties info : infos) {
            onUserSpeaker(info.userId, info.isSpeaking());
        }
    }

    void onUserSpeaker(String userId, boolean isSpeaking) {
        if (mHostSeatLayout.updateSpeakingStatus(userId, isSpeaking)) {
            return;
        }

        for (SeatLayout layout : mSeatIdMap.values()) {
            if (layout.updateSpeakingStatus(userId, isSpeaking)) {
                break;
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onStartSingBroadcast(StartSingBroadcast event) {
        PickedSongInfo song = event.song;
        updateSingStatus(song == null ? null : song.ownerUid);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onFinishSingBroadcast(FinishSingBroadcast event) {
        PickedSongInfo song = event.nextSong;
        String nextOwnerId = song == null ? null : song.ownerUid;

        updateSingStatus(nextOwnerId);
    }

    void updateSingStatus(@Nullable String ownerUid) {
        for (SeatLayout layout : mSeatIdMap.values()) {
            layout.updateSingStatus(ownerUid);
        }
        mHostSeatLayout.updateSingStatus(ownerUid);
    }

    void handleAudienceClickSeat(int seatId, SeatInfo seatInfo) {
        if (seatInfo.isLocked()) {
            Log.d(TAG, "handleAudienceClickSeat: SKIP: Seat isLocked");
            return;
        }

        UserInfo userInfo = seatInfo.userInfo;
        if (userInfo != null && !TextUtils.equals(mViewModel.myUserId(), userInfo.userId)) {
            Log.d(TAG, "handleAudienceClickSeat: SKIP: Click another one's Seat");
            return;
        } else if (userInfo != null) {
            Log.d(TAG, "handleAudienceClickSeat: Click yourself Seat");
        } else {
            Log.d(TAG, "handleAudienceClickSeat: Click empty Seat");
            if (mViewModel.myUserStatus() == UserStatus.INTERACT) {
                CenteredToast.show(R.string.toast_error_switch_seat);
                return;
            } else if (mViewModel.myUserStatus() == UserStatus.NORMAL) {
                if (mViewModel.getSelfApply()) {
                    CenteredToast.show(R.string.toast_apply_guest);
                    return;
                }
            }
        }

        NavOptions navOptions = new NavOptions.Builder()
                .setPopUpTo(R.id.ktv_room, false)
                .build();

        Bundle args = new Bundle();
        args.putInt("seat_id", seatId);
        args.putParcelable("seat_info", seatInfo);
        Navigation.findNavController(requireView())
                .navigate(R.id.action_manage_seat, args, navOptions);
    }
}
