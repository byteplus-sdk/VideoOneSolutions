// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;


import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.Input;

import android.graphics.Rect;
import android.os.Bundle;
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

import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.remote.model.drama.DramaTheaterEntity;
import com.byteplus.vod.minidrama.remote.model.drama.DramaTheaterType;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaTheaterFragmentBinding;
import com.byteplus.vod.scenekit.utils.ViewUtils;

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
    public ActivityResultLauncher<Input> mDramaDetailPageLauncher
            = registerForActivityResult(new DramaDetailVideoActivityResultContract(), result -> {
    });

    private final IDramaTheaterClickListener mDramaClickListener = (info, position, infos) -> {
        Input input = new Input(
                DramaItem.createByDramaInfos(infos),
                position
        );
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
        mRemoteApi.getDramaChannel(new HttpCallback<>() {
            @Override
            public void onSuccess(DramaTheaterEntity result) {
                L.d(this, "refresh", "success");
                if (getActivity() == null) return;
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
            }

            @Override
            public void onError(Throwable e) {
                L.d(this, "refresh", e, "error");
                if (getActivity() == null) return;
                dismissRefreshing();
                Toast.makeText(getActivity(), e.getMessage() + "", Toast.LENGTH_LONG).show();
            }
        });
    }

    private void dismissRefreshing() {
        mRefreshLayout.setRefreshing(false);
    }

    private void showRefreshing() {
        mRefreshLayout.setRefreshing(true);
    }
}
