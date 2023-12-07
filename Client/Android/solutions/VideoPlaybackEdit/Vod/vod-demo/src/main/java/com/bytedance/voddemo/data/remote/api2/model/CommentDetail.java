/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.bytedance.voddemo.data.remote.api2.model;

import com.bytedance.voddemo.ui.video.scene.comment.model.CommentItem;
import com.google.gson.annotations.SerializedName;

import java.util.Date;

public class CommentDetail {
    @SerializedName("content")
    public String content;
    @SerializedName("name")
    public String userName;
    @SerializedName("uid")
    public String userId;
    @SerializedName("createTime")
    public Date createTime;
    @SerializedName("like")
    public int likeNumber;

    public CommentItem toItem() {
        CommentItem item = new CommentItem();
        item.content = this.content;
        item.userName = this.userName;
        item.userId = this.userId;
        item.createTime = this.createTime;
        item.likeNumber = this.likeNumber;
        return item;
    }
}
