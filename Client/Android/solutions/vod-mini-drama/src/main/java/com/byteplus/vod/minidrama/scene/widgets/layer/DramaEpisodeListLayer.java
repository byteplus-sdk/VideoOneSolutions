// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.DiffUtil;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.bumptech.glide.Glide;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaEpisodeListScelectLayerBinding;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.vod.minidrama.event.EpisodePlayStateChanged;
import com.byteplus.vod.minidrama.event.EpisodeUserClickUnlockAllEvent;
import com.byteplus.vod.minidrama.event.EpisodeUserSelectedEvent;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaItemViewModel;
import com.byteplus.vod.minidrama.scene.detail.pay.UnlockDataHelper;
import com.byteplus.vod.minidrama.scene.detail.selector.DramaEpisodePagerFragment;
import com.byteplus.vod.minidrama.scene.detail.selector.model.Range;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.vod.scenekit.ui.video.layer.ListBaseLayer;
import com.google.android.material.tabs.TabLayoutMediator;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DramaEpisodeListLayer extends ListBaseLayer {

    public interface IEpisodeListCallback {
        int getSize();
        DramaItem getDramaItem();
        Fragment getFragment();
    }

    private static final String TAG = "DramaEpisodeListLayer";

    public static final int SPLIT_COUNT = 5;

    private final IEpisodeListCallback mCallback;

    VevodMiniDramaEpisodeListScelectLayerBinding binding;

    @Override
    public String tag() {
        return "drama_episode_list";
    }

    public DramaEpisodeListLayer(@NonNull IEpisodeListCallback callback) {
        mCallback = callback;
    }

    @Override
    public int getSize() {
        return mCallback.getSize();
    }

    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        DramaItemViewModel viewModel = new ViewModelProvider(mCallback.getFragment()).get(DramaItemViewModel.class);
        viewModel.setItem(mCallback.getDramaItem());
        Context context = parent.getContext();
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_mini_drama_episode_list_scelect_layer, parent, false);
        view.setOnClickListener(v -> animateDismiss());
        binding = VevodMiniDramaEpisodeListScelectLayerBinding.bind(view);

        if (UnlockDataHelper.hasLocked(mCallback.getDramaItem())) {
            binding.unlockAll.setVisibility(View.VISIBLE);
            binding.unlockAll.setOnClickListener(v -> {
                MiniEventBus.post(new EpisodeUserClickUnlockAllEvent());
                dismiss();
            });
        } else {
            binding.unlockAll.setVisibility(View.GONE);
        }

        refreshRanges();
        new TabLayoutMediator(binding.tab, binding.viewPager, true, (tab, position) -> {
            DramaEpisodesPagerAdapter adapter = (DramaEpisodesPagerAdapter) binding.viewPager.getAdapter();
            if (adapter == null) {
                return;
            }
            Range range = adapter.getItem(position);
            tab.setText(context.getString(R.string.vevod_mini_drama_episode_range, range.from, range.to));
        }).attach();


        Glide.with(binding.cover)
                .load(mCallback.getDramaItem().getCoverUrl())
                .into(binding.cover);
        binding.title.setText(mCallback.getDramaItem().getDramaTitle());
        binding.allEpisodes.setText(context.getString(R.string.vevod_mini_drama_all_episodes_count, mCallback.getDramaItem().getTotalEpisodeNumber()));
        return view;
    }

    private void refreshRanges() {
        DramaEpisodesPagerAdapter adapter = new DramaEpisodesPagerAdapter(mCallback.getFragment());
        binding.viewPager.setAdapter(adapter);
        adapter.setItems(createRanges(mCallback.getDramaItem().getTotalEpisodeNumber()));
        int selectedPage = Math.max(0, mCallback.getDramaItem().currentEpisodeNumber - 1) / SPLIT_COUNT;
        binding.viewPager.setCurrentItem(selectedPage, false);
    }

    @Override
    protected void onUnbindLayerHost(@NonNull VideoLayerHost layerHost) {
        super.onUnbindLayerHost(layerHost);
        MiniEventBus.unregister(this);
    }

    @Override
    public void show() {
        super.show();
        refreshRanges();
        MiniEventBus.register(this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        MiniEventBus.unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodePlayStateChanged(EpisodePlayStateChanged event) {
        if (!TextUtils.equals(mCallback.getDramaItem().getDramaId(), event.dramaId)) {
            Log.d(TAG, "onEpisodePlayStateChanged: dramaId not match: " + mCallback.getDramaItem().getDramaId() + "!= " + event.dramaId);
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
