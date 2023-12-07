// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene.feedvideo;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Rect;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bytedance.playerkit.player.playback.DisplayModeHelper;
import com.bytedance.playerkit.player.playback.DisplayView;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.databinding.VevodFeedVideoItemBinding;
import com.bytedance.vod.scenekit.ui.base.VideoViewExtras;
import com.bytedance.vod.scenekit.ui.video.layer.CoverLayer;
import com.bytedance.vod.scenekit.ui.video.layer.FullScreenLayer;
import com.bytedance.vod.scenekit.ui.video.layer.GestureLayer;
import com.bytedance.vod.scenekit.ui.video.layer.LoadingLayer;
import com.bytedance.vod.scenekit.ui.video.layer.LockLayer;
import com.bytedance.vod.scenekit.ui.video.layer.LogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.PlayCompleteLayer;
import com.bytedance.vod.scenekit.ui.video.layer.PlayErrorLayer;
import com.bytedance.vod.scenekit.ui.video.layer.PlayPauseLayer;
import com.bytedance.vod.scenekit.ui.video.layer.SyncStartTimeLayer;
import com.bytedance.vod.scenekit.ui.video.layer.TimeProgressBarLayer;
import com.bytedance.vod.scenekit.ui.video.layer.TipsLayer;
import com.bytedance.vod.scenekit.ui.video.layer.TitleBarLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.QualitySelectDialogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.SpeedSelectDialogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.TimeProgressDialogLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.VolumeBrightnessDialogLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.vod.scenekit.ui.video.scene.feedvideo.layer.FeedVideoCoverShadowLayer;
import com.bytedance.vod.scenekit.utils.UIUtils;
import com.bytedance.vod.scenekit.utils.FormatHelper;
import com.bytedance.vod.scenekit.utils.ViewUtils;
import com.videoone.avatars.Avatars;

import java.util.ArrayList;
import java.util.List;


public class FeedVideoAdapter extends RecyclerView.Adapter<FeedVideoAdapter.ViewHolder> {

    public interface OnItemViewListener {
        void onItemClick(ViewHolder holder);

        void onVideoViewClick(ViewHolder holder);

        void onEvent(ViewHolder viewHolder, Event event);
    }

    private final List<VideoItem> mItems = new ArrayList<>();
    private final OnItemViewListener mOnItemViewListener;

    private boolean mIsLoadingMore;

