// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common.panel;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.live.common.R;

import java.util.ArrayList;
import java.util.List;

@MainThread
public class MultiInfoPanel extends InfoPanel {
    private final InfoAdapter mAdapter;

    public MultiInfoPanel(@StringRes int title, View root) {
        super(title, root);
        Context context = root.getContext();

        TextView titleView = root.findViewById(R.id.title);
        titleView.setText(title);

        mAdapter = new InfoAdapter(context);

        RecyclerView contentView = root.findViewById(R.id.content);
        contentView.setLayoutManager(new LinearLayoutManager(context));
        contentView.setAdapter(mAdapter);
    }

    public void appendContent(String content) {
        if (!mEnabled) {
            return;
        }
        mAdapter.append(content);
    }

    public void setEnabled(boolean enable) {
        if (!enable) {
            mAdapter.clear();
        }

        super.setEnabled(enable);
    }

    static class InfoAdapter extends RecyclerView.Adapter<InfoViewHolder> {

        private final List<String> mItems = new ArrayList<>();

        private final LayoutInflater mInflater;

        InfoAdapter(@NonNull Context context) {
            mInflater = LayoutInflater.from(context);
        }

        @NonNull
        @Override
        public InfoViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new InfoViewHolder(
                    mInflater.inflate(R.layout.live_player_info_item, parent, false)
            );
        }

        @Override
        public void onBindViewHolder(@NonNull InfoViewHolder holder, int position) {
            holder.text.setText(mItems.get(position));
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

        void append(String item) {
            mItems.add(item);
            int position = mItems.size();
            notifyItemInserted(position);
        }

        void clear() {
            int count = mItems.size();
            mItems.clear();
            notifyItemRangeRemoved(0, count);
        }
    }

    static class InfoViewHolder extends RecyclerView.ViewHolder {
        final TextView text;

        public InfoViewHolder(@NonNull View itemView) {
            super(itemView);
            text = (TextView) itemView;
        }
    }
}
