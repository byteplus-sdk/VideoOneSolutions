// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.shortvideo;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.TextUtils;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.view.GestureDetectorCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.airbnb.lottie.LottieCompositionFactory;
import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.DisplayView;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ext.VideoLayerHostExt;
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras;
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LockLayer;
import com.byteplus.vod.scenekit.ui.video.layer.LogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PauseLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayErrorLayer;
import com.byteplus.vod.scenekit.ui.video.layer.PlayerConfigLayer;
import com.byteplus.vod.scenekit.ui.video.layer.TitleBarLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.QualitySelectDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.SpeedSelectDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.VolumeBrightnessDialogLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoDetailsLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoFullScreenLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoGestureLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoPlayCompleteLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoPlayPauseLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoProgressBarLayer;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoTimeProgressBarLayer;
import com.vertcdemo.base.ReportDialog;

import java.util.ArrayList;
import java.util.List;


public class ShortVideoAdapter extends RecyclerView.Adapter<ShortVideoAdapter.ViewHolder> {

    private final List<VideoItem> mItems = new ArrayList<>();

    private final IShortVideoStrategyConfig mStrategyConfig;

    @Nullable
    private Runnable mAfterExitFullScreenListener;

    ShortVideoAdapter(Context context, IShortVideoStrategyConfig config) {
        mStrategyConfig = config;
        // Preload the lottie resource to reduce lag
        LottieCompositionFactory.fromAsset(context, "like_cancel.json");
        LottieCompositionFactory.fromAsset(context, "like_icondata.json");
    }

    public void setAfterExitFullScreenListener(@Nullable Runnable listener) {
        mAfterExitFullScreenListener = listener;
    }

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
        return ViewHolder.create(parent, mStrategyConfig);
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
        holder.bind(position, videoItem, mAfterExitFullScreenListener);
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public final VideoView videoView;

        private final ShortVideoDetailsLayer detailsLayer;

        public static ViewHolder create(ViewGroup parent, IShortVideoStrategyConfig config) {
            View itemview = LayoutInflater.from(parent.getContext()).inflate(
                    R.layout.vevod_short_video_item, parent, false
            );
            return new ViewHolder(itemview, config);
        }

        @SuppressLint("ClickableViewAccessibility")
        public ViewHolder(@NonNull View itemView, IShortVideoStrategyConfig config) {
            super(itemView);
            Context context = itemView.getContext();

            videoView = itemView.findViewById(R.id.videoView);
            setupVideoView(itemView, videoView, config);
            VideoLayerHost layerHost = videoView.layerHost();
            assert layerHost != null;
            detailsLayer = layerHost.findLayer(ShortVideoDetailsLayer.class);
            assert detailsLayer != null;

            GestureDetectorCompat  mDetector = new GestureDetectorCompat(context, new GestureDetector.SimpleOnGestureListener() {
                @Override
                public boolean onDown(@NonNull MotionEvent e) {
                    return true;
                }

                @Override
                public boolean onSingleTapConfirmed(@NonNull MotionEvent e) {
                    videoView.performClick();
                    return true;
                }

                @Override
                public boolean onDoubleTap(@NonNull MotionEvent e) {
                    DoubleTapHeartHelper.show((ViewGroup) itemView, (int) e.getX(), (int) e.getY());
                    detailsLayer.onDoubleTap();
                    return true;
                }

                @Override
                public void onLongPress(@NonNull MotionEvent e) {
                    ReportDialog.show(context);
                }
            });
            videoView.setOnTouchListener((v, event) -> mDetector.onTouchEvent(event));
        }

        public void bind(int position, VideoItem videoItem, @Nullable Runnable listener) {
            VideoLayerHost layerHost = videoView.layerHost();
            ShortVideoFullScreenLayer fsLayer = layerHost == null ? null : layerHost.findLayer(ShortVideoFullScreenLayer.class);
            if ((videoItem.getWidth() != 0 && videoItem.getHeight() != 0)
                    && videoItem.getWidth() > videoItem.getHeight()) {  // Support Landscape mode
                videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL_X);

                detailsLayer.updateDisplayAnchor(videoItem.getWidth(), videoItem.getHeight());
                if (fsLayer != null) {
                    fsLayer.setAfterExitFullScreenListener(listener);
                }
            } else { // Support Portrait mode
                videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL);

                detailsLayer.updateDisplayFullScreen();
                if (fsLayer != null) {
                    fsLayer.setAfterExitFullScreenListener(null);
                }
            }

            detailsLayer.bind(videoItem);

            MediaSource mediaSource = videoView.getDataSource();
            if (mediaSource == null) {
                mediaSource = VideoItem.toMediaSource(videoItem);
                videoView.bindDataSource(mediaSource);
                VideoViewExtras.updateExtra(videoView, videoItem);
            } else {
                if (!TextUtils.equals(videoItem.getVid(), mediaSource.getMediaId())) {
                    videoView.stopPlayback();
                    mediaSource = VideoItem.toMediaSource(videoItem);
                    videoView.bindDataSource(mediaSource);
                    VideoViewExtras.updateExtra(videoView, videoItem);
                } else {
                    // do nothing
                }
            }
        }
    }

    static void setupVideoView(@NonNull View parent, @NonNull VideoView videoView, IShortVideoStrategyConfig config) {
        VideoLayerHost layerHost = new VideoLayerHostExt(parent.getContext(), config);
        layerHost.addLayer(new ShortVideoFullScreenLayer());
        layerHost.addLayer(new ShortVideoDetailsLayer());

        layerHost.addLayer(new ShortVideoGestureLayer());

        layerHost.addLayer(new TitleBarLayer(PlayScene.SCENE_FULLSCREEN));
        layerHost.addLayer(new ShortVideoTimeProgressBarLayer());

        layerHost.addLayer(new VolumeBrightnessDialogLayer());
        layerHost.addLayer(new ShortVideoPlayPauseLayer());
        layerHost.addLayer(new LockLayer());

        layerHost.addLayer(new LoadingLayer());
        layerHost.addLayer(new PauseLayer());
        layerHost.addLayer(new ShortVideoProgressBarLayer());
        layerHost.addLayer(new PlayErrorLayer());
        layerHost.addLayer(new PlayerConfigLayer());
        layerHost.addLayer(new ShortVideoPlayCompleteLayer());
        if (config.enableLogLayer()) {
            layerHost.addLayer(new LogLayer());
        }

        layerHost.addLayer(MoreDialogLayer.createWithoutLoopMode());
        layerHost.addLayer(new QualitySelectDialogLayer());
        layerHost.addLayer(new SpeedSelectDialogLayer());

        layerHost.attachToVideoView(videoView);
        videoView.setBackgroundColor(ContextCompat.getColor(parent.getContext(), android.R.color.black));
        //videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT); // fit mode
        videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL); // immersive mode
        videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW);
        videoView.setPlayScene(PlayScene.SCENE_SHORT);
    }
}

