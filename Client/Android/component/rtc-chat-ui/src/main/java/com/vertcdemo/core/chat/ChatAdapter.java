// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.chat;

import android.content.Context;
import android.graphics.Color;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.vertcdemo.rtc.chat.R;

import java.util.ArrayList;
import java.util.List;

public class ChatAdapter extends RecyclerView.Adapter<ChatViewHolder> {
    public static final int USER_NAME_COLOR = Color.parseColor("#BFFFFFFF");
    private final List<CharSequence> mMsgList = new ArrayList<>();

    @NonNull
    @Override
    public ChatViewHolder onCreateViewHolder(@NonNull ViewGroup parent,
                                             int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.layout_chat_item, parent, false);
        return new ChatViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ChatViewHolder holder, int position) {
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

    public void onNormalMessage(Context context, String userName, String content, boolean isHost) {
        SpannableStringBuilder ssb = new SpannableStringBuilder();

        if (isHost) {
            ssb.append(" ");
            ImageSpan imageSpan = new ImageSpan(context, R.drawable.ic_message_host);
            ssb.setSpan(imageSpan, 0, 1, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            ssb.append(" ");
        }
        { // Change User Name Color
            final int start = ssb.length();
            ssb.append(userName);
            final int end = ssb.length();

            final ForegroundColorSpan colorSpan = new ForegroundColorSpan(ChatAdapter.USER_NAME_COLOR);
            ssb.setSpan(colorSpan, start, end, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
        }
        ssb.append(": ");
        ssb.append(content);

        addChatMsg(ssb);
    }

    public static ChatAdapter bind(@NonNull RecyclerView view) {
        Context context = view.getContext();

        final LinearLayoutManager layoutManager = new LinearLayoutManager(context);
        layoutManager.setStackFromEnd(true);
        view.setLayoutManager(layoutManager);
        int space = context.getResources().getDimensionPixelSize(R.dimen.rtc_chat_message_space);
        view.addItemDecoration(new ChatItemDecoration(space));

        ChatAdapter adapter = new ChatAdapter();
        view.setAdapter(adapter);
        return adapter;
    }

    public void clear() {
        int itemCount = mMsgList.size();
        mMsgList.clear();
        notifyItemRangeRemoved(0, itemCount);
    }
}