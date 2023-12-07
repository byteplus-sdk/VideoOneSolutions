/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.bytedance.voddemo.ui.video.scene.comment.model;

import com.vertcdemo.core.SolutionDataManager;

import java.util.Date;

public class CommentItem {

    public String content;
    public String userName;
    public String userId;
    public Date createTime;
    public int likeNumber;

    public boolean isSelf = false;

    public boolean iLikeIt = false;


    public static CommentItem self(String content) {
        CommentItem item = new CommentItem();
        item.userId = SolutionDataManager.ins().getUserId();
        item.userName = SolutionDataManager.ins().getUserName();
        item.content = content;
        item.createTime = new Date();
        item.likeNumber = 0;
        item.isSelf = true;

        return item;
    }
}
