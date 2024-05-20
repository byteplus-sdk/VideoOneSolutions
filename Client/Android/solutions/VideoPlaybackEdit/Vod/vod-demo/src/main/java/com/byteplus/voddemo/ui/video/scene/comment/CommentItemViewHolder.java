// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.voddemo.ui.video.scene.comment;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.voddemo.R;

class CommentItemViewHolder extends RecyclerView.ViewHolder {

    public ImageView avatar;
    public TextView name;
    public TextView comment;
    public TextView time;
    public TextView likeNum;

    public View delete;


    public CommentItemViewHolder(@NonNull View itemView) {
        super(itemView);

        avatar = itemView.findViewById(R.id.avatar);
        name = itemView.findViewById(R.id.name);
        comment = itemView.findViewById(R.id.comment);
        time = itemView.findViewById(R.id.time);
        likeNum = itemView.findViewById(R.id.likeNum);

        delete = itemView.findViewById(R.id.delete);
    }
}
