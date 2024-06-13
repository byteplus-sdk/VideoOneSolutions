// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.chat;

import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

class ChatViewHolder extends RecyclerView.ViewHolder {
    public final TextView messageView;

    public ChatViewHolder(@NonNull View itemView) {
        super(itemView);
        messageView = (TextView) itemView;
    }
}
