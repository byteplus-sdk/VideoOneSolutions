// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;


import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.Input;

import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Pair;
import android.view.View;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.ConcatAdapter;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.utils.ProgressRecorder;
import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaEntryEpisode;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.remote.model.drama.DramaTheaterEntity;
import com.byteplus.vod.minidrama.remote.model.drama.DramaTheaterType;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract;
import com.byteplus.vod.minidrama.scene.settings.DramaSettings;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaTheaterFragmentBinding;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.utils.ViewUtils;

import java.util.ArrayList;
import java.util.List;

public class DramaTheaterFragment extends Fragment {
    private GetDramas mRemoteApi;
    private DramaTheaterCarouselAdapter mCarouselAdapter;
    private DramaTheaterHeaderAdapter mTrendingHeaderAdapter;
    private DramaTheaterTrendingAdapter mTrendingAdapter;
    private DramaTheaterHeaderAdapter mNewHeaderAdapter;
    private DramaTheaterNewAdapter mNewAdapter;
    private DramaTheaterHeaderAdapter mRecommendHeaderAdapter;
    private DramaTheaterItemAdapter mRecommendAdapter;
    private DramaHomePreloader mHomePreloader;
    private DramaTheaterEntity mHomeData;

    public ActivityResultLauncher<Input> mDramaDetailPageLauncher
            = registerForActivityResult(new DramaDetailVideoActivityResultContract(), result -> {
    });

    private final IDramaTheaterClickListener mDramaClickListener = (info, position, infos) -> {
        // 点击后交给详情页策略，避免首页任务继续占用下载资源。
        // Hand over to the detail strategy on tap so home tasks stop using download resources.
        if (mHomePreloader != null) {
            mHomePreloader.stop();
        }
        Input input = new Input(createDramaItems(infos), position);
        mDramaDetailPageLauncher.launch(input);
    };

    public DramaTheaterFragment() {
        super(R.layout.vevod_mini_drama_theater_fragment);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRemoteApi = new GetDramas();
        mCarouselAdapter = new DramaTheaterCarouselAdapter();
        mTrendingHeaderAdapter = new DramaTheaterHeaderAdapter(R.string.vevod_mini_drama_main_tab_title_trending, true);
        mTrendingAdapter = new DramaTheaterTrendingAdapter();
        mNewHeaderAdapter = new DramaTheaterHeaderAdapter(R.string.vevod_mini_drama_main_tab_title_new, true);
        mNewAdapter = new DramaTheaterNewAdapter();
        mRecommendHeaderAdapter = new DramaTheaterHeaderAdapter(R.string.vevod_mini_drama_main_tab_title_recommend, true);
        mRecommendAdapter = new DramaTheaterItemAdapter();
    }

    private SwipeRefreshLayout mRefreshLayout;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        VevodMiniDramaTheaterFragmentBinding binding = VevodMiniDramaTheaterFragmentBinding.bind(view);

        mRefreshLayout = binding.swipeRefreshLayout;
        binding.swipeRefreshLayout.setOnRefreshListener(this::refresh);
        if (DramaSettings.isTheaterEntryPreloadEnabled()) {
            mHomePreloader = new DramaHomePreloader(CacheLoader.Default.get());
        }

        ConcatAdapter adapter = new ConcatAdapter(
                new ConcatAdapter.Config.Builder()
                        .setIsolateViewTypes(true)
                        .build(),
                mCarouselAdapter,
                mTrendingHeaderAdapter,
                mTrendingAdapter,
                mNewHeaderAdapter,
                mNewAdapter,
                mRecommendHeaderAdapter,
                mRecommendAdapter
        );

        final int SPAN_COUNT = 2;
        final int _4dp = ViewUtils.dp2px(4);
        final int _16dp = ViewUtils.dp2px(16);

