// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.recommend;


import static com.byteplus.vod.minidrama.utils.Route.EXTRA_DRAMA_INFO;
import static com.byteplus.vod.minidrama.utils.Route.EXTRA_EPISODE_NUMBER;

import android.content.res.Resources;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.byteplus.minidrama.R;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.minidrama.event.EpisodeRecommendClicked;
import com.byteplus.vod.minidrama.event.OnCommentEvent;
import com.byteplus.vod.minidrama.event.OnRecommendForYou;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaRecommend;
import com.byteplus.vod.minidrama.scene.comment.MDCommentDialogFragment;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.Input;
import com.byteplus.vod.minidrama.scene.widgets.DramaVideoSceneView;
import com.byteplus.vod.minidrama.scene.widgets.adatper.ViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.bottom.SpeedIndicatorViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoLayer;
import com.byteplus.vod.minidrama.scene.widgets.viewholder.DramaEpisodeVideoViewHolder;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.vod.scenekit.data.model.ItemType;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.page.Book;
import com.byteplus.vod.scenekit.data.page.Page;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Collections;
import java.util.List;

public class DramaRecommendVideoFragment extends Fragment {
    private GetDramas mRemoteApi;
    private final Book<VideoItem> mBook = new Book<>(10);
    private DramaVideoSceneView mSceneView;
    private SpeedIndicatorViewHolder mSpeedIndicator;

    public ActivityResultLauncher<Input> mDramaDetailPageLauncher = registerForActivityResult(new DramaDetailVideoActivityResultContract(), result -> {

    });