    public FeedVideoAdapter(OnItemViewListener listener) {
        this.mOnItemViewListener = listener;
    }

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
                notifyItemRangeInserted(count, videoItems.size());
            } else {
                notifyDataSetChanged();
            }
        }
    }

    public VideoItem getItem(int position) {
        return mItems.get(position);
    }

    public List<VideoItem> getItems() {
        return mItems;
    }

    public void setLoadingMore(boolean loadingMore) {
        mIsLoadingMore = loadingMore;
    }

    public boolean isLoadingMore() {
        return mIsLoadingMore;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(
                VevodFeedVideoItemBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false),
                mOnItemViewListener);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        final VideoItem videoItem = mItems.get(position);
        holder.bindSource(position, videoItem, mItems);
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder implements
            FeedVideoPageView.DetailPageNavigator.FeedVideoViewHolder {
        // video
        public FrameLayout videoViewContainer;
        public VideoView sharedVideoView;
        public PlaybackController controller;

        private final VevodFeedVideoItemBinding binding;

        protected VideoItem videoItem;

        public ViewHolder(@NonNull VevodFeedVideoItemBinding binding, OnItemViewListener listener) {
            super(binding.getRoot());
            this.binding = binding;
            initVideoView(binding, listener);
            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onItemClick(ViewHolder.this);
                }
            });
        }

        private void initVideoView(@NonNull VevodFeedVideoItemBinding binding, OnItemViewListener listener) {
            videoViewContainer = binding.videoViewContainer;
            VideoView videoView = sharedVideoView = binding.videoView;

            VideoLayerHost layerHost = new VideoLayerHost(itemView.getContext());
            layerHost.addLayer(new GestureLayer());
            layerHost.addLayer(new FullScreenLayer());
            layerHost.addLayer(new CoverLayer());
            layerHost.addLayer(new FeedVideoCoverShadowLayer());
            layerHost.addLayer(new TimeProgressBarLayer(TimeProgressBarLayer.CompletedPolicy.KEEP));
            layerHost.addLayer(new TitleBarLayer());
            layerHost.addLayer(new QualitySelectDialogLayer());
            layerHost.addLayer(new SpeedSelectDialogLayer());
            layerHost.addLayer(MoreDialogLayer.create());
            layerHost.addLayer(new TipsLayer());
            layerHost.addLayer(new SyncStartTimeLayer());
            // layerHost.addLayer(new VolumeBrightnessIconLayer());
            layerHost.addLayer(new VolumeBrightnessDialogLayer());
            layerHost.addLayer(new TimeProgressDialogLayer());
            // layerHost.addLayer(new FeedVideoVVLayer());
            layerHost.addLayer(new PlayPauseLayer());
            layerHost.addLayer(new LockLayer());
            layerHost.addLayer(new LoadingLayer());
            layerHost.addLayer(new PlayErrorLayer());
            layerHost.addLayer(new PlayCompleteLayer());
            if (VideoSettings.booleanValue(VideoSettings.DEBUG_ENABLE_LOG_LAYER)) {
                layerHost.addLayer(new LogLayer());
            }
            layerHost.attachToVideoView(videoView);

            videoView.setBackgroundColor(ContextCompat.getColor(itemView.getContext(), android.R.color.black));
            videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT);
            videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW);
            videoView.setPlayScene(PlayScene.SCENE_FEED);

            controller = new PlaybackController();
            controller.bind(videoView);

            videoView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onVideoViewClick(ViewHolder.this);
                }
            });
            controller.addPlaybackListener(event -> {
                if (listener != null) {
                    listener.onEvent(ViewHolder.this, event);
                }
            });
        }

        void bindSource(int position, VideoItem videoItem, List<VideoItem> videoItems) {
            this.videoItem = videoItem;
            bindHeader(position, videoItem, videoItems);
            bindVideoView(position, videoItem, videoItems);
        }

        void bindHeader(int position, VideoItem videoItem, List<VideoItem> videoItems) {
            binding.header.title.setText(videoItem.getTitle());

            Context context = binding.header.description.getContext();
            binding.header.description.setText(
                    FormatHelper.formatCountAndCreateTime(context, videoItem)
            );

            Glide.with(binding.header.avatar)
                    .load(Avatars.byUserId(videoItem.getUserId()))
                    .transform(new CircleCrop())
                    .into(binding.header.avatar);
        }

        void bindVideoView(int position, VideoItem videoItem, List<VideoItem> videoItems) {
            VideoView videoView = sharedVideoView;
            MediaSource mediaSource = videoView.getDataSource();
            if (mediaSource == null) {
                mediaSource = VideoItem.toMediaSource(videoItem, true);
                videoView.bindDataSource(mediaSource);
                VideoViewExtras.updateExtra(videoView, videoItem);
            } else {
                if (TextUtils.equals(videoItem.getVid(), mediaSource.getMediaId())) {
                    // do nothing
                } else {
                    videoView.stopPlayback();
                    mediaSource = VideoItem.toMediaSource(videoItem, true);
                    videoView.bindDataSource(mediaSource);
                    VideoViewExtras.updateExtra(videoView, videoItem);
                }
            }
        }

        @Override
        public VideoView getSharedVideoView() {
            return sharedVideoView;
        }

        @Override
        public void detachSharedVideoView(VideoView videoView) {
            if (sharedVideoView == videoView) {
                ViewUtils.removeFromParent(videoView);
                sharedVideoView = null;
            }
        }

        @Override
        public void attachSharedVideoView(VideoView videoView) {
            sharedVideoView = videoView;
            videoViewContainer.addView(videoView);
            videoView.setPlayScene(PlayScene.SCENE_FEED);
            // sharedVideoView.startPlayback();
            int position = getAbsoluteAdapterPosition();
            if (position >= 0) {
                if (itemView.getParent() instanceof RecyclerView) {
                    RecyclerView recyclerView = (RecyclerView) itemView.getParent();
                    recyclerView.smoothScrollToPosition(position);
                }
            }
        }

        @Override
        public Rect calVideoViewTransitionRect() {
            final int[] location = UIUtils.getLocationInWindow(videoViewContainer);
            int left = location[0];
            int top = location[1] - UIUtils.getStatusBarHeight(itemView.getContext());
            int right = left + videoViewContainer.getWidth();
            int bottom = top + videoViewContainer.getHeight();
            return new Rect(left, top, right, bottom);
        }

        @Override
        public VideoItem getVideoItem() {
            return this.videoItem;
        }
    }
}


