// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room;

import static com.vertcdemo.solution.chorus.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.MutableLiveData;
import androidx.navigation.Navigation;

import com.bumptech.glide.Glide;
import com.bytedance.chrous.R;
import com.bytedance.chrous.databinding.FragmentChorusRoomStageBinding;
import com.vertcdemo.core.event.NetworkStatusEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.chorus.event.MusicLibraryInitEvent;
import com.vertcdemo.solution.chorus.bean.PickedSongInfo;
import com.vertcdemo.solution.chorus.bean.SongItem;
import com.vertcdemo.solution.chorus.core.MusicDownloadManager;
import com.vertcdemo.solution.chorus.core.rts.annotation.DownloadType;
import com.vertcdemo.solution.chorus.core.rts.annotation.SongStatus;
import com.vertcdemo.solution.chorus.event.DownloadStatusChanged;
import com.vertcdemo.solution.chorus.event.PlayProgressEvent;
import com.vertcdemo.solution.chorus.event.SDKAudioVolumeEvent;
import com.vertcdemo.solution.chorus.event.UserVideoEvent;
import com.vertcdemo.solution.chorus.feature.room.bean.SingerData;
import com.vertcdemo.solution.chorus.feature.room.state.SingState;
import com.vertcdemo.solution.chorus.feature.room.state.Singing;
import com.vertcdemo.solution.chorus.view.LrcView;
import com.vertcdemo.ui.CenteredToast;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.File;
import java.util.Locale;
import java.util.Objects;

public class ChorusRoomStageFragment extends Fragment {
    private static final String TAG = "ChorusRoomStageFragment";

    public ChorusRoomStageFragment() {
        super(R.layout.fragment_chorus_room_stage);
    }

    private ChorusRoomViewModel mViewModel;

