// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.feedvideo;


import static com.byteplus.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.LinearSmoothScroller;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.layer.helper.MiniPlayerHelper;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoAdapter.OnItemViewListener;

import java.util.List;


public class FeedVideoPageView extends FrameLayout {
    private static final String TAG = "FeedVideoPageView";

    private final RecyclerView mRecyclerView;
    private final LinearLayoutManager mLayoutManager;
    private final FeedVideoAdapter mFeedVideoAdapter;
    private Lifecycle mLifeCycle;
    private DetailPageNavigator mNavigator;
    private VideoView mCurrentVideoView;
    private boolean mInterceptStartPlaybackOnResume;

    public interface DetailPageNavigator {

        interface FeedVideoViewHolder {

            VideoView getSharedVideoView();

            void detachSharedVideoView(VideoView videoView);

            void attachSharedVideoView(VideoView videoView);

            Rect calVideoViewTransitionRect();

            VideoItem getVideoItem();
        }

        void enterDetail(FeedVideoViewHolder holder);
    }

    public FeedVideoPageView(@NonNull Context context) {
        this(context, null);
    }

    public FeedVideoPageView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FeedVideoPageView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        mLayoutManager = new LinearLayoutManager(context,
                LinearLayoutManager.VERTICAL, false) {
            @Override
            public void smoothScrollToPosition(RecyclerView recyclerView, RecyclerView.State state,
                                               int position) {
                LinearSmoothScroller linearSmoothScroller = new LinearSmoothScroller(context) {
                    @Override
                    protected float calculateSpeedPerPixel(DisplayMetrics displayMetrics) {
                        return super.calculateSpeedPerPixel(displayMetrics) * 4;
                    }
                };
                linearSmoothScroller.setTargetPosition(position);
                startSmoothScroll(linearSmoothScroller);
            }
        };
        mFeedVideoAdapter = new FeedVideoAdapter(mAdapterListener) {
            @Override
            public void onViewDetachedFromWindow(@NonNull ViewHolder holder) {
                if (!isFullScreen()) {
                    if (holder.sharedVideoView != null) {
                        holder.sharedVideoView.stopPlayback();
                    }
                }
            }

            @Override
            public void onViewRecycled(@NonNull ViewHolder holder) {
                super.onViewRecycled(holder);
                if (!isFullScreen()) {
                    if (holder.sharedVideoView != null) {
                        holder.sharedVideoView.stopPlayback();
                    }
                }
            }
        };

