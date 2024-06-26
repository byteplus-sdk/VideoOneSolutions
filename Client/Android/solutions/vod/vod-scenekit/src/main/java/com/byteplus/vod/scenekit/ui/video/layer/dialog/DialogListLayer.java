// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.vod.scenekit.ui.video.layer.dialog;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;


public abstract class DialogListLayer<T> extends DialogLayer {

    private final Adapter<T> mAdapter;
    private CharSequence mTitle;

    public DialogListLayer() {
        this.mAdapter = initAdapter();
    }

    protected Adapter<T> initAdapter() {
        return new Adapter<>();
    }

    public void setTitle(CharSequence title) {
        this.mTitle = title;
    }

    protected Adapter<T> adapter() {
        return mAdapter;
    }

    @Nullable
    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_dialog_list_layer, parent, false);
        RecyclerView recyclerView = view.findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(parent.getContext(), LinearLayoutManager.VERTICAL, false));
        recyclerView.setAdapter(mAdapter);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                animateDismiss();
            }
        });

        View listPanel = view.findViewById(R.id.listPanel);
        listPanel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // do nothing
            }
        });

        TextView title = view.findViewById(R.id.title);
        if (title != null) {
            title.setText(mTitle);
        }
        return view;
    }

    public interface OnItemClickListener {
        void onItemClick(int position, RecyclerView.ViewHolder holder);
    }

    public static class Item<T> {
        public final T obj;
        public final String text;

        public Item(T obj, String text) {
            this.obj = obj;
            this.text = text;
        }
    }

    public static class Adapter<T> extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

        private final List<Item<T>> mItems = new ArrayList<>();

        private OnItemClickListener mListener;
        private Item<T> mSelected;

        public void setOnItemClickListener(OnItemClickListener listener) {
            this.mListener = listener;
        }

        public void setList(List<Item<T>> items) {
            mItems.clear();
            mItems.addAll(items);
            notifyDataSetChanged();
        }

        public void setSelected(Item<T> item) {
            if (mSelected != item) {
                mSelected = item;
                notifyDataSetChanged();
            }
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
            View item = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_dialog_list_layer_item, parent, false);
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

}
