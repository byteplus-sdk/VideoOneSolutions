// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.song;

import static com.vertcdemo.solution.ktv.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.graphics.Typeface;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.ui.BottomDialogFragmentX;
import com.vertcdemo.core.utils.Streams;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.PickedSongInfo;
import com.vertcdemo.solution.ktv.bean.StatusPickedSongItem;
import com.vertcdemo.solution.ktv.bean.StatusSongItem;
import com.vertcdemo.solution.ktv.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.ktv.databinding.DialogKtvMusicLibraryBinding;
import com.vertcdemo.solution.ktv.event.InteractChangedBroadcast;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.TabViewModel;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.List;
import java.util.Objects;

public class MusicLibraryDialog extends BottomDialogFragmentX {
    private static final String TAG = "MusicLibraryDialog";

    private TabViewModel mViewModel;


    private KTVRoomViewModel mRoomViewModel;


    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRoomViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);
        mViewModel = new ViewModelProvider(this).get(TabViewModel.class);

        Bundle arguments = getArguments();
        if (arguments != null) {
            int tabIndex = arguments.getInt("tab_index", 0);
            mViewModel.index.setValue(tabIndex);
        }
    }

    @Override
    public int getTheme() {
        return R.style.KTVBottomSheetDialogTheme;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_ktv_music_library, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        ((BottomSheetDialog) Objects.requireNonNull(getDialog())).getBehavior().setDraggable(false);

        DialogKtvMusicLibraryBinding binding = DialogKtvMusicLibraryBinding.bind(view);

        binding.songLibraryTab.setOnClickListener(v -> mViewModel.index.postValue(0));
        binding.pickedSongTab.setOnClickListener(v -> mViewModel.index.postValue(1));

        MusicLibraryAdapter musicLibraryAdapter = new MusicLibraryAdapter(item -> {
            Log.d(TAG, "pickListener: " + item.status);
            if (item.status == SongStatus.NOT_DOWNLOAD) {
                mRoomViewModel.downloadTrack(item.getSongId());
            } else if (item.status == SongStatus.FINISH
                    || item.status == SongStatus.DOWNLOADED) {
                mRoomViewModel.requestSong(item.getSongId());
            }
        });

        binding.songLibrary.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.songLibrary.setItemAnimator(null);
        binding.songLibrary.setAdapter(musicLibraryAdapter);

        PickedSongsAdapter pickedSongsAdapter = new PickedSongsAdapter();
        binding.selectedSongs.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.selectedSongs.setItemAnimator(null);
        binding.selectedSongs.setAdapter(pickedSongsAdapter);

        mViewModel.index.observe(getViewLifecycleOwner(), tabIndex -> {
            if (tabIndex == 1) {
                binding.songLibraryTab.setSelected(false);
                binding.songLibraryTab.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                binding.groupSongLibrary.setVisibility(View.GONE);

                binding.pickedSongTab.setSelected(true);
                binding.pickedSongTab.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                binding.groupSelected.setVisibility(View.VISIBLE);

                if (pickedSongsAdapter.getItemCount() == 0) {
                    binding.emptyView.setText(R.string.label_music_picked_empty);
                    binding.emptyView.setVisibility(View.VISIBLE);
                } else {
                    binding.emptyView.setVisibility(View.GONE);
                }
            } else {
                binding.songLibraryTab.setSelected(true);
                binding.songLibraryTab.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                binding.groupSongLibrary.setVisibility(View.VISIBLE);

                binding.pickedSongTab.setSelected(false);
                binding.pickedSongTab.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                binding.groupSelected.setVisibility(View.GONE);

                if (musicLibraryAdapter.getItemCount() == 0) {
                    binding.emptyView.setText(R.string.label_music_library_empty);
                    binding.emptyView.setVisibility(View.VISIBLE);
                } else {
                    binding.emptyView.setVisibility(View.GONE);
                }
            }
        });

        mRoomViewModel.songLibrary.observe(getViewLifecycleOwner(), songs -> {
            Integer tabIndex = mViewModel.index.getValue();
            assert tabIndex != null;
            if (tabIndex == 0) {
                binding.emptyView.setText(R.string.label_music_library_empty);
                binding.emptyView.setVisibility(songs.isEmpty() ? View.VISIBLE : View.GONE);
            }

            musicLibraryAdapter.setList(songs);
        });

        mRoomViewModel.pickedSongs.observe(getViewLifecycleOwner(), songs -> {
            Integer tabIndex = mViewModel.index.getValue();
            assert tabIndex != null;
            if (tabIndex == 1) {
                binding.emptyView.setText(R.string.label_music_picked_empty);
                binding.emptyView.setVisibility(songs.isEmpty() ? View.VISIBLE : View.GONE);
            }

            PickedSongInfo playing = mRoomViewModel.getCurrentSong();

            List<StatusPickedSongItem> items = Streams.map(songs, item -> {
                boolean isPlaying = playing != null && TextUtils.equals(item.ownerUid, playing.ownerUid)
                        && TextUtils.equals(item.songId, playing.songId);
                return new StatusPickedSongItem(item, isPlaying);
            });

            pickedSongsAdapter.setList(items);
            if (items.isEmpty()) {
                binding.pickedSongTab.setText(R.string.button_karaoke_station_pick_song);
            } else {
                binding.pickedSongTab.setText(getString(R.string.button_karaoke_station_pick_song_xxx, items.size()));
            }
        });

        List<StatusSongItem> songs = mRoomViewModel.songLibrary.getValue();
        if (songs == null || songs.isEmpty()) {
            String roomId = mRoomViewModel.requireRoomId();
            mRoomViewModel.requestAllSongs(roomId);
        }

        SolutionEventBus.register(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInteractChangedBroadcast(InteractChangedBroadcast event) {
        if (event.isFinish() && TextUtils.equals(mRoomViewModel.myUserId(), event.getUserId())) {
            dismiss();
        }
    }

    @Override
    public void onDestroyView() {
        SolutionEventBus.unregister(this);
        super.onDestroyView();
    }
}
