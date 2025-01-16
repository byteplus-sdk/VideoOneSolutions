// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.selector;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.minidrama.R;
import com.byteplus.vod.minidrama.event.EpisodePlayStateChanged;
import com.byteplus.vod.minidrama.event.EpisodeUserSelectedEvent;
import com.byteplus.vod.minidrama.event.EpisodesUnlockedEvent;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaItemViewModel;
import com.byteplus.vod.minidrama.scene.detail.selector.model.IndexItem;
import com.byteplus.vod.minidrama.scene.detail.selector.model.Range;
import com.byteplus.vod.minidrama.utils.MiniEventBus;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class DramaEpisodePagerFragment extends Fragment {
    private static final int SPAN_COUNT = 6;

    public DramaEpisodePagerFragment() {
        super(R.layout.vevod_mini_drama_episode_select_pager_fragment);
    }

    DramaItemViewModel selectorViewModel;
    IndexItemViewModel viewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        selectorViewModel = new ViewModelProvider(requireParentFragment()).get(DramaItemViewModel.class);
        viewModel = new ViewModelProvider(this).get(IndexItemViewModel.class);

        Bundle arguments = requireArguments();
        Range range = Objects.requireNonNull(arguments.getParcelable("range"));

        DramaItem dramaItem = Objects.requireNonNull(selectorViewModel.dramaItem);
        viewModel.setRange(dramaItem, range);
    }

    EpisodeIndexAdapter adapter;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        RecyclerView recyclerView = view.findViewById(R.id.recycler_view);
        recyclerView.setLayoutManager(new GridLayoutManager(requireContext(), SPAN_COUNT));
        adapter = new EpisodeIndexAdapter(viewModel.getDramaId());
        recyclerView.setAdapter(adapter);

        viewModel.indexItems.observe(getViewLifecycleOwner(), adapter::setItems);

        MiniEventBus.register(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodePlayStateChanged(EpisodePlayStateChanged event) {
        if (!viewModel.getDramaId().equals(event.dramaId)) {
            return;
        }
        Range range = viewModel.range;
        if (range.contains(event.from) || range.contains(event.to)) {
            adapter.notifyPlayingStateChanged(event.from, event.to);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodesUnlockedEvent(EpisodesUnlockedEvent event) {
        if (!TextUtils.equals(selectorViewModel.dramaItem.getDramaId(), event.dramaId)) {
            return;
        }

        adapter.notifyUnlockStateChanged(event);
    }

    @Override
    public void onDestroyView() {
        MiniEventBus.unregister(this);
        super.onDestroyView();
    }

    static class EpisodeIndexAdapter extends RecyclerView.Adapter<EpisodeIndexViewHolder> {

        private final String dramaId;

        private List<IndexItem> items = Collections.emptyList();

        EpisodeIndexAdapter(String dramaId) {
            this.dramaId = dramaId;
        }

        @NonNull
        @Override
        public EpisodeIndexViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());
            View view = inflater.inflate(R.layout.vevod_mini_drama_episode_select_dialog_item, parent, false);
            return new EpisodeIndexViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull EpisodeIndexViewHolder holder, int position) {
            IndexItem item = items.get(position);
            holder.indexView.setText(String.valueOf(item.index));
            holder.lockView.setVisibility(item.locked ? View.VISIBLE : View.INVISIBLE);
            updatePlayingState(holder, item.playing);

            holder.itemView.setOnClickListener(v -> {
                IndexItem index = items.get(holder.getBindingAdapterPosition());
                MiniEventBus.post(new EpisodeUserSelectedEvent(dramaId, index.index));
            });
        }

        @Override
        public void onBindViewHolder(@NonNull EpisodeIndexViewHolder holder,
                                     int position,
                                     @NonNull List<Object> payloads) {
            if (payloads.isEmpty()) {
                super.onBindViewHolder(holder, position, payloads);
            } else {
                IndexItem item = items.get(position);
                if (payloads.contains(PAYLOAD_PLAYING_STATE_CHANGED)) {
                    updatePlayingState(holder, item.playing);
                }
                if (payloads.contains(PAYLOAD_LOCKED_STATE_CHANGED)) {
                    holder.lockView.setVisibility(item.locked ? View.VISIBLE : View.INVISIBLE);
                }
            }
        }

        private void updatePlayingState(EpisodeIndexViewHolder holder, boolean playing) {
            holder.playingView.setVisibility(playing ? View.VISIBLE : View.INVISIBLE);
            holder.itemView.setSelected(playing);
        }

        @Override
        public int getItemCount() {
            return items.size();
        }

        public void setItems(List<IndexItem> newItems) {
            List<IndexItem> oldItems = items;
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
                    IndexItem oldItem = oldItems.get(oldItemPosition);
                    IndexItem newItem = newItems.get(newItemPosition);
                    return oldItem.index == newItem.index
                            && oldItem.locked == newItem.locked
                            && oldItem.playing == newItem.playing;
                }

                @Override
                public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                    return false;
                }
            }).dispatchUpdatesTo(this);
        }

        public void notifyPlayingStateChanged(int from, int to) {
            for (int i = 0; i < items.size(); i++) {
                IndexItem item = items.get(i);
                if (item.index == from) {
                    item.playing = false;
                    notifyItemChanged(i, PAYLOAD_PLAYING_STATE_CHANGED);
                } else if (item.index == to) {
                    item.playing = true;
                    notifyItemChanged(i, PAYLOAD_PLAYING_STATE_CHANGED);
                }
            }
        }

        public void notifyUnlockStateChanged(EpisodesUnlockedEvent event) {
            for (int i = 0; i < items.size(); i++) {
                IndexItem item = items.get(i);
                if (event.has(item.index)) {
                    item.locked = false;
                    notifyItemChanged(i, PAYLOAD_LOCKED_STATE_CHANGED);
                }
            }
        }

        private static final String PAYLOAD_PLAYING_STATE_CHANGED = "playing_state_changed";
        private static final String PAYLOAD_LOCKED_STATE_CHANGED = "locked_state_changed";
    }

    static class EpisodeIndexViewHolder extends RecyclerView.ViewHolder {
        public final TextView indexView;
        public final ImageView playingView;
        public final ImageView lockView;

        public EpisodeIndexViewHolder(@NonNull View itemView) {
            super(itemView);
            indexView = itemView.findViewById(R.id.indexView);
            playingView = itemView.findViewById(R.id.playingView);
            lockView = itemView.findViewById(R.id.lockView);
        }
    }
}
