// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.video.scene.feedvideo;

import static com.byteplus.vod.scenekit.ui.video.scene.PlayScene.SCENE_DETAIL;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;

import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.utils.L;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.page.Book;
import com.byteplus.vod.scenekit.data.page.Page;
import com.byteplus.vod.scenekit.ui.base.BaseFragment;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoPageView;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoSceneView;
import com.byteplus.voddemo.R;
import com.byteplus.vodcommon.data.remote.RemoteApi;
import com.byteplus.vodcommon.data.remote.api2.GetFeedStreamApi;
import com.byteplus.voddemo.ui.video.scene.VideoActivity;
import com.byteplus.voddemo.ui.video.scene.detail.DetailVideoFragment;

import java.util.List;


public class FeedVideoFragment extends BaseFragment implements FeedVideoPageView.DetailPageNavigator {

    private RemoteApi.GetFeedStream mRemoteApi;
    private String mAccount;
    private final Book<VideoItem> mBook = new Book<>(10);
    private FeedVideoSceneView mSceneView;

    private DetailVideoFragment.DetailVideoSceneEventListener mListener;

    public FeedVideoFragment() {
        // Required empty public constructor
    }

    public static FeedVideoFragment newInstance() {
        return new FeedVideoFragment();
    }

    @Override
    public boolean onBackPressed() {
        if (mSceneView.onBackPressed()) {
            return true;
        }
        return super.onBackPressed();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRemoteApi = new GetFeedStreamApi();
        mAccount = VideoSettings.stringValue(VideoSettings.FEED_VIDEO_SCENE_ACCOUNT_ID);
    }

    @Override
    protected void initBackPressedHandler() {
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.vevod_feed_video_fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mSceneView = view.findViewById(R.id.shortVideoSceneView);
        mSceneView.pageView().setLifeCycle(getLifecycle());
        mSceneView.setOnRefreshListener(this::refresh);
        mSceneView.setOnLoadMoreListener(this::loadMore);
        mSceneView.setDetailPageNavigator(this);
        refresh();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mRemoteApi.cancel();
    }

    private void refresh() {
        L.d(this, "refresh", "start", 0, mBook.pageSize());
        mSceneView.showRefreshing();
        mRemoteApi.getFeedStream(RemoteApi.VideoType.FEED, mAccount, 0, mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
            @Override
            public void onSuccess(Page<VideoItem> page) {
                L.d(this, "refresh", "success");
                if (getActivity() == null) return;
                List<VideoItem> videoItems = mBook.firstPage(page);
                VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_FEED), null);
                mSceneView.dismissRefreshing();
                if (!videoItems.isEmpty()) {
                    mSceneView.pageView().setItems(videoItems);
                }
            }

            @Override
            public void onError(Exception e) {
                L.d(this, "refresh", e, "error");
                if (getActivity() == null) return;
                mSceneView.dismissRefreshing();
                Toast.makeText(getActivity(), R.string.vevod_network_error, Toast.LENGTH_LONG).show();
            }
        });
    }

    private void loadMore() {
        if (mBook.hasMore()) {
            if (mSceneView.isLoadingMore()) return;
            mSceneView.showLoadingMore();
            L.d(this, "loadMore", "start", mBook.nextPageIndex(), mBook.pageSize());
            mRemoteApi.getFeedStream(RemoteApi.VideoType.FEED, mAccount, mBook.nextPageIndex(), mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
                @Override
                public void onSuccess(Page<VideoItem> page) {
                    L.d(this, "loadMore", "success", mBook.nextPageIndex());
                    if (getActivity() == null) return;
                    List<VideoItem> videoItems = mBook.addPage(page);
                    VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_FEED), null);
                    mSceneView.dismissLoadingMore();
                    mSceneView.pageView().appendItems(videoItems);
                }

                @Override
                public void onError(Exception e) {
                    L.d(this, "loadMore", e, "error", mBook.nextPageIndex());
                    if (getActivity() == null) return;
                    mSceneView.dismissLoadingMore();
                    Toast.makeText(getActivity(), R.string.vevod_network_error, Toast.LENGTH_LONG).show();
                }
            });
        } else {
            mBook.end();
            mSceneView.finishLoadingMore();
            L.d(this, "loadMore", "end");
        }
    }

    public void setDetailSceneEventListener(DetailVideoFragment.DetailVideoSceneEventListener listener) {
        mListener = listener;
    }

    @Override
    public void enterDetail(FeedVideoViewHolder holder) {
        final String pageType = VideoSettings.stringValue(VideoSettings.DETAIL_VIDEO_SCENE_FRAGMENT_OR_ACTIVITY);
        if (TextUtils.equals(pageType, "Activity")) {
            final VideoView videoView = holder.getSharedVideoView();
            if (videoView == null) return;

            final MediaSource source = videoView.getDataSource();
            if (source == null) return;

            final PlaybackController controller = videoView.controller();

            boolean continuesPlayback = false;
            if (controller != null) {
                continuesPlayback = controller.player() != null;
                controller.unbindPlayer();
            }
            final Bundle bundle = DetailVideoFragment.createBundle(
                    holder.getVideoItem(),
                    source,
                    continuesPlayback,
                    RemoteApi.VideoType.FEED
            );
            VideoActivity.intentInto(getActivity(), SCENE_DETAIL, bundle);
        } else {
            final FragmentActivity activity = requireActivity();
            final Bundle arguments = DetailVideoFragment.createBundle(
                    holder.getVideoItem(),
                    RemoteApi.VideoType.FEED
            );
            arguments.putBoolean(DetailVideoFragment.EXTRA_KEEP_PLAYBACK_STATE, true);
            final DetailVideoFragment detail = DetailVideoFragment.newInstance(arguments);
            detail.setFeedVideoViewHolder(holder);
            detail.getLifecycle().addObserver(mDetailLifeCycle);
            activity.getSupportFragmentManager()
                    .beginTransaction()
                    .addToBackStack(null)
                    .add(android.R.id.content, detail, DetailVideoFragment.class.getName())
                    .commit();
        }
    }

    final LifecycleEventObserver mDetailLifeCycle = new LifecycleEventObserver() {
        @Override
        public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
            switch (event) {
                case ON_CREATE:
                    if (mListener != null) {
                        mListener.onEnterDetail();
                    }
                    break;
                case ON_DESTROY:
                    if (mListener != null) {
                        mListener.onExitDetail();
                    }
                    break;
            }
        }
    };
}
