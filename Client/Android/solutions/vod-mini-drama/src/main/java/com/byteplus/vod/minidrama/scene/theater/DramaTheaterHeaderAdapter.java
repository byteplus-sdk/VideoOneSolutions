// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.minidrama.R;

public class DramaTheaterHeaderAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> implements ViewItemType {
    @StringRes
    private final int title;
    private boolean mHidden;

    public DramaTheaterHeaderAdapter(@StringRes int title, boolean hidden) {
        this.title = title;
        mHidden = hidden;
    }

    public void setHidden(boolean hidden) {
        boolean hasChanged = mHidden != hidden;
        mHidden = hidden;
        if (hasChanged) {
            notifyDataSetChanged();
        }
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        View view = inflater.inflate(R.layout.vevod_mini_drama_category_item, parent, false);
        TextView text = view.findViewById(R.id.text);
        text.setText(title);
        return new RecyclerView.ViewHolder(view){};
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        // do nothing
    }

    @Override
    public int getItemCount() {
        return mHidden ? 0 : 1;
    }

    @Override
    public int getItemViewType(int position) {
        return HEADER;
    }
}
