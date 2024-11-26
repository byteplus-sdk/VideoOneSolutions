// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.scene.shortvideo;

import static com.byteplus.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.view.View;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.L;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.config.ICompleteAction;
import com.byteplus.vod.scenekit.ui.video.scene.utils.ShortStrategySettingsConfig;
import com.byteplus.vod.scenekit.ui.widgets.viewpager2.OnPageChangeCallbackCompat;

import java.util.List;

public class ShortVideoPageView {

    /**
     * Enable this to resume play when onResume even if use paused
     */
    private static final boolean FORCE_RESUME_PLAY = true;

    private final ShortStrategySettingsConfig mStrategyConfig = new ShortStrategySettingsConfig();

    private final ViewPager2 mViewPager;
    private final ShortVideoAdapter mShortVideoAdapter;
    private final PlaybackController mController = new PlaybackController();
    private Lifecycle mLifeCycle;
    private boolean mInterceptStartPlaybackOnResume;

    public ShortVideoPageView(@NonNull ViewPager2 viewPager) {
        this.mViewPager = viewPager;

        mViewPager.setOrientation(ViewPager2.ORIENTATION_VERTICAL);
        mShortVideoAdapter = new ShortVideoAdapter(viewPager.getContext(), mStrategyConfig);
        mViewPager.setAdapter(mShortVideoAdapter);
        mViewPager.registerOnPageChangeCallback(new OnPageChangeCallbackCompat(mViewPager) {
            @Override
            public void onPageSelected(int position, ViewPager2 pager) {
                togglePlayback(position);
            }
        });
        mController.addPlaybackListener(event -> {
            if (event.code() == PlayerEvent.State.COMPLETED) {
                final Player player = event.owner(Player.class);
                if (player != null && !player.isLooping() &&
                        mStrategyConfig.completeAction() == ICompleteAction.NEXT) {
                    VideoView videoView = mController.videoView();
                    assert videoView != null;
                    if (isFullScreenMode(videoView.getPlayScene())) {
                        // FullScreen mode, can't switch next
                        return;
                    }
                    playNext();
                }
            }
        });

        mShortVideoAdapter.setAfterExitFullScreenListener(() -> {
            final Player player = mController.player();
            if (player != null && !player.isLooping() &&
                    mStrategyConfig.completeAction() == ICompleteAction.NEXT) {
                if (player.isCompleted()) {
                    VideoView videoView = mController.videoView();
                    if (videoView != null) {
                        // Use post to wait videoView layout complete
                        videoView.post(this::playNext);
                    }
                }
            }
        });
    }

    void playNext() {
        final int currentPosition = getCurrentItem();
        final int nextPosition = currentPosition + 1;
        if (nextPosition < mShortVideoAdapter.getItemCount()) {
            setCurrentItem(nextPosition, true);
        }
    }

    @MainThread
    public void setLifeCycle(Lifecycle lifeCycle) {
        if (lifeCycle == mLifeCycle) {
            return;
        }
        if (mLifeCycle != null) {
            mLifeCycle.removeObserver(mLifecycleEventObserver);
        }
        if (lifeCycle != null) {
            lifeCycle.addObserver(mLifecycleEventObserver);
        }
        mLifeCycle = lifeCycle;
    }

    public void setItems(List<VideoItem> videoItems) {
        mShortVideoAdapter.setItems(videoItems);
        if (mLifeCycle != null && mLifeCycle.getCurrentState() == Lifecycle.State.RESUMED) {
            ShortVideoStrategy.setItems(videoItems);
        }
        mViewPager.getChildAt(0).post(this::play);
    }

    public void prependItems(List<VideoItem> videoItems) {
        mShortVideoAdapter.prependItems(videoItems);
        ShortVideoStrategy.setItems(mShortVideoAdapter.getItems());
    }

    public void appendItems(List<VideoItem> videoItems) {
        mShortVideoAdapter.appendItems(videoItems);
        ShortVideoStrategy.appendItems(videoItems);
    }

    public void deleteItem(int position) {
        if (position >= mShortVideoAdapter.getItemCount() || position < 0) return;

        final int currentPosition = getCurrentItem();
        mShortVideoAdapter.deleteItem(position);
        ShortVideoStrategy.setItems(mShortVideoAdapter.getItems());
        if (currentPosition == position && position < mShortVideoAdapter.getItemCount()) {
            mViewPager.postDelayed(this::play, 100);
        }
    }

    public int getItemCount() {
        return mShortVideoAdapter.getItemCount();
    }

    public void setCurrentItem(int position, boolean smoothScroll) {
        mViewPager.setCurrentItem(position, smoothScroll);
    }

    public int getCurrentItem() {
        return mViewPager.getCurrentItem();
    }

    private void togglePlayback(int currentPosition) {
        if (!mLifeCycle.getCurrentState().isAtLeast(Lifecycle.State.RESUMED)) {
            return;
        }
        L.d(this, "togglePlayback", currentPosition);
        final VideoView videoView = findVideoViewByPosition(mViewPager, currentPosition);
        if (mController.videoView() == null) {
            if (videoView != null) {
                mController.bind(videoView);
                mController.startPlayback();
            }
        } else {
            if (videoView != null && videoView != mController.videoView()) {
                mController.stopPlayback();
                mController.bind(videoView);
            }
            mController.startPlayback();
        }
    }

    public void play() {
        final int currentPosition = mViewPager.getCurrentItem();
        if (currentPosition >= 0 && mShortVideoAdapter.getItemCount() > 0) {
            togglePlayback(currentPosition);
        }
    }

    public void resume() {
        if (FORCE_RESUME_PLAY || !mInterceptStartPlaybackOnResume) {
            play();
        }
        mInterceptStartPlaybackOnResume = false;
    }

    public void pause() {
        Player player = mController.player();
        if (player != null && (player.isPaused() || (!player.isLooping() && player.isCompleted()))) {
            mInterceptStartPlaybackOnResume = true;
        } else {
            mInterceptStartPlaybackOnResume = false;
            mController.pausePlayback();
        }
    }

    public void stop() {
        mController.stopPlayback();
    }

    private final LifecycleEventObserver mLifecycleEventObserver = new LifecycleEventObserver() {
        @Override
        public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
            switch (event) {
                case ON_CREATE:
                    break;
                case ON_RESUME:
                    if (mStrategyConfig.enableStrategy()) {
                        ShortVideoStrategy.setEnabled(true);
                        ShortVideoStrategy.setItems(mShortVideoAdapter.getItems());
                    }
                    resume();
                    break;
                case ON_PAUSE:
                    pause();
                    break;
                case ON_DESTROY:
                    if (mStrategyConfig.enableStrategy()) {
                        ShortVideoStrategy.setEnabled(false);
                    }
                    mLifeCycle.removeObserver(this);
                    mLifeCycle = null;
                    stop();
                    break;
            }
        }
    };

    @Nullable
    private static VideoView findVideoViewByPosition(ViewPager2 pager, int position) {
        final RecyclerView recyclerView = (RecyclerView) pager.getChildAt(0);
        if (recyclerView == null) {
            return null;
        }
        LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
        if (layoutManager == null) {
            return null;
        }

        View itemView = layoutManager.findViewByPosition(position);
        if (itemView instanceof VideoView) {
            return (VideoView) itemView;
        }
        return itemView == null ? null : itemView.findViewById(R.id.videoView);
    }

}