    public DramaRecommendVideoFragment() {
        super(R.layout.vevod_mini_drama_recommend_video_fragment);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRemoteApi = new GetDramas();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mRemoteApi.cancel();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        SwipeRefreshLayout refreshLayout = view.findViewById(R.id.vevod_refresh_view);
        Resources resources = getResources();
        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            int topAdjust = resources.getDimensionPixelSize(R.dimen.vevod_mini_drama_swipe_circle_top_adjust);
            refreshLayout.setProgressViewOffset(false, 0, insets.top + topAdjust);
            return windowInsets;
        });

        mSceneView = new DramaVideoSceneView(view);
        mSceneView.pageView().setLifeCycle(getLifecycle());
        mSceneView.pageView().setViewHolderFactory(new RecommendDramaVideoViewHolderFactory());
        mSceneView.setOnRefreshListener(this::refresh);
        mSceneView.setOnLoadMoreListener(this::loadMore);

        mSpeedIndicator = new SpeedIndicatorViewHolder(view, mSceneView);
        mSpeedIndicator.showSpeedIndicator(false);
        refresh();
    }

    private class RecommendDramaVideoViewHolderFactory implements ViewHolder.Factory {
        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            switch (viewType) {
                case ItemType.ITEM_TYPE_VIDEO: {
                    final DramaEpisodeVideoViewHolder viewHolder = new DramaEpisodeVideoViewHolder(
                            new FrameLayout(parent.getContext()),
                            DramaVideoLayer.Type.RECOMMEND,
                            mSpeedIndicator);
                    final VideoView videoView = viewHolder.videoView;
                    final PlaybackController controller = videoView == null ? null : videoView.controller();
                    if (controller != null) {
                        controller.addPlaybackListener(new Dispatcher.EventListener() {
                            @Override
                            public void onEvent(Event event) {
                                if (event.code() == PlayerEvent.State.COMPLETED) {
                                    onDramaPlayCompleted(event);
                                }
                            }
                        });
                    }
                    return viewHolder;
                }
            }
            throw new IllegalArgumentException("unsupported type!");
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        MiniEventBus.register(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        MiniEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onRecommendForYou(OnRecommendForYou event) {
        RecommendForYouFragment fragment = new RecommendForYouFragment();
        Bundle args = new Bundle();
        args.putSerializable(EXTRA_DRAMA_INFO, event.dramaInfo);
        args.putInt(EXTRA_EPISODE_NUMBER, event.episodeNumber);
        fragment.setArguments(args);
        fragment.show(getChildFragmentManager(), "recommend_for_you");
    }

    @Subscribe
    public void onCommentClick(OnCommentEvent event) {
        DialogFragment fragment = new MDCommentDialogFragment();
        Bundle args = new Bundle();
        args.putString("vid", event.vid);
        fragment.setArguments(args);
        fragment.show(getChildFragmentManager(), "comment");
    }

    @Subscribe
    public void onEpisodeRecommendClicked(EpisodeRecommendClicked event) {
        int episodeNumber = event.recommend.feed.episodeNumber;
        DramaItem dramaItem = new DramaItem(event.recommend.info, episodeNumber);
        String mediaKey;
        if (mSceneView.pageView().getCurrentViewHolder() instanceof DramaEpisodeVideoViewHolder videoViewHolder) {
            mediaKey = videoViewHolder.getMediaId();
            VideoView videoView = videoViewHolder.videoView();
            if (videoView != null) {
                final PlaybackController controller = videoView.controller();
                if (controller != null) {
                    controller.unbindPlayer();
                }
            }
        } else {
            mediaKey = null;
        }
        mDramaDetailPageLauncher.launch(new Input(Collections.singletonList(dramaItem), mediaKey));
    }

    private void onDramaPlayCompleted(Event event) {

    }

    private void playNext() {
        final int currentPosition = mSceneView.pageView().getCurrentItem();
        final int nextPosition = currentPosition + 1;
        final int total = mSceneView.pageView().getItemCount();
        if (nextPosition < total) {
            L.d(this, "playNext", "current", currentPosition, "next", nextPosition, "total", total);
            mSceneView.pageView().setCurrentItem(nextPosition, true);
        } else {
            L.d(this, "playNext", "current", currentPosition, "total", total, "end");
        }
    }

    private void refresh() {
        L.d(this, "refresh", "start", 0, mBook.pageSize());
        mSceneView.showRefreshing();
        mRemoteApi.getDramaRecommend(0, mBook.pageSize(), new HttpCallback<>() {

            @Override
            public void onSuccess(List<DramaRecommend> items) {
                if (getActivity() == null) return;

                List<VideoItem> videoItems = DramaRecommend.toVideoItems(items);
                VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_SHORT), null);
                VideoItem.syncProgress(videoItems, true);

                mBook.firstPage(new Page<>(videoItems, 0, Page.TOTAL_INFINITY));
                mBook.end(); // TODO: DEMO ONLY HAS ONE PAGE
                mSceneView.dismissRefreshing();
                mSceneView.pageView().setItems(videoItems);
            }

            @Override
            public void onError(Throwable e) {
                L.d(this, "refresh", e, "error");
                if (getActivity() == null) return;

                mSceneView.dismissRefreshing();
                Toast.makeText(getActivity(), String.valueOf(e), Toast.LENGTH_LONG).show();
            }
        });
    }

    private void loadMore() {
        if (mBook.hasMore()) {
            mSceneView.showLoadingMore();
            L.d(this, "loadMore", "start", mBook.nextPageIndex(), mBook.pageSize());
            mRemoteApi.getDramaRecommend(0, mBook.pageSize(), new HttpCallback<>() {
                @Override
                public void onSuccess(List<DramaRecommend> items) {
                    if (getActivity() == null) return;

                    List<VideoItem> videoItems = DramaRecommend.toVideoItems(items);
                    VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_SHORT), null);
                    VideoItem.syncProgress(videoItems, true);

                    mBook.addPage(new Page<>(videoItems, mBook.nextPageIndex(), Page.TOTAL_INFINITY));
                    mSceneView.dismissLoadingMore();
                    mSceneView.pageView().appendItems(videoItems);
                }

                @Override
                public void onError(Throwable e) {
                    L.d(this, "loadMore", "error", mBook.nextPageIndex());
                    if (getActivity() == null) return;
                    mSceneView.dismissLoadingMore();
                    Toast.makeText(getActivity(), String.valueOf(e), Toast.LENGTH_LONG).show();
                }
            });
        } else {
            mBook.end();
            mSceneView.finishLoadingMore();
            L.d(this, "loadMore", "end");
        }
    }
}
