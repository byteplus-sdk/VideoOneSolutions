// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.room;

import static com.vertcdemo.core.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;
import com.vertcdemo.solution.ktv.databinding.FragmentKtvControlsBinding;
import com.vertcdemo.solution.ktv.feature.main.state.SingState;
import com.vertcdemo.solution.ktv.feature.main.state.UserRoleState;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;

public class KTVRoomControlsFragment extends Fragment {
    private static final String TAG = "KTVRoomControls";


    public KTVRoomControlsFragment() {
        super(R.layout.fragment_ktv_controls);
    }

    private KTVRoomViewModel mRoomViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRoomViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        FragmentKtvControlsBinding binding = FragmentKtvControlsBinding.bind(view);

        binding.origin.setOnClickListener(v -> {
            v.setSelected(!v.isSelected());

            mRoomViewModel.switchTrack();
        });

        binding.pausePlay.setOnClickListener(v -> {
            v.setSelected(!v.isSelected());
            mRoomViewModel.switchPausePlay();
        });

        binding.next.setOnClickListener(v -> {
            mRoomViewModel.nextTrack();
        });

        binding.tuning.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_tuning);
        });

        binding.songs.setOnClickListener(v -> {
            Bundle args = new Bundle();
            args.putInt("tab_index", 1);
            Navigation.findNavController(v).navigate(R.id.action_music_library, args);
        });

        mRoomViewModel.originTrack.observe(getViewLifecycleOwner(), binding.origin::setSelected);
        mRoomViewModel.isAudioMixing.observe(getViewLifecycleOwner(), isAudioMixing -> binding.pausePlay.setSelected(!isAudioMixing));
        mRoomViewModel.singing.observe(getViewLifecycleOwner(), state -> {
            if (state.state == SingState.SINGING) {
                PickedSongInfo song = state.song;
                assert song != null;

                boolean isMySong = TextUtils.equals(song.ownerUid, mRoomViewModel.myUserId());
                binding.origin.setEnabled(isMySong);
                binding.pausePlay.setEnabled(isMySong);
                binding.next.setEnabled(isMySong || mRoomViewModel.isHost());
                binding.tuning.setEnabled(isMySong);
            }
        });

        mRoomViewModel.userRoleState.observe(getViewLifecycleOwner(), state -> {
            binding.songs.setEnabled(state == UserRoleState.HOST || state == UserRoleState.INTERACT);
        });
    }
}
