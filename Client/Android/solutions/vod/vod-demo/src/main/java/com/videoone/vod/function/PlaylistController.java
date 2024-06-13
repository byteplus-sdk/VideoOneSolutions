// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.vod.function;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class PlaylistController {

    public interface IPlaylistCallback {
        void onPlayVideoChanged(VideoItem videoItem);
        void onVideoStartPlay();
    }

    private final List<VideoItem> mVideoList;
    private final String mPlayMode;

    private final AtomicInteger mPlayIndex = new AtomicInteger(0);

    private final IPlaylistCallback mPlaylistCallback;

    private final Dispatcher.EventListener mPlaybackListener = event -> {
        switch (event.code()) {
            case PlaybackEvent.Action.START_PLAYBACK: {
                notifyStartPlay();
                break;
            }
            case PlayerEvent.State.COMPLETED: {
                playNext();
                break;
            }
        }
    };

    public PlaylistController(List<VideoItem> videoList, String playMode, IPlaylistCallback callback) {
        mVideoList = videoList;
        mPlayMode = playMode;
        mPlaylistCallback = callback;
    }

    private void notifyStartPlay() {
        mPlaylistCallback.onVideoStartPlay();
    }

    public VideoItem getPlayVideoItem() {
        return mPlayIndex.get() < mVideoList.size() ? mVideoList.get(mPlayIndex.get()) : null;
    }

    public List<VideoItem> getPlaylist() {
        return mVideoList;
    }

    public void playVideo(VideoItem videoItem) {
        for (int i = 0; i < mVideoList.size(); i++) {
            VideoItem item = mVideoList.get(i);
            if (videoItem == item) {
                mPlayIndex.set(i);
            }
        }
        mPlaylistCallback.onPlayVideoChanged(videoItem);
    }

    public boolean hasNext() {
        return mPlayIndex.get() < mVideoList.size() - 1;
    }

    public boolean hasPrevious() {
        return mPlayIndex.get() > 0;
    }

    public void playNext() {
        if (!hasNext() && !"loop".equals(mPlayMode)) {
            return;
        }
        if (mPlayIndex.get() >= mVideoList.size() - 1) {
            mPlayIndex.set(0);
            mPlaylistCallback.onPlayVideoChanged(mVideoList.get(mPlayIndex.get()));
        } else {
            mPlaylistCallback.onPlayVideoChanged(mVideoList.get(mPlayIndex.incrementAndGet()));
        }
    }

    public void playPrevious() {
        if (!hasPrevious()  && !"loop".equals(mPlayMode)) {
            return;
        }
        if (mPlayIndex.get() <= 0) {
            mPlayIndex.set(mVideoList.size() - 1);
            mPlaylistCallback.onPlayVideoChanged(mVideoList.get(mPlayIndex.get()));
        } else {
            mPlaylistCallback.onPlayVideoChanged(mVideoList.get(mPlayIndex.decrementAndGet()));
        }
    }

    public void removePlaybackListener(VideoView videoView) {
        if (videoView != null) {
            PlaybackController controller = videoView.controller();
            if (controller != null) {
                controller.removePlaybackListener(mPlaybackListener);
            }
        }
    }

    public void addPlaybackListener(VideoView videoView) {
        if (videoView != null) {
            PlaybackController controller = videoView.controller();
            if (controller != null) {
                controller.addPlaybackListener(mPlaybackListener);
            }
        }
    }

}
