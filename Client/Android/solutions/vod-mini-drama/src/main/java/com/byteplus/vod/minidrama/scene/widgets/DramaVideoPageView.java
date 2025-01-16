// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.util.Predicate;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.scene.widgets.adatper.MultiTypeAdapter;
import com.byteplus.vod.minidrama.scene.widgets.adatper.ViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.viewholder.DramaEpisodeVideoViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.viewholder.DramaEpisodeVideoViewLandscapeHolder;
import com.byteplus.vod.minidrama.scene.widgets.viewholder.ViewHolderAction;
import com.byteplus.vod.minidrama.scene.widgets.viewpager2.OnPageChangeCallbackCompat;
import com.byteplus.vod.minidrama.scene.widgets.viewpager2.ViewPager2Helper;
import com.byteplus.vod.minidrama.utils.ItemHelper;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.minidrama.utils.MiniDramaVideoStrategy;
import com.byteplus.vod.minidrama.utils.VideoItemHelper;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.ui.video.layer.helper.MiniPlayerHelper;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class DramaVideoPageView implements LifecycleEventObserver, Dispatcher.EventListener {
    private final ViewPager2 mViewPager;
    private final MultiTypeAdapter mShortVideoAdapter;
    private Lifecycle mLifeCycle;
    private ViewHolder.Factory mViewHolderFactory;
    private boolean mInterceptStartPlaybackOnResume;
    private ViewHolder mCurrentHolder;

    public DramaVideoPageView(ViewPager2 viewPager) {
        mViewPager = viewPager;
        ViewPager2Helper.setup(mViewPager);
        mViewPager.setOffscreenPageLimit(1);
        mViewPager.setOrientation(ViewPager2.ORIENTATION_VERTICAL);
        mShortVideoAdapter = new MultiTypeAdapter(new DramaVideoViewHolderFactory() {
            @NonNull
            @Override
            public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                if (mViewHolderFactory != null) {
                    return mViewHolderFactory.onCreateViewHolder(parent, viewType);
                }
                return super.onCreateViewHolder(parent, viewType);
            }
        });
        mViewPager.setAdapter(mShortVideoAdapter);
        mViewPager.registerOnPageChangeCallback(new OnPageChangeCallbackCompat(mViewPager) {
            @Override
            public void onPageSelected(ViewPager2 pager, int position) {
                super.onPageSelected(pager, position);
                togglePlayback(position);
            }

            @Override
            public void onPagePeekStart(ViewPager2 pager, int position, int peekPosition) {
                super.onPagePeekStart(pager, position, peekPosition);
                final ViewHolder holder = findItemViewHolderByPosition(pager, peekPosition);
                if (holder == null) return;
                holder.executeAction(ViewHolderAction.ACTION_VIEW_PAGER_ON_PAGE_PEEK_START, new Object[]{pager, position, peekPosition});
            }
        });
    }

    @Override
    public void onEvent(Event event) {

    }

    public ViewPager2 viewPager() {
        return mViewPager;
    }

    public void setLifeCycle(Lifecycle lifeCycle) {
        if (mLifeCycle != lifeCycle) {
            if (mLifeCycle != null) {
                mLifeCycle.removeObserver(this);
            }
            mLifeCycle = lifeCycle;
        }
        if (mLifeCycle != null) {
            mLifeCycle.addObserver(this);
        }
    }

    public void setViewHolderFactory(ViewHolder.Factory factory) {
        this.mViewHolderFactory = factory;
    }

    public void setItems(List<? extends ViewItem> items) {
        L.d(this, "setItems", items == null ? -1 : items.size(), items);

        List<VideoItem> videoItems = VideoItemHelper.findVideoItems(items);
        VideoItem.playScene(videoItems, PlayScene.SCENE_SHORT);
        mShortVideoAdapter.setItems(items, ItemHelper.comparator());
        MiniDramaVideoStrategy.setItems(videoItems);

        play();
    }

    public void prependItems(List<ViewItem> items) {
        if (items == null) return;

        L.d(this, "prependItems", items.size(), items);

        VideoItem.playScene(VideoItemHelper.findVideoItems(items), PlayScene.SCENE_SHORT);
        mShortVideoAdapter.insertItems(0, items);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
    }

    public void appendItems(List<? extends ViewItem> items) {
        if (items == null) return;

        L.d(this, "appendItems", items);

        List<VideoItem> videoItems = VideoItemHelper.findVideoItems(items);
        VideoItem.playScene(videoItems, PlayScene.SCENE_SHORT);
        mShortVideoAdapter.appendItems(items);
        MiniDramaVideoStrategy.appendItems(filter(videoItems));
    }

    private static List<VideoItem> filter(List<VideoItem> items) {
        List<VideoItem> out = new ArrayList<>();
        for (VideoItem item : items) {
            DramaFeed feed = DramaFeed.of(item);
            if (feed.isLocked()) {
                continue;
            }
            out.add(item);
        }
        return out;
    }

    public void deleteItem(int position) {
        if (position >= mShortVideoAdapter.getItemCount() || position < 0) return;

        final int currentPosition = getCurrentItem();
        final ViewItem item = mShortVideoAdapter.getItem(position);
        L.d(this, "deleteItem", position, item);

        mShortVideoAdapter.deleteItem(position);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
        if (currentPosition == position) {
            play();
        }
    }

    public void deleteItems(int position, int count) {
        if (position >= mShortVideoAdapter.getItemCount() || position < 0) return;

        final int currentPosition = getCurrentItem();
        L.d(this, "deleteItems", position, count);
        mShortVideoAdapter.deleteItems(position, count);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
        if (position <= currentPosition && currentPosition < position + count) {
            play();
        }
    }

    public void replaceItem(int position, ViewItem item) {
        if (item == null) return;
        if (position >= mShortVideoAdapter.getItemCount() || position < 0) return;
        VideoItem.playScene(VideoItemHelper.findVideoItem(item), PlayScene.SCENE_SHORT);
        L.d(this, "replaceItem", position, item);
        final int currentPosition = getCurrentItem();
        mShortVideoAdapter.replaceItem(position, item);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
        if (currentPosition == position) {
            play();
        }
    }

    public void replaceItems(int position, List<ViewItem> items) {
        if (items == null) return;
        if (mShortVideoAdapter.getItemCount() <= position || position < 0) return;
        VideoItem.playScene(VideoItemHelper.findVideoItems(items), PlayScene.SCENE_SHORT);
        L.d(this, "replaceItems", position, items.size(), items);
        final int currentPosition = getCurrentItem();
        mShortVideoAdapter.replaceItems(position, items);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
        if (position <= currentPosition && currentPosition < position + items.size()) {
            play();
        }
    }

    public void insertItem(int position, ViewItem item) {
        if (item == null) return;
        if (mShortVideoAdapter.getItemCount() <= position || position < 0) return;
        VideoItem.playScene(VideoItemHelper.findVideoItem(item), PlayScene.SCENE_SHORT);
        L.d(this, "insertItem", position, item);
        final int currentPosition = getCurrentItem();
        mShortVideoAdapter.insertItem(position, item);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
        if (currentPosition == position) {
            play();
        }
    }

    public void insertItems(int position, List<ViewItem> items) {
        if (items == null) return;
        if (mShortVideoAdapter.getItemCount() <= position || position < 0) return;
        VideoItem.playScene(VideoItemHelper.findVideoItems(items), PlayScene.SCENE_SHORT);
        L.d(this, "insertItems", position, items.size(), items);
        final int currentPosition = getCurrentItem();
        mShortVideoAdapter.insertItems(position, items);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
        if (position <= currentPosition && currentPosition < position + items.size()) {
            play();
        }
    }

    public List<ViewItem> getItems() {
        return mShortVideoAdapter.getItems();
    }

    public ViewItem getItem(int position) {
        return mShortVideoAdapter.getItem(position);
    }

    public int getItemCount() {
        return mShortVideoAdapter.getItemCount();
    }

    public int getItemViewType(int position) {
        return mShortVideoAdapter.getItemViewType(position);
    }

    public void setCurrentItem(int position, boolean smoothScroll) {
        L.d(this, "setCurrentItem", position, smoothScroll);
        mViewPager.setCurrentItem(position, smoothScroll);
    }

    public int findItemPosition(@NonNull Predicate<ViewItem> predicate) {
        return mShortVideoAdapter.findPosition(predicate);
    }

    public int getCurrentItem() {
        return mViewPager.getCurrentItem();
    }

    public View getCurrentItemView() {
        final int currentPosition = mViewPager.getCurrentItem();
        return ViewPager2Helper.findItemViewByPosition(mViewPager, currentPosition);
    }

    public ViewHolder getCurrentViewHolder() {
        return findItemViewHolderByPosition(mViewPager, mViewPager.getCurrentItem());
    }

    public ViewItem getCurrentItemModel() {
        final int currentPosition = mViewPager.getCurrentItem();
        return mShortVideoAdapter.getItems().get(currentPosition);
    }

    private void togglePlayback(int position) {
        if (mLifeCycle != null && !mLifeCycle.getCurrentState().isAtLeast(Lifecycle.State.RESUMED)) {
            L.d(this, "togglePlayback", position, "returned",
                    L.string(mLifeCycle.getCurrentState()));
            return;
        }
        L.d(this, "togglePlayback", position, mShortVideoAdapter.getItem(position));
        final ViewHolder viewHolder = findItemViewHolderByPosition(mViewPager, position);
        final ViewHolder lastHolder = mCurrentHolder;
        mCurrentHolder = viewHolder;
        // stop last
        if (lastHolder != null && lastHolder != viewHolder) {
            lastHolder.executeAction(ViewHolderAction.ACTION_STOP);
        }
        // start current
        if (viewHolder != null) {
            if (viewHolder instanceof DramaEpisodeVideoViewHolder videoViewHolder) {
                VideoView videoView = videoViewHolder.videoView();
                Player player = videoView == null ? null : videoView.player();
                if (player != null && player.isReleased()) {
                    L.d(this, "togglePlayback, player is released, unbind player");
                    PlaybackController controller = Objects.requireNonNull(videoView.controller());
                    controller.unbindPlayer();
                }
            }
            viewHolder.executeAction(ViewHolderAction.ACTION_PLAY);
        }
    }

    public void play() {
        L.d(this, "play");

        final int currentPosition = mViewPager.getCurrentItem();
        if (currentPosition >= 0) {
            togglePlayback(currentPosition);
        }
    }

    public void pause() {
        L.d(this, "pause");
        ViewHolder viewHolder = getCurrentViewHolder();
        if (viewHolder != null) {
            if (viewHolder instanceof DramaEpisodeVideoViewLandscapeHolder videoViewHolder) {
                VideoView videoView = videoViewHolder.videoView();
                Player player = videoView == null ? null: videoView.player();
                if (!MiniPlayerHelper.get().isMiniPlayerOff() && player != null && player.isPlaying()) {
                    return;
                }
            }
            viewHolder.executeAction(ViewHolderAction.ACTION_PAUSE);
        }
    }

    public void stop() {
        L.d(this, "stop");
        ViewHolder viewHolder = getCurrentViewHolder();
        if (viewHolder != null) {
            viewHolder.executeAction(ViewHolderAction.ACTION_STOP);
        }
    }

    public void setInterceptStartPlaybackOnResume(boolean interceptStartPlay) {
        this.mInterceptStartPlaybackOnResume = interceptStartPlay;
    }

    @Override
    public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
        switch (event) {
            case ON_RESUME:
                onResume();
                break;
            case ON_PAUSE:
                onPause();
                break;
            case ON_DESTROY:
                onDestroy();
                break;
        }
    }

    private void onResume() {
        L.d(this, "onResume");
        MiniDramaVideoStrategy.setEnabled(true);
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
        if (!mInterceptStartPlaybackOnResume) {
            play();
        }
        mInterceptStartPlaybackOnResume = false;
    }

    public void onEpisodesUnlocked() {
        // After unlock, should update preload list
        MiniDramaVideoStrategy.setItems(VideoItemHelper.findVideoItems(mShortVideoAdapter.getItems()));
    }

    private void onPause() {
        L.d(this, "onPause");
        MiniDramaVideoStrategy.setEnabled(false);
        pause();
    }

    private void onDestroy() {
        L.d(this, "onDestroy");
        if (mLifeCycle != null) {
            mLifeCycle.removeObserver(this);
            mLifeCycle = null;
        }
        stop();
    }

    public boolean onBackPressed() {
        final ViewHolder holder = getCurrentViewHolder();
        if (holder != null && holder.onBackPressed()) {
            return true;
        }
        return false;
    }

    public float getPlaybackSpeed() {
        final ViewHolder holder = getCurrentViewHolder();
        if (holder instanceof DramaEpisodeVideoViewHolder videoViewHolder) {
            PlaybackController controller = videoViewHolder.videoView().controller();
            if (controller != null) {
                Player player = controller.player();
                if (player != null) {
                    return player.getSpeed();
                }
            }
        }

        return 1.0F;
    }

    public void setPlaybackSpeed(float speed) {
        final ViewHolder holder = getCurrentViewHolder();
        if (holder instanceof DramaEpisodeVideoViewHolder videoViewHolder) {
            PlaybackController controller = videoViewHolder.videoView().controller();
            if (controller == null) {
                return;
            }
            Player player = controller.player();
            if (player != null) {
                player.setSpeed(speed);
            }
        }
    }

    private static ViewHolder findItemViewHolderByPosition(ViewPager2 pager, int position) {
        View itemView = ViewPager2Helper.findItemViewByPosition(pager, position);
        if (itemView != null) {
            return (ViewHolder) itemView.getTag();
        }
        return null;
    }
}
