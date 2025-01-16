// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.selector;

import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.EXTRA_DRAMA_ITEM;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.DiffUtil;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.bumptech.glide.Glide;
import com.byteplus.vod.minidrama.event.EpisodePlayStateChanged;
import com.byteplus.vod.minidrama.event.EpisodeUserClickUnlockAllEvent;
import com.byteplus.vod.minidrama.event.EpisodeUserSelectedEvent;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaItemViewModel;
import com.byteplus.vod.minidrama.scene.detail.pay.UnlockDataHelper;
import com.byteplus.vod.minidrama.scene.detail.selector.model.Range;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaEpisodeSelectDialogFragmentBinding;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.android.material.tabs.TabLayoutMediator;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class DramaEpisodeSelectDialogFragment extends BottomSheetDialogFragment {
    private static final String TAG = "EpisodeSelectDialog2";

    public static final int SPLIT_COUNT = 5;

    public static DramaEpisodeSelectDialogFragment newInstance(DramaItem dramaItem) {
        Bundle bundle = new Bundle();
        bundle.putSerializable(EXTRA_DRAMA_ITEM, dramaItem);
        DramaEpisodeSelectDialogFragment fragment = new DramaEpisodeSelectDialogFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    public DramaEpisodeSelectDialogFragment() {
        super(R.layout.vevod_mini_drama_episode_select_dialog_fragment);
    }

    @Override
    public int getTheme() {
        return R.style.VeVodMiniDramaBottomSheetDark;
    }

    DramaItemViewModel viewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        viewModel = new ViewModelProvider(this).get(DramaItemViewModel.class);
        Bundle arguments = requireArguments();
        viewModel.setItem((DramaItem) arguments.getSerializable(EXTRA_DRAMA_ITEM));
    }

    VevodMiniDramaEpisodeSelectDialogFragmentBinding binding;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        Context context = requireContext();
        DramaItem item = Objects.requireNonNull(viewModel.dramaItem);

        binding = VevodMiniDramaEpisodeSelectDialogFragmentBinding.bind(view);

        binding.unlockAll.setVisibility(View.VISIBLE);
        binding.unlockAll.setOnClickListener(v -> {
            MiniEventBus.post(new EpisodeUserClickUnlockAllEvent());
            dismiss();
        });

        DramaEpisodesPagerAdapter adapter = new DramaEpisodesPagerAdapter(this);
        binding.viewPager.setAdapter(adapter);
        new TabLayoutMediator(binding.tab, binding.viewPager, true, (tab, position) -> {
            Range range = adapter.getItem(position);
            tab.setText(context.getString(R.string.vevod_mini_drama_episode_range, range.from, range.to));
        }).attach();


        Glide.with(binding.cover)
                .load(item.getCoverUrl())
                .into(binding.cover);
        binding.title.setText(item.getDramaTitle());
        binding.allEpisodes.setText(context.getString(R.string.vevod_mini_drama_all_episodes_count, item.getTotalEpisodeNumber()));

        adapter.setItems(createRanges(item.getTotalEpisodeNumber()));

        int selectedPage = Math.max(0, item.currentEpisodeNumber - 1) / SPLIT_COUNT;
        binding.viewPager.setCurrentItem(selectedPage, false);

        MiniEventBus.register(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodePlayStateChanged(EpisodePlayStateChanged event) {
        if (!TextUtils.equals(viewModel.getDramaId(), event.dramaId)) {
            Log.d(TAG, "onEpisodePlayStateChanged: dramaId not match: " + viewModel.getDramaId() + "!= " + event.dramaId);
            dismiss();
            return;
        }

        int selectedPage = Math.max(0, event.to - 1) / SPLIT_COUNT;
        binding.viewPager.setCurrentItem(selectedPage, false);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUserSelectEpisode(EpisodeUserSelectedEvent event) {
        dismiss();
    }

    @Override
    public void onDestroyView() {
        MiniEventBus.unregister(this);
        super.onDestroyView();
    }

    public boolean isShowing() {
        return getDialog() != null && getDialog().isShowing();
    }

    static class DramaEpisodesPagerAdapter extends FragmentStateAdapter {

        private List<Range> items = Collections.emptyList();

        public DramaEpisodesPagerAdapter(@NonNull Fragment fragment) {
            super(fragment);
        }

        @NonNull
        @Override
        public Fragment createFragment(int position) {
            DramaEpisodePagerFragment fragment = new DramaEpisodePagerFragment();
            Bundle args = new Bundle();
            args.putParcelable("range", items.get(position));
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public int getItemCount() {
            return items.size();
        }

        public Range getItem(int position) {
            return items.get(position);
        }

        public void setItems(List<Range> newItems) {
            List<Range> oldItems = this.items;
            this.items = newItems;
            DiffUtil.calculateDiff(new DiffUtil.Callback() {
                @Override
                public int getOldListSize() {
                    return oldItems.size();
                }

                @Override
                public int getNewListSize() {
                    return newItems.size();
                }

                @Override
                public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                    Range oldItem = oldItems.get(oldItemPosition);
                    Range newItem = newItems.get(newItemPosition);
                    return oldItem.from == newItem.from
                            && oldItem.to == newItem.to;
                }

                @Override
                public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                    return false;
                }
            }).dispatchUpdatesTo(this);
        }
    }

    static List<Range> createRanges(int count) {
        List<Range> ranges = new ArrayList<>();
        for (int from = 1; from <= count; from += SPLIT_COUNT) {
            int to = Math.min(from + SPLIT_COUNT - 1, count);
            ranges.add(new Range(from, to));
        }
        return ranges;
    }
}

