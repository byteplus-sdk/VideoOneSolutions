// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.vod.function.fragment;

import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.layer.PlayPauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlaylistLayer;
import com.byteplus.vod.scenekit.ui.video.layer.adapter.PlayListItemAdapter;
import com.videoone.vod.function.PlaylistController;
import com.videoone.vod.function.VodFunctionActivity;

import java.util.List;

public class PlaylistFragment extends VodFunctionFragment implements PlayListItemAdapter.OnItemClickListener{

    private PlayListItemAdapter mAdapter;

    private PlaylistController mPlaylistController;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle bundle =requireArguments();
        List<VideoItem> videoList = (List<VideoItem>) bundle.getSerializable(VodFunctionActivity.EXTRA_VIDEO_LIST);
        String playMode = bundle.getString(VodFunctionActivity.EXTRA_PLAY_MODE, "loop");
        mPlaylistController = new PlaylistController(videoList, playMode, new PlaylistController.IPlaylistCallback() {
            @Override
            public void onPlayVideoChanged(VideoItem videoItem) {
                playVideo(videoItem);
                if (mAdapter != null) {
                    mAdapter.setPlayItem(videoItem);
                }
                VideoView videoView = getVideoView();
                VideoLayerHost layerHost = videoView == null ? null : videoView.layerHost();
                if (layerHost != null) {
                    PlaylistLayer layer = layerHost.findLayer(PlaylistLayer.class);
                    if (layer != null) {
                        layer.setPlayItem(videoItem);
                    }
                }
            }

            @Override
            public void onVideoStartPlay() {
                showNextBtn(mPlaylistController.hasNext());
                showPreviousBtn(mPlaylistController.hasPrevious());
            }
        });
    }

    @Override
    protected void addFunctionLayer(@NonNull VideoLayerHost layerHost) {
        super.addFunctionLayer(layerHost);
        layerHost.addLayer(new PlaylistLayer(new PlaylistLayer.IPlaylistLayerCallback() {
            @Override
            public List<VideoItem> getVideoList() {
                if (mPlaylistController != null) {
                    return mPlaylistController.getPlaylist();
                }
                return null;
            }

            @Override
            public VideoItem getPlayVideoItem() {
                if (mPlaylistController != null) {
                    return mPlaylistController.getPlayVideoItem();
                }
                return null;
            }

            @Override
            public void onItemClick(VideoItem videoItem) {
                if (mPlaylistController != null) {
                    mPlaylistController.playVideo(videoItem);
                }
            }
        }));
    }

    @Override
    protected boolean setupBottomContainer(FrameLayout container) {
        RecyclerView recyclerView = new RecyclerView(requireContext());
        container.addView(recyclerView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));
        mAdapter = new PlayListItemAdapter(requireContext(),PlayListItemAdapter.STYLE_HALFSCREEN, this);
        mAdapter.bindRecyclerView(recyclerView);
        mAdapter.setItems(mPlaylistController.getPlaylist());
        mAdapter.setPlayItem(mPlaylistController.getPlayVideoItem());
        mPlaylistController.addPlaybackListener(getVideoView());
        return true;
    }

    private void showNextBtn(boolean show) {
        VideoView videoView = getVideoView();
        if (videoView == null) {
            return;
        }
        VideoLayerHost layerHost = videoView.layerHost();
        if (layerHost == null) {
            return;
        }
        PlayPauseLayer layer = layerHost.findLayer(PlayPauseLayer.class);
        if (layer == null) {
            return;
        }
        layer.showNextBtn(show);
        layer.setNextBtnOnClickListener(v -> mPlaylistController.playNext());
    }

    private void showPreviousBtn(boolean show) {
        VideoView videoView = getVideoView();
        if (videoView == null) {
            return;
        }
        VideoLayerHost layerHost = videoView.layerHost();
        if (layerHost == null) {
            return;
        }
        PlayPauseLayer layer = layerHost.findLayer(PlayPauseLayer.class);
        if (layer == null) {
            return;
        }
        layer.showPreviousBtn(show);
        layer.setPreviousBtnOnClickListener(v -> mPlaylistController.playPrevious());
    }

    @Override
    public void onItemClick(VideoItem videoItem) {
        mPlaylistController.playVideo(videoItem);
    }
}