        binding.recyclerView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect,
                                       @NonNull View view,
                                       @NonNull RecyclerView parent,
                                       @NonNull RecyclerView.State state) {
                final int globalPosition = parent.getChildAdapterPosition(view);
                Pair<RecyclerView.Adapter<? extends RecyclerView.ViewHolder>, Integer> pair
                        = adapter.getWrappedAdapterAndPosition(globalPosition);

                if (pair.first == mRecommendAdapter ||
                        pair.first == mTrendingAdapter ||
                        pair.first == mNewAdapter) { // For normal items
                    int position = pair.second;
                    int column = position % SPAN_COUNT;

                    if (column == 0) { // left column
                        outRect.left = _16dp;
                        outRect.right = _4dp;
                    } else if (column == (SPAN_COUNT - 1)) { // right column
                        outRect.left = _4dp;
                        outRect.right = _16dp;
                    } else {
                        outRect.left = _4dp;
                        outRect.right = _4dp;
                    }
                } else {
                    outRect.left = _16dp;
                    outRect.right = _16dp;
                }
            }
        });

        GridLayoutManager layoutManager = new GridLayoutManager(requireContext(), SPAN_COUNT);
        layoutManager.setSpanSizeLookup(
                new GridLayoutManager.SpanSizeLookup() {
                    @Override
                    public int getSpanSize(int position) {
                        Pair<RecyclerView.Adapter<? extends RecyclerView.ViewHolder>, Integer> pair
                                = adapter.getWrappedAdapterAndPosition(position);
                        int viewType = pair.first.getItemViewType(position);
                        switch (viewType) {
                            case ViewItemType.HEADER, ViewItemType.CAROUSEL, ViewItemType.TRENDING,
                                 ViewItemType.RELEASE_NEW -> {
                                return SPAN_COUNT;
                            }
                            case ViewItemType.ITEM -> {
                                return 1;
                            }
                        }
                        return 1;
                    }
                }
        );
        binding.recyclerView.setLayoutManager(layoutManager);
        binding.recyclerView.setAdapter(adapter);
        refresh();
    }

    private void refresh() {
        L.d(this, "refresh", "start refresh");
        showRefreshing();
        mRemoteApi.getDramaChannel(
                DramaSettings.isTheaterEntryPreloadEnabled(),
                new HttpCallback<>() {
            @Override
            public void onSuccess(DramaTheaterEntity result) {
                L.d(this, "refresh", "success");
                if (!isAdded() || mRefreshLayout == null) return;
                dismissRefreshing();

                List<DramaInfo> list;
                for (DramaTheaterType type : DramaTheaterType.values()) {
                    switch (type) {
                        case LOOP -> mCarouselAdapter.setItems(result.getInfos(type), mDramaClickListener);
                        case TRENDING -> {
                            list = result.getInfos(type);
                            mTrendingHeaderAdapter.setHidden(list == null || list.isEmpty());
                            mTrendingAdapter.setItems(list, mDramaClickListener);
                        }
                        case NEW -> {
                            list = result.getInfos(type);
                            mNewHeaderAdapter.setHidden(list == null || list.isEmpty());
                            mNewAdapter.setItems(list, mDramaClickListener);
                        }
                        case RECOMMEND -> {
                            list = result.getInfos(type);
                            mRecommendHeaderAdapter.setHidden(list == null || list.isEmpty());
                            mRecommendAdapter.setItems(list, mDramaClickListener);
                        }
                    }
                }
                mHomeData = result;
                preloadHome();
            }

            @Override
            public void onError(Throwable e) {
                L.d(this, "refresh", e, "error");
                if (!isAdded() || mRefreshLayout == null) return;
                dismissRefreshing();
                Toast.makeText(getActivity(), e.getMessage() + "", Toast.LENGTH_LONG).show();
            }
        });
    }

    private void dismissRefreshing() {
        if (mRefreshLayout != null) {
            mRefreshLayout.setRefreshing(false);
        }
    }

    private void showRefreshing() {
        if (mRefreshLayout != null) {
            mRefreshLayout.setRefreshing(true);
        }
    }

    private void preloadHome() {
        // 数据可能在页面不可见时返回，只在首页恢复可见后提交任务。
        // Feed data can arrive while hidden; submit tasks only when the home page is resumed.
        if (isResumed() && mHomePreloader != null && mHomeData != null) {
            mHomePreloader.preload(mHomeData);
        }
    }

    private static List<DramaItem> createDramaItems(List<DramaInfo> infos) {
        List<DramaItem> items = new ArrayList<>(infos.size());
        final long nowMs = System.currentTimeMillis();
        for (DramaInfo info : infos) {
            DramaItem item = new DramaItem(info, 1);
            DramaEntryEpisode entryEpisode = info.entryEpisode;
            if (entryEpisode != null && entryEpisode.isUsable(nowMs)) {
                if (TextUtils.isEmpty(entryEpisode.feed.dramaId)) {
                    entryEpisode.feed.dramaId = info.dramaId;
                }
                VideoItem videoItem = entryEpisode.feed.toVideoItem();
                VideoItem.syncProgress(videoItem, true);
                item.currentItem = videoItem;
                item.currentEpisodeNumber = entryEpisode.feed.episodeNumber;

                // 保留已有本地进度，仅在本地无进度时使用服务端续播位置。
                // Keep existing local progress; use the server resume position only when none is recorded.
                long localProgress = ProgressRecorder.getProgress(entryEpisode.feed.vid);
                if (localProgress <= 0 && entryEpisode.resumePositionMs > 0) {
                    ProgressRecorder.recordProgress(
                            entryEpisode.feed.vid,
                            entryEpisode.resumePositionMs);
                }
            }
            items.add(item);
        }
        return items;
    }

    @Override
    public void onResume() {
        super.onResume();
        preloadHome();
    }

    @Override
    public void onPause() {
        if (mHomePreloader != null) {
            mHomePreloader.stop();
        }
        super.onPause();
    }

    @Override
    public void onDestroyView() {
        // 取消视图生命周期内的请求和预加载，避免旧回调访问已销毁的视图。
        // Cancel view-scoped requests and preloads to keep old callbacks away from the destroyed view.
        mRemoteApi.cancel();
        if (mHomePreloader != null) {
            mHomePreloader.stop();
            mHomePreloader = null;
        }
        mHomeData = null;
        mRefreshLayout = null;
        super.onDestroyView();
    }

    @Override
    public void onDestroy() {
        mRemoteApi.cancel();
        super.onDestroy();
    }
}