    private final MutableLiveData<NetworkStatusEvent> networkStatusEvents = new MutableLiveData<>();
    private final MutableLiveData<SDKAudioVolumeEvent> audioVolumeEvents = new MutableLiveData<>();

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mViewModel = navGraphViewModelProvider(this, R.id.chorus_room_graph).get(ChorusRoomViewModel.class);
    }

    private final ActivityResultLauncher<String> startChorusLauncher = registerForActivityResult(new ActivityResultContracts.RequestPermission(), result -> {
        if (result == Boolean.TRUE) {
            mViewModel.startSing();
        } else {
            CenteredToast.show(R.string.toast_chorus_no_mic_permission);
        }
    });

    FragmentChorusRoomStageBinding binding;

    private LrcView mLrcView;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        binding = FragmentChorusRoomStageBinding.bind(view);
        mLrcView = binding.lrcView;

        binding.startChorus.setOnClickListener(DebounceClickListener.create(v -> {
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.RECORD_AUDIO)
                    == PackageManager.PERMISSION_GRANTED) {
                mViewModel.startSing();
            } else {
                startChorusLauncher.launch(Manifest.permission.RECORD_AUDIO);
            }
        }));

        mViewModel.originTrack.observe(getViewLifecycleOwner(), value -> binding.origin.setSelected(value == Boolean.TRUE));

        binding.origin.setOnClickListener(DebounceClickListener.create(v -> mViewModel.switchTrack()));
        binding.next.setOnClickListener(DebounceClickListener.create(v -> mViewModel.nextTrack()));
        binding.tuning.setOnClickListener(DebounceClickListener.create(v -> {
            Navigation.findNavController(v).navigate(R.id.action_tuning);
        }));

        binding.songs.setOnClickListener(DebounceClickListener.create(v -> {
            Bundle args = new Bundle();
            args.putInt("tab_index", 1);
            Navigation.findNavController(v).navigate(R.id.action_music_library, args);
        }));

        final ChorusSingerManager leaderSinger = new ChorusSingerManager(
                binding.leaderSinger,
                binding.networkStatusLeader,
                mViewModel);
        final ChorusSingerManager supportingSinger = new ChorusSingerManager(
                binding.supportingSinger,
                binding.networkStatusSupporting,
                mViewModel);

        mViewModel.leaderSinger.observe(getViewLifecycleOwner(), leaderData -> {
            leaderSinger.setSingerData(leaderData);

            SingerData supportingData = mViewModel.supportingSinger.getValue();
            boolean hasVideo = leaderData.hasVideo || (supportingData != null && supportingData.hasVideo);
            binding.bgStage.setVisibility(hasVideo ? View.GONE : View.VISIBLE);
            binding.bgShadow.setVisibility(hasVideo ? View.VISIBLE : View.GONE);
        });
        mViewModel.supportingSinger.observe(getViewLifecycleOwner(), supportingData -> {
            supportingSinger.setSingerData(supportingData);

            SingerData leaderData = mViewModel.supportingSinger.getValue();
            boolean hasVideo = supportingData.hasVideo || (leaderData != null && leaderData.hasVideo);
            binding.bgStage.setVisibility(hasVideo ? View.GONE : View.VISIBLE);
            binding.bgShadow.setVisibility(hasVideo ? View.VISIBLE : View.GONE);
        });

        mViewModel.singing.observe(getViewLifecycleOwner(), singing -> {
            SingState state = singing.state;
            if (state == SingState.WAITING_NEXT) {

                binding.startChorus.setVisibility(View.GONE);
                binding.songName.setVisibility(View.VISIBLE);

                PickedSongInfo song = Objects.requireNonNull(singing.song);
                binding.songName.setText(getString(R.string.chorus_next_song_hint, song.songName));
                binding.songName.setSelected(true);
            } else if (state == SingState.WAITING_JOIN) {
                binding.startChorus.setVisibility(View.VISIBLE);
                binding.songName.setVisibility(View.VISIBLE);

                PickedSongInfo song = Objects.requireNonNull(singing.song);
                binding.songName.setText(song.songName);
                binding.songName.setSelected(true);

                binding.startChorusTips.setText(mViewModel.isLeaderSinger() ? R.string.start_sing_solo : R.string.start_sing_chorus);
            } else {
                binding.startChorus.setVisibility(View.GONE);
                binding.songName.setVisibility(View.GONE);
            }

            if (state == SingState.SINGING) {
                binding.musicInfo.getRoot().setVisibility(View.VISIBLE);
                PickedSongInfo song = Objects.requireNonNull(singing.song);
                binding.musicInfo.trackTitle.setText(song.songName);
                Glide.with(binding.musicInfo.trackCover)
                        .load(song.coverUrl)
                        .placeholder(R.drawable.ic_play_original)
                        .into(binding.musicInfo.trackCover);
                binding.musicInfo.trackProgress.setText(R.string.zero_time);

                bindLrcView(song);
            } else {
                binding.musicInfo.getRoot().setVisibility(View.GONE);
            }

            binding.groupSinging.setVisibility(state == SingState.SINGING ? View.VISIBLE : View.GONE);
        });

        mViewModel.singerRole.observe(getViewLifecycleOwner(), singerRole -> {
            switch (singerRole) {
                case LEADER:
                    binding.origin.setEnabled(true);
                    binding.next.setEnabled(true);
                    binding.tuning.setEnabled(true);
                    break;
                case SUPPORTING:
                    binding.origin.setEnabled(false);
                    binding.next.setEnabled(false);
                    binding.tuning.setEnabled(true);
                    break;
                default:
                    binding.origin.setEnabled(false);
                    binding.next.setEnabled(false);
                    binding.tuning.setEnabled(false);
                    break;
            }
        });

        networkStatusEvents.observe(getViewLifecycleOwner(), leaderSinger::setNetworkStatus);
        networkStatusEvents.observe(getViewLifecycleOwner(), supportingSinger::setNetworkStatus);

        audioVolumeEvents.observe(getViewLifecycleOwner(), leaderSinger::setAudioVolumeEvent);
        audioVolumeEvents.observe(getViewLifecycleOwner(), supportingSinger::setAudioVolumeEvent);

        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    /**
     * RTC 用户开始或者停止视频采集事件回调
     */
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUserVideoEvent(UserVideoEvent event) {
        mViewModel.onUserVideoEvent(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onNetStatusEvent(NetworkStatusEvent event) {
        networkStatusEvents.setValue(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onSDKAudioVolumeEvent(SDKAudioVolumeEvent event) {
        audioVolumeEvents.setValue(event);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onReceivedPlayProgress(PlayProgressEvent event) {
        int duration = (int) mViewModel.currentDuration() / 1000;
        int progress = (int) (event.progress / 1000);
        String text = String.format(Locale.ENGLISH, "%02d:%02d/%02d:%02d", progress / 60, progress % 60, duration / 60, duration % 60);

        binding.musicInfo.trackProgress.setText(text);

        if (mLrcView != null) {
            mLrcView.updateTime(event.progress);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onDownloadStatusChanged(DownloadStatusChanged event) {
        if (event.contains(mViewModel.requireRoomId()) && event.status == SongStatus.DOWNLOADED) {
            if (event.type == DownloadType.LRC) {
                File lrcFile = MusicDownloadManager.lrcFile(event.songId);
                tryShowLrcView(lrcFile, event.songId);
            }
        }
    }

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

    private void tryShowLrcView(File lrcFile, String musicId) {
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
}
