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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DramaTheaterFragment extends Fragment {
    private static final long VIEWPORT_SETTLE_DELAY_MS = 150L;
    private static final int NEW_LOOK_AHEAD_COUNT = 2;
    private static final int TRENDING_LOOK_AHEAD_COUNT = 3;
    private static final int RECOMMEND_LOOK_AHEAD_COUNT = 2;

    private GetDramas mRemoteApi;
    private DramaTheaterCarouselAdapter mCarouselAdapter;
    private DramaTheaterHeaderAdapter mTrendingHeaderAdapter;
    private DramaTheaterTrendingAdapter mTrendingAdapter;
    private DramaTheaterHeaderAdapter mNewHeaderAdapter;
    private DramaTheaterNewAdapter mNewAdapter;
    private DramaTheaterHeaderAdapter mRecommendHeaderAdapter;
    private DramaTheaterItemAdapter mRecommendAdapter;
    private RecyclerView mRecyclerView;
    private DramaBrowsePreloadCoordinator mPreloadCoordinator;
    private int mLastScrollDy;
    private final Runnable mUpdatePreloadCandidates = this::updatePreloadCandidates;

    public ActivityResultLauncher<Input> mDramaDetailPageLauncher
            = registerForActivityResult(new DramaDetailVideoActivityResultContract(), result -> {
        schedulePreloadUpdate();
    });

    private final IDramaTheaterClickListener mDramaClickListener = (info, position, infos) -> {
        if (mPreloadCoordinator != null) {
            mPreloadCoordinator.prepareForPlayback(info.dramaId);
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
        mRecyclerView = binding.recyclerView;
        if (DramaSettings.isTheaterEntryPreloadEnabled()) {
            mPreloadCoordinator = new DramaBrowsePreloadCoordinator(
                    requireContext(),
                    CacheLoader.Default.get());
        }

        mCarouselAdapter.setViewportChangedListener(this::schedulePreloadUpdate);
        mTrendingAdapter.setViewportChangedListener(this::schedulePreloadUpdate);
        mNewAdapter.setViewportChangedListener(this::schedulePreloadUpdate);

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
        binding.recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                if (dy != 0) {
                    mLastScrollDy = dy;
                }
            }

            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    schedulePreloadUpdate();
                }
            }
        });
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
                schedulePreloadUpdate();
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

    private void schedulePreloadUpdate() {
        RecyclerView recyclerView = mRecyclerView;
        if (recyclerView == null || mPreloadCoordinator == null) return;
        recyclerView.removeCallbacks(mUpdatePreloadCandidates);
        recyclerView.postDelayed(mUpdatePreloadCandidates, VIEWPORT_SETTLE_DELAY_MS);
    }

    private void updatePreloadCandidates() {
        if (!isResumed() || mPreloadCoordinator == null) return;
        mPreloadCoordinator.updateCandidates(collectPreloadCandidates());
    }

    private List<DramaInfo> collectPreloadCandidates() {
        RecyclerView recyclerView = mRecyclerView;
        if (recyclerView == null) return new ArrayList<>();

        Map<String, DramaInfo> candidates = new LinkedHashMap<>();
        int firstRecommendPosition = Integer.MAX_VALUE;
        int lastRecommendPosition = RecyclerView.NO_POSITION;

        for (int index = 0; index < recyclerView.getChildCount(); index++) {
            View child = recyclerView.getChildAt(index);
            RecyclerView.ViewHolder holder = recyclerView.getChildViewHolder(child);
            List<DramaInfo> nestedCandidates = new ArrayList<>();

            if (holder instanceof DramaTheaterCarouselAdapter.ViewHolder carouselHolder) {
                addCandidate(candidates, carouselHolder.getCurrentItem());
            } else if (holder instanceof DramaTheaterTrendingAdapter.ViewHolder trendingHolder) {
                trendingHolder.collectCandidates(nestedCandidates, TRENDING_LOOK_AHEAD_COUNT);
            } else if (holder instanceof DramaTheaterNewAdapter.ViewHolder newHolder) {
                newHolder.collectCandidates(nestedCandidates, NEW_LOOK_AHEAD_COUNT);
            } else if (holder instanceof DramaTheaterItemAdapter.ViewHolder itemHolder) {
                addCandidate(candidates, itemHolder.getItem());
                int position = itemHolder.getBindingAdapterPosition();
                if (position != RecyclerView.NO_POSITION) {
                    firstRecommendPosition = Math.min(firstRecommendPosition, position);
                    lastRecommendPosition = Math.max(lastRecommendPosition, position);
                }
            }
            addCandidates(candidates, nestedCandidates);
        }

        if (lastRecommendPosition != RecyclerView.NO_POSITION) {
            if (mLastScrollDy >= 0) {
                int end = Math.min(
                        mRecommendAdapter.getItemCount() - 1,
                        lastRecommendPosition + RECOMMEND_LOOK_AHEAD_COUNT);
                for (int position = lastRecommendPosition + 1; position <= end; position++) {
                    addCandidate(candidates, mRecommendAdapter.getItems().get(position));
                }
            } else {
                int start = Math.max(0, firstRecommendPosition - RECOMMEND_LOOK_AHEAD_COUNT);
                for (int position = firstRecommendPosition - 1; position >= start; position--) {
                    addCandidate(candidates, mRecommendAdapter.getItems().get(position));
                }
            }
        }

        return new ArrayList<>(candidates.values());
    }

    private static void addCandidates(
            Map<String, DramaInfo> candidates,
            List<DramaInfo> items) {
        for (DramaInfo item : items) {
            addCandidate(candidates, item);
        }
    }

    private static void addCandidate(Map<String, DramaInfo> candidates, DramaInfo info) {
        if (info == null || TextUtils.isEmpty(info.dramaId)) return;
        candidates.putIfAbsent(info.dramaId, info);
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
        if (mPreloadCoordinator != null) {
            mPreloadCoordinator.resume();
        }
        schedulePreloadUpdate();
    }

    @Override
    public void onStop() {
        if (mPreloadCoordinator != null) {
            mPreloadCoordinator.pause();
        }
        super.onStop();
    }

    @Override
    public void onDestroyView() {
        if (mRecyclerView != null) {
            mRecyclerView.removeCallbacks(mUpdatePreloadCandidates);
        }
        mRemoteApi.cancel();
        if (mPreloadCoordinator != null) {
            mPreloadCoordinator.release();
            mPreloadCoordinator = null;
        }
        mCarouselAdapter.setViewportChangedListener(null);
        mTrendingAdapter.setViewportChangedListener(null);
        mNewAdapter.setViewportChangedListener(null);
        mRecyclerView = null;
        mRefreshLayout = null;
        super.onDestroyView();
    }

    @Override
    public void onDestroy() {
        mRemoteApi.cancel();
        super.onDestroy();
    }
}
