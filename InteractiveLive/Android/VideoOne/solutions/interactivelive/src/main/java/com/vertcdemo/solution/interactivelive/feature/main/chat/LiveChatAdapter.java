// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.chat;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.vertcdemo.solution.interactivelive.R;

import java.util.ArrayList;
import java.util.List;

public class LiveChatAdapter extends RecyclerView.Adapter<LiveChatAdapter.ChatViewHolder> {
    public static final int USER_NAME_COLOR = Color.parseColor("#BFFFFFFF");
    private final List<CharSequence> mMsgList = new ArrayList<>();

    @NonNull
    @Override
    public LiveChatAdapter.ChatViewHolder onCreateViewHolder(@NonNull ViewGroup parent,
                                                             int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_live_chat_layout, parent, false);
        return new ChatViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull LiveChatAdapter.ChatViewHolder holder, int position) {
        holder.messageView.setText(mMsgList.get(position));
    }

    @Override
    public int getItemCount() {
        return mMsgList.size();
    }

    @MainThread
    public void addChatMsg(@NonNull CharSequence info) {
        mMsgList.add(info);
        notifyItemInserted(mMsgList.size() - 1);
    }

    static class ChatViewHolder extends RecyclerView.ViewHolder {
        public final TextView messageView;

        public ChatViewHolder(@NonNull View itemView) {
            super(itemView);
            messageView = (TextView) itemView;
        }
    }
}
