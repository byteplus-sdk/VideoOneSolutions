// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.video.scene.longvideo;

import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.utils.L;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.page.Book;
import com.byteplus.vod.scenekit.data.page.Page;
import com.byteplus.vod.scenekit.ui.base.BaseFragment;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.widgets.load.impl.RecycleViewLoadMoreHelper;
import com.byteplus.vodcommon.data.remote.RemoteApi;
import com.byteplus.vodcommon.data.remote.api2.GetFeedStreamApi;
import com.byteplus.voddemo.R;
import com.byteplus.voddemo.ui.video.scene.VideoActivity;
import com.byteplus.voddemo.ui.video.scene.detail.DetailVideoFragment;

import java.util.List;


public class LongVideoFragment extends BaseFragment {

    private RemoteApi.GetFeedStream mRemoteApi;
    private String mAccount;

    private final Book<VideoItem> mBook = new Book<>(12);
    private LongVideoAdapter mAdapter;
    private SwipeRefreshLayout mRefreshLayout;
    private RecycleViewLoadMoreHelper mLoadMoreHelper;
    private LongVideoDataTrans mDataTrans;

    public static LongVideoFragment newInstance() {
        return new LongVideoFragment();
    }

    @Override
    public boolean onBackPressed() {
        final String pageType = VideoSettings.stringValue(VideoSettings.DETAIL_VIDEO_SCENE_FRAGMENT_OR_ACTIVITY);
        if (TextUtils.equals(pageType, "Activity")) {
            return super.onBackPressed();
        } else {
            DetailVideoFragment detailVideoFragment = (DetailVideoFragment) requireActivity()
                    .getSupportFragmentManager()
                    .findFragmentByTag(DetailVideoFragment.class.getName());
            if (detailVideoFragment != null) {
                if (detailVideoFragment.onBackPressed()) {
                    return true;
                }
            }
            return super.onBackPressed();
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRemoteApi = new GetFeedStreamApi();
        mAccount = VideoSettings.stringValue(VideoSettings.LONG_VIDEO_SCENE_ACCOUNT_ID);
        mDataTrans = new LongVideoDataTrans(requireActivity());
        mAdapter = new LongVideoAdapter(new LongVideoAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(LongVideoAdapter.Item item, RecyclerView.ViewHolder holder) {
                if (item.type == LongVideoAdapter.Item.TYPE_VIDEO_ITEM) {
                    enterDetail(item.videoItem);
                }
            }

            @Override
            public void onHeaderItemClick(VideoItem item, RecyclerView.ViewHolder holder) {
                enterDetail(item);
            }
        });
    }

    private void enterDetail(VideoItem item) {
        final MediaSource source = VideoItem.toMediaSource(item);
        final Bundle bundle = DetailVideoFragment.createBundle(
                item, source, false, RemoteApi.VideoType.LONG);

        final String pageType = VideoSettings.stringValue(VideoSettings.DETAIL_VIDEO_SCENE_FRAGMENT_OR_ACTIVITY);

        if (TextUtils.equals(pageType, "Activity")) {
            VideoActivity.intentInto(requireActivity(), PlayScene.SCENE_DETAIL, bundle);
        } else {
            FragmentActivity activity = requireActivity();
            DetailVideoFragment detail = DetailVideoFragment.newInstance(bundle);
            activity.getSupportFragmentManager()
                    .beginTransaction()
                    .setCustomAnimations(R.anim.vevod_slide_in_right, R.anim.vevod_slide_out_right,
                            R.anim.vevod_slide_in_right, R.anim.vevod_slide_out_right)
                    .addToBackStack(null)
                    .add(android.R.id.content, detail, DetailVideoFragment.class.getName())
                    .commit();
        }
    }

    @Override
    protected void initBackPressedHandler() {
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.vevod_long_video_fragment;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mRefreshLayout = view.findViewById(R.id.swipeRefreshLayout);
        mRefreshLayout.setOnRefreshListener(() -> refresh());

        RecyclerView recyclerView = view.findViewById(R.id.recyclerView);
        GridLayoutManager layoutManager = new GridLayoutManager(requireActivity(), 2);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.setAdapter(mAdapter);
        recyclerView.addItemDecoration(new LongVideoItemDecoration(requireContext()));

        mLoadMoreHelper = new RecycleViewLoadMoreHelper(recyclerView);
        mLoadMoreHelper.setOnLoadMoreListener(() -> loadMore());
        refresh();
    }

    private void refresh() {
        L.d(this, "refresh", "start", 0, mBook.pageSize());
        showRefreshing();
        mRemoteApi.getFeedStream(RemoteApi.VideoType.LONG, mAccount, 0, mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
            @Override
            public void onSuccess(Page<VideoItem> page) {
                L.d(this, "refresh", "success");
                if (getActivity() == null) return;
                List<VideoItem> videoItems = mBook.firstPage(page);
                VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_LONG), null);
                dismissRefreshing();
                mDataTrans.setList(mAdapter, videoItems);
            }

            @Override
            public void onError(Throwable e) {
                L.d(this, "refresh", e, "error");
                if (getActivity() == null) return;
                dismissRefreshing();
                Toast.makeText(getActivity(), R.string.vevod_network_error, Toast.LENGTH_LONG).show();
            }
        });
    }

    private boolean isRefreshing() {
        return mRefreshLayout.isRefreshing();
    }

    private void dismissRefreshing() {
        mRefreshLayout.setRefreshing(false);
    }

    private void showRefreshing() {
        mRefreshLayout.setRefreshing(true);
    }

    private boolean isLoadingMore() {
        return mLoadMoreHelper.isLoadingMore();
    }

    private void showLoadingMore() {
        mLoadMoreHelper.showLoadingMore();
    }

    private void dismissLoadingMore() {
        mLoadMoreHelper.dismissLoadingMore();
    }

    private void finishLoadingMore() {
        mLoadMoreHelper.finishLoadingMore();
    }

    private void loadMore() {
        if (mBook.hasMore()) {
            if (isLoadingMore()) return;
            L.d(this, "loadMore", "start", mBook.nextPageIndex(), mBook.pageSize());
            showLoadingMore();
            mRemoteApi.getFeedStream(RemoteApi.VideoType.LONG, mAccount, mBook.nextPageIndex(), mBook.pageSize(), new RemoteApi.Callback<Page<VideoItem>>() {
                @Override
                public void onSuccess(Page<VideoItem> page) {
                    L.d(this, "loadMore", "success", mBook.nextPageIndex());
                    if (getActivity() == null) return;
                    List<VideoItem> videoItems = mBook.addPage(page);
                    VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_LONG), null);
                    dismissLoadingMore();
                    mDataTrans.append(mAdapter, videoItems);
                }

                @Override
                public void onError(Throwable e) {
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
