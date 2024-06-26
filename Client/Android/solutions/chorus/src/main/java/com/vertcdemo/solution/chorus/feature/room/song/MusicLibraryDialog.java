// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room.song;


import static com.vertcdemo.solution.chorus.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.Manifest;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
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
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.DialogChorusMusicLibraryBinding;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.vertcdemo.core.ui.BottomDialogFragmentX;
import com.vertcdemo.core.utils.Streams;
import com.vertcdemo.solution.chorus.bean.PickedSongInfo;
import com.vertcdemo.solution.chorus.bean.StatusPickedSongItem;
import com.vertcdemo.solution.chorus.bean.StatusSongItem;
import com.vertcdemo.solution.chorus.common.SolutionToast;
import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.chorus.feature.room.ChorusRoomViewModel;

import java.util.List;
import java.util.Objects;

public class MusicLibraryDialog extends BottomDialogFragmentX {
    private static final String TAG = "MusicLibraryDialog";

    private LibraryViewModel mViewModel;
    private ChorusRoomViewModel mRoomViewModel;


    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRoomViewModel = navGraphViewModelProvider(this, R.id.chorus_room_graph).get(ChorusRoomViewModel.class);
        mViewModel = new ViewModelProvider(this).get(LibraryViewModel.class);

        Bundle arguments = getArguments();
        if (arguments != null) {
            int tabIndex = arguments.getInt("tab_index", 0);
            mViewModel.index.setValue(tabIndex);
        }
    }

    private final ActivityResultLauncher<String> pickSongLauncher = registerForActivityResult(new ActivityResultContracts.RequestPermission(), result -> {
        if (result == Boolean.TRUE) {
            Log.d(TAG, "pickListener: permission granted: ");
            StatusSongItem item = mViewModel.pending;
            if (item != null) {
                handleSongItem(item);
            }
        } else {
            SolutionToast.show(R.string.toast_chorus_no_mic_permission);
        }
        mViewModel.pending = null;
    });

    @Override
    public int getTheme() {
        return R.style.ChorusBottomSheetDialogTheme;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_chorus_music_library, container, false);
    }

    private void handleSongItem(@NonNull StatusSongItem item) {
        Log.d(TAG, "pickListener: handleSongItem: " + item.getSongName());
        if (item.status == SongStatus.NOT_DOWNLOAD) {
            mRoomViewModel.downloadTrack(item.getSongId());
        } else if (item.status == SongStatus.FINISH
                || item.status == SongStatus.DOWNLOADED) {
            mRoomViewModel.requestSong(item.getSongId());
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        ((BottomSheetDialog) Objects.requireNonNull(getDialog())).getBehavior().setDraggable(false);

        DialogChorusMusicLibraryBinding binding = DialogChorusMusicLibraryBinding.bind(view);

        binding.songLibraryTab.setOnClickListener(v -> mViewModel.index.postValue(0));
        binding.pickedSongTab.setOnClickListener(v -> mViewModel.index.postValue(1));

        MusicLibraryAdapter musicLibraryAdapter = new MusicLibraryAdapter(item -> {
            Log.d(TAG, "pickListener: " + item.status);
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.RECORD_AUDIO)
                    != PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "pickListener: request permission, set to pending.");
                mViewModel.pending = item;
                pickSongLauncher.launch(Manifest.permission.RECORD_AUDIO);
                return;
            }
            handleSongItem(item);
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
    }
}
