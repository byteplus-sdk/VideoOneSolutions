// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.minidrama.R;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;

public class DramaSpeedSelectorFragment extends BottomSheetDialogFragment {
    public static final String REQUEST_KEY = "request_key_speed_selector";
    public static final String EXTRA_PLAYBACK_SPEED = "extra_playback_speed";

    private static List<Item<Float>> createItems(Context context) {
        return Arrays.asList(
                new Item<>(3.0F, "3.0x"),
                new Item<>(2.0F, "2.0x"),
                new Item<>(1.5F, "1.5x"),
                new Item<>(1.0F, "1.0x"),
                new Item<>(0.5F, "0.5x")
        );
    }

    public DramaSpeedSelectorFragment() {
        super(R.layout.vevod_mini_drama_speed_selector_fragment);
    }

    @Override
    public int getTheme() {
        return R.style.VeVodMiniDramaBottomSheetDark;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        Bundle arguments = requireArguments();
        float playbackSpeed = arguments.getFloat(EXTRA_PLAYBACK_SPEED, 1.0F);
        RecyclerView recyclerView = view.findViewById(R.id.recycler_view);
        Adapter<Float> mAdapter = new Adapter<>(createItems(requireContext()), playbackSpeed);
        recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerView.setAdapter(mAdapter);
        mAdapter.setOnItemClickListener((position, holder) -> {
            Item<Float> item = mAdapter.getItem(position);
            Item<Float> selected = mAdapter.mSelected;
            if (selected != null && Objects.equals(item.obj, selected.obj)) {
                dismiss();
                return;
            }
            Bundle result = new Bundle();
            result.putFloat(EXTRA_PLAYBACK_SPEED, item.obj);
            getParentFragmentManager().setFragmentResult(REQUEST_KEY, result);
            dismiss();
        });
    }

    public interface OnItemClickListener {
        void onItemClick(int position, RecyclerView.ViewHolder holder);
    }

    public static class Adapter<T> extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

        private final List<Item<T>> mItems;

        private OnItemClickListener mListener;
        public Item<T> mSelected;

        public Adapter(List<Item<T>> items, T current) {
            mItems = items;
            mSelected = findItem(current);
        }

        public void setOnItemClickListener(OnItemClickListener listener) {
            this.mListener = listener;
        }

        public Item<T> findItem(T obj) {
            for (Item<T> item : mItems) {
                if (Objects.equals(obj, item.obj)) return item;
            }
            return null;
        }

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View item = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.vevod_mini_drama_speed_selector_item, parent, false);
            RecyclerView.ViewHolder holder = new RecyclerView.ViewHolder(item) {
            };
            holder.itemView.setOnClickListener(v -> {
                if (mListener != null) {
                    mListener.onItemClick(holder.getBindingAdapterPosition(), holder);
                }
            });
            return holder;
        }

        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
            Item<T> item = mItems.get(position);
            TextView text = holder.itemView.findViewById(R.id.text);
            text.setText(item.text);
            holder.itemView.setSelected(Objects.equals(mSelected, item));
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

        public Item<T> getItem(int position) {
            return mItems.get(position);
        }
    }

    public static class Item<T> {
        public final T obj;
        public final String text;

        public Item(T obj, String text) {
            this.obj = obj;
            this.text = text;
        }
    }
}
