// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.video.scene.shortvideo;

import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.utils.L;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.page.Book;
import com.byteplus.vod.scenekit.data.page.Page;
import com.byteplus.vod.scenekit.ui.base.BaseFragment;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.ShortVideoSceneView;
import com.byteplus.voddemo.R;
import com.byteplus.vodcommon.data.remote.RemoteApi;
import com.byteplus.vodcommon.data.remote.api2.GetFeedStreamApi;

import java.util.List;


public class ShortVideoFragment extends BaseFragment {

    private RemoteApi.GetFeedStream mRemoteApi;
    private String mAccount;

    private final Book<VideoItem> mBook = new Book<>(10);
    private ShortVideoSceneView mSceneView;

    public ShortVideoFragment() {
        // Required empty public constructor
    }

    public static ShortVideoFragment newInstance() {
        ShortVideoFragment fragment = new ShortVideoFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRemoteApi = new GetFeedStreamApi();
        mAccount = VideoSettings.stringValue(VideoSettings.SHORT_VIDEO_SCENE_ACCOUNT_ID);
    }

    @Override
    protected void initBackPressedHandler() {
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.vevod_short_video_fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mSceneView = new ShortVideoSceneView(view);
        mSceneView.pageView().setLifeCycle(getLifecycle());
        mSceneView.setOnRefreshListener(this::refresh);
        mSceneView.setOnLoadMoreListener(this::loadMore);
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
        mRemoteApi.getFeedStream(RemoteApi.VideoType.SHORT, mAccount, 0, mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
            @Override
            public void onSuccess(Page<VideoItem> page) {
                L.d(this, "refresh", "success");
                if (getActivity() == null) return;
                List<VideoItem> videoItems = mBook.firstPage(page);
                VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_SHORT), null);
                mSceneView.dismissRefreshing();
                mSceneView.pageView().setItems(videoItems);
            }

            @Override
            public void onError(Throwable e) {
                L.d(this, "refresh", e, "error");
                if (getActivity() == null) return;
                mSceneView.dismissRefreshing();
                Toast.makeText(getActivity(), R.string.vevod_network_error, Toast.LENGTH_LONG).show();
            }
        });
    }

    private void loadMore() {
        if (mBook.hasMore()) {
            mSceneView.showLoadingMore();
            L.d(this, "loadMore", "start", mBook.nextPageIndex(), mBook.pageSize());
            mRemoteApi.getFeedStream(RemoteApi.VideoType.SHORT, mAccount, mBook.nextPageIndex(), mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
                @Override
                public void onSuccess(Page<VideoItem> page) {
                    L.d(this, "loadMore", "success", mBook.nextPageIndex());
                    if (getActivity() == null) return;
                    List<VideoItem> videoItems = mBook.addPage(page);
                    VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_SHORT), null);
                    mSceneView.dismissLoadingMore();
                    mSceneView.pageView().appendItems(videoItems);
                }

                @Override
                public void onError(Throwable e) {
                    L.d(this, "loadMore", "error", mBook.nextPageIndex());
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
}