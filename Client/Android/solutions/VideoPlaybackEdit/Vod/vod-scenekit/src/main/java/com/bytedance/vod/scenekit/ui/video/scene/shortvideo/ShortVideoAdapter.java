// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.shortvideo;

import android.annotation.SuppressLint;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bytedance.playerkit.player.playback.DisplayModeHelper;
import com.bytedance.playerkit.player.playback.DisplayView;
import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.ui.video.layer.LoadingLayer;
import com.bytedance.vod.scenekit.ui.video.layer.PlayerConfigLayer;
import com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoCoverLayer;
import com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoDetailsLayer;
import com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoProgressBarLayer;
import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.ui.video.layer.LogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.PauseLayer;
import com.bytedance.vod.scenekit.ui.video.layer.PlayErrorLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.vertcdemo.base.ReportDialog;

import java.util.ArrayList;
import java.util.List;


public class ShortVideoAdapter extends RecyclerView.Adapter<ShortVideoAdapter.ViewHolder> {

    private final List<VideoItem> mItems = new ArrayList<>();

    @SuppressLint("NotifyDataSetChanged")
    public void setItems(List<VideoItem> videoItems) {
        mItems.clear();
        mItems.addAll(videoItems);
        notifyDataSetChanged();
    }

    public void prependItems(List<VideoItem> videoItems) {
        if (videoItems != null && !videoItems.isEmpty()) {
            mItems.addAll(0, videoItems);
            notifyItemRangeInserted(0, videoItems.size());
        }
    }

    @SuppressLint("NotifyDataSetChanged")
    public void appendItems(List<VideoItem> videoItems) {
        if (videoItems != null && !videoItems.isEmpty()) {
            int count = mItems.size();
            mItems.addAll(videoItems);
            if (count > 0) {
                notifyItemRangeInserted(count, mItems.size());
            } else {
                notifyDataSetChanged();
            }
        }
    }

    public void deleteItem(int position) {
        if (position >= 0 && position < mItems.size()) {
            mItems.remove(position);
            notifyItemRemoved(position);
        }
    }

    public VideoItem getItem(int position) {
        return mItems.get(position);
    }

    public List<VideoItem> getItems() {
        return mItems;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return ViewHolder.create(parent);
    }

    @Override
    public void onViewDetachedFromWindow(@NonNull ViewHolder holder) {
        holder.videoView.stopPlayback();
    }

    @Override
    public void onViewRecycled(@NonNull ViewHolder holder) {
        holder.videoView.stopPlayback();
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        VideoItem videoItem = mItems.get(position);
        holder.bind(position, videoItem);
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public final VideoView videoView;

        public static ViewHolder create(ViewGroup parent) {
            VideoView videoView = createVideoView(parent);
            videoView.setLayoutParams(new RecyclerView.LayoutParams(
                    RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.MATCH_PARENT));
            return new ViewHolder(videoView);
        }

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            videoView = (VideoView) itemView;
            videoView.setLayoutParams(new RecyclerView.LayoutParams(
                    RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.MATCH_PARENT));

            videoView.setOnLongClickListener(v -> {
                ReportDialog.show(v.getContext());
                return true;
            });
        }

        public void bind(int position, VideoItem videoItem) {
            MediaSource mediaSource = videoView.getDataSource();
            if (mediaSource == null) {
                mediaSource = VideoItem.toMediaSource(videoItem, false);
                videoView.bindDataSource(mediaSource);
            } else {
                if (!TextUtils.equals(videoItem.getVid(), mediaSource.getMediaId())) {
                    videoView.stopPlayback();
                    mediaSource = VideoItem.toMediaSource(videoItem, false);
                    videoView.bindDataSource(mediaSource);
                } else {
                    // do nothing
                }
            }

            ShortVideoDetailsLayer detailsLayer = videoView.layerHost().findLayer(ShortVideoDetailsLayer.class);
            assert detailsLayer != null;
            detailsLayer.bind(videoItem);
        }
    }

    static VideoView createVideoView(ViewGroup parent) {
        VideoView videoView = new VideoView(parent.getContext());
        VideoLayerHost layerHost = new VideoLayerHost(parent.getContext());
        layerHost.addLayer(new ShortVideoCoverLayer());
        layerHost.addLayer(new ShortVideoDetailsLayer());
        layerHost.addLayer(new LoadingLayer());
        layerHost.addLayer(new PauseLayer());
        layerHost.addLayer(new ShortVideoProgressBarLayer());
        layerHost.addLayer(new PlayErrorLayer());
        layerHost.addLayer(new PlayerConfigLayer(() -> {
            return VideoSettings.intValue(VideoSettings.SHORT_VIDEO_PLAYBACK_COMPLETE_ACTION) == 0; /* 0 means Loop */
        }));
        if (VideoSettings.booleanValue(VideoSettings.DEBUG_ENABLE_LOG_LAYER)) {
            layerHost.addLayer(new LogLayer());
        }
        layerHost.attachToVideoView(videoView);
        videoView.setBackgroundColor(parent.getResources().getColor(android.R.color.black));
        //videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT); // fit mode
        videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL); // immersive mode
        videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW);
        videoView.setPlayScene(PlayScene.SCENE_SHORT);
        return videoView;
    }
}

