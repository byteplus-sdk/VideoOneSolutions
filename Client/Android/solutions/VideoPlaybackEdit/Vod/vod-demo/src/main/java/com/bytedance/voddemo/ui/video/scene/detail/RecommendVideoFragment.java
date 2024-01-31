// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.ui.video.scene.detail;


import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.bytedance.playerkit.utils.L;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.data.page.Book;
import com.bytedance.vod.scenekit.data.page.Page;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.vod.scenekit.ui.widgets.load.impl.RecycleViewLoadMoreHelper;
import com.bytedance.voddemo.data.remote.RemoteApi;
import com.bytedance.voddemo.data.remote.api2.GetFeedStreamApi;
import com.bytedance.voddemo.impl.R;
import com.bytedance.voddemo.impl.databinding.VevodRecommendVideoFragmentBinding;
import com.bytedance.voddemo.ui.video.scene.detail.bean.RecommendInfo;

import java.util.List;

public class RecommendVideoFragment extends Fragment implements RecommendVideoAdapter.OnItemClickListener {

    private DetailViewModel mDetailModel;

    private GetFeedStreamApi mRemoteApi;

    private final Book<VideoItem> mBook = new Book<>(10);

    private RecycleViewLoadMoreHelper mLoadMoreHelper;

    private RecommendVideoAdapter mAdapter;

    public RecommendVideoFragment() {
        super(R.layout.vevod_recommend_video_fragment);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRemoteApi = new GetFeedStreamApi();
        mDetailModel = new ViewModelProvider(requireParentFragment()).get(DetailViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodRecommendVideoFragmentBinding binding = VevodRecommendVideoFragmentBinding.bind(view);

        binding.recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
        mAdapter = new RecommendVideoAdapter(requireContext(), this);
        binding.recycler.setAdapter(mAdapter);

        mLoadMoreHelper = new RecycleViewLoadMoreHelper(binding.recycler);
        mLoadMoreHelper.setOnLoadMoreListener(() -> {
            RecommendInfo info = mDetailModel.recommendInfo.getValue();
            if (info != null) {
                loadMore(info.vid, info.videoType);
            }
        });

        mDetailModel.recommendInfo.observe(getViewLifecycleOwner(), info -> {
            L.d(this, "recommend.observe", "Recommend=" + info);
            if (info != null) {
                mLoadMoreHelper.setLoadMoreEnabled(false);
                mAdapter.clear();
                refresh(info.vid, info.videoType);
            }
        });
    }

    public void onItemClick(@NonNull VideoItem item) {
        mDetailModel.recommendVideoItem.setValue(item);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mRemoteApi.cancel();
    }

    void setItems(List<VideoItem> videoItems) {
        mAdapter.setItems(videoItems);
        mLoadMoreHelper.setLoadMoreEnabled(true);
    }

    void appendItems(List<VideoItem> videoItems) {
        mAdapter.appendItems(videoItems);
    }

    void showRefreshing() {

    }

    void dismissRefreshing() {

    }

    void showLoadingMore() {
        mLoadMoreHelper.showLoadingMore();
    }

    void dismissLoadingMore() {
        mLoadMoreHelper.dismissLoadingMore();
    }

    void finishLoadingMore() {
        mLoadMoreHelper.finishLoadingMore();
    }

    private void refresh(String vid, @RemoteApi.VideoType int videoType) {
        L.d(this, "refresh", "start", 0, mBook.pageSize());
        showRefreshing();
        mRemoteApi.getFeedSimilarVideos(vid, videoType, 0, mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
            @Override
            public void onSuccess(Page<VideoItem> page) {
                L.d(this, "refresh", "success");
                if (getActivity() == null) return;
                List<VideoItem> videoItems = mBook.firstPage(page);
                VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_DETAIL));
                dismissRefreshing();
                setItems(videoItems);
            }

            @Override
            public void onError(Exception e) {
                L.d(this, "refresh", e, "error");
                if (getActivity() == null) return;
                dismissRefreshing();
                Toast.makeText(getActivity(), R.string.vevod_network_error, Toast.LENGTH_LONG).show();
            }
        });
    }

    private void loadMore(String vid, @RemoteApi.VideoType int videoType) {
        if (mBook.hasMore()) {
            showLoadingMore();
            L.d(this, "loadMore", "start", mBook.nextPageIndex(), mBook.pageSize());
            mRemoteApi.getFeedSimilarVideos(vid, videoType, mBook.nextPageIndex(), mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
                @Override
                public void onSuccess(Page<VideoItem> page) {
                    L.d(this, "loadMore", "success", mBook.nextPageIndex());
                    if (getActivity() == null) return;
                    List<VideoItem> videoItems = mBook.addPage(page);
                    VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_DETAIL));
                    dismissLoadingMore();
                    appendItems(videoItems);
                }

                @Override
                public void onError(Exception e) {
                    L.d(this, "loadMore", "error", mBook.nextPageIndex());
                    if (getActivity() == null) return;
                    dismissLoadingMore();
                    Toast.makeText(getActivity(), R.string.vevod_network_error, Toast.LENGTH_LONG).show();
                }
            });
        } else {
            mBook.end();
            finishLoadingMore();
            L.d(this, "loadMore", "end");
        }
    }
}