        mRecyclerView = new RecyclerView(context);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setAdapter(mFeedVideoAdapter);
        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            private boolean isUserInitiated = false;
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    Log.d(TAG, "onScrollStateChanged: SCROLL_STATE_IDLE, isUserInitiated=" + isUserInitiated);
                    if(!isUserInitiated){
                        return;
                    }
                    isUserInitiated = false;
                    // find a VideoItem to play
                    Object parent = getParent();
                    boolean isRefreshing = false;
                    if (parent instanceof SwipeRefreshLayout) {
                        isRefreshing = ((SwipeRefreshLayout) parent).isRefreshing();
                    }
                    if (!isRefreshing) {
                        autoplaySomeVideo();
                    } else {
                        Log.d(TAG, "onScrollStateChanged: Parent trigger refreshing, stop auto play");
                    }
                } else if (newState == RecyclerView.SCROLL_STATE_DRAGGING) {
                    Log.d(TAG, "onScrollStateChanged: SCROLL_STATE_DRAGGING");
                    isUserInitiated = true;
                }
            }
        });
        addView(mRecyclerView, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
    }

    public RecyclerView recyclerView() {
        return mRecyclerView;
    }

    final OnItemViewListener mAdapterListener = new OnItemViewListener() {
        @Override
        public void onItemClick(FeedVideoAdapter.ViewHolder holder) {
            if (mNavigator != null) {
                if (mCurrentVideoView != null && mCurrentVideoView != holder.controller.videoView()) {
                    // Clicked another item, stop current
                    mCurrentVideoView.stopPlayback();
                }

                mNavigator.enterDetail(holder);
            }
        }

        @Override
        public void onVideoViewClick(FeedVideoAdapter.ViewHolder holder) {
            // click to play
            VideoView videoView = holder.sharedVideoView;
            if (videoView == null) return;

            final Player player = videoView.player();
            if (player == null) {
                videoView.startPlayback();
                int position = holder.getAbsoluteAdapterPosition();
                if (position >= 0) {
                    mRecyclerView.smoothScrollToPosition(position);
                }
            }
        }

        @Override
        public void onEvent(FeedVideoAdapter.ViewHolder viewHolder, Event event) {
            if (event.code() == PlaybackEvent.Action.START_PLAYBACK) {// toggle play
                final VideoView videoView = viewHolder.controller.videoView();
                if (mCurrentVideoView != null && videoView != null) {
                    if (mCurrentVideoView != videoView) {
                        mCurrentVideoView.stopPlayback();
                    }
                }
                mCurrentVideoView = videoView;
            }
        }
    };

    public void setLifeCycle(Lifecycle lifeCycle) {
        if (mLifeCycle != lifeCycle) {
            if (mLifeCycle != null) {
                mLifeCycle.removeObserver(mLifecycleEventObserver);
            }
            mLifeCycle = lifeCycle;
        }
        if (mLifeCycle != null) {
            mLifeCycle.addObserver(mLifecycleEventObserver);
        }
    }

    private final LifecycleEventObserver mLifecycleEventObserver = new LifecycleEventObserver() {
        @Override
        public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
            switch (event) {
                case ON_CREATE:
                    break;
                case ON_RESUME:
                    FeedVideoStrategy.setEnabled(true);
                    FeedVideoStrategy.setItems(mFeedVideoAdapter.getItems());
                    resume();
                    break;
                case ON_PAUSE:
                    pause();
                    break;
                case ON_DESTROY:
                    FeedVideoStrategy.setEnabled(false);
                    mLifeCycle.removeObserver(mLifecycleEventObserver);
                    mLifeCycle = null;
                    stop();
                    break;
            }
        }
    };

    public void setDetailPageNavigator(DetailPageNavigator navigator) {
        mNavigator = navigator;
    }

    public void setItems(List<VideoItem> videoItems) {
        int oldItemCount = mFeedVideoAdapter.getItemCount();
        mFeedVideoAdapter.setItems(videoItems);
        if (mLifeCycle != null && mLifeCycle.getCurrentState() == Lifecycle.State.RESUMED) {
            FeedVideoStrategy.setItems(videoItems);
            if (oldItemCount != 0 && !videoItems.isEmpty()) {
                // User trigger refresh
                // Need post to wait for RecyclerView layout fresh completed
                post(this::autoplaySomeVideo);
            }
        }
    }

    public void prependItems(List<VideoItem> videoItems) {
        mFeedVideoAdapter.prependItems(videoItems);
        FeedVideoStrategy.setItems(mFeedVideoAdapter.getItems());
    }

    public void appendItems(List<VideoItem> videoItems) {
        mFeedVideoAdapter.appendItems(videoItems);
        FeedVideoStrategy.appendItems(videoItems);
    }

    public void play() {
        if (mCurrentVideoView != null) {
            mCurrentVideoView.startPlayback();
        }
    }

    public void resume() {
        autoplaySomeVideo();
    }

    /**
     * Old version of resume, only resume ourself pausePlayback
     */
    public void _resume() {
        if (!mInterceptStartPlaybackOnResume) {
            play();
        }
        mInterceptStartPlaybackOnResume = false;
    }

    public void pause() {
        if (mCurrentVideoView != null) {
            Player player = mCurrentVideoView.player();
            if (player != null && (player.isPaused() || (!player.isLooping() && player.isCompleted()))) {
                mInterceptStartPlaybackOnResume = true;
            } else {
                mInterceptStartPlaybackOnResume = false;
                if (MiniPlayerHelper.get().isMiniPlayerOff() || (!(mCurrentVideoView.getPlayScene() == PlayScene.SCENE_DETAIL)
                        && !PlayScene.isFullScreenMode(mCurrentVideoView.getPlayScene()))) {
                    mCurrentVideoView.pausePlayback();
                }
            }
        }
    }

    public void stop() {
        if (mCurrentVideoView != null) {
            mCurrentVideoView.stopPlayback();
            mCurrentVideoView = null;
        }
    }

    public boolean isFullScreen() {
        return mCurrentVideoView != null && isFullScreenMode(mCurrentVideoView.getPlayScene());
    }

    public boolean onBackPressed() {
        if (mCurrentVideoView != null) {
            final VideoLayerHost layerHost = mCurrentVideoView.layerHost();
            return layerHost != null && layerHost.onBackPressed();
        }
        return false;
    }

    void autoplaySomeVideo() {
        if (mFeedVideoAdapter.getItemCount() == 0) {
            Log.d(TAG, "autoplaySomeVideo: Skip by empty");
            return;
        }
        Log.d(TAG, "autoplaySomeVideo: itemCount=" + mFeedVideoAdapter.getItemCount());
        int position = mLayoutManager.findFirstCompletelyVisibleItemPosition();
        if (position == RecyclerView.NO_POSITION) {
            Log.d(TAG, "autoplaySomeVideo: findFirstCompletelyVisibleItemPosition: " + position);
            return;
        }
        RecyclerView.ViewHolder viewHolder = mRecyclerView.findViewHolderForAdapterPosition(position);
        if (viewHolder == null) {
            Log.d(TAG, "autoplaySomeVideo: viewHolder: null");
            return;
        }

        FeedVideoAdapter.ViewHolder videoHolder = (FeedVideoAdapter.ViewHolder) viewHolder;
        Log.d(TAG, "autoplaySomeVideo: found an item: " + videoHolder.videoItem.getTitle());
        VideoView videoView = videoHolder.sharedVideoView;
        if (videoView == null) return;
        videoView.startPlayback();
    }
}
