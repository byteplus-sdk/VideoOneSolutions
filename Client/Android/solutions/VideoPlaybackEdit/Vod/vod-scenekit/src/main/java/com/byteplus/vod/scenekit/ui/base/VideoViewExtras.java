// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.base;

import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.data.model.VideoItem;

public class VideoViewExtras {

    public static void updateExtra(@Nullable VideoView view, @Nullable VideoItem item) {
        if (view == null) {
            return;
        }

        view.setTag(R.id.vevod_video_item, item);
    }

    public static int getLikeCount(@Nullable VideoView view) {
        if (view == null) {
            return 0;
        }

        VideoItem item = (VideoItem) view.getTag(R.id.vevod_video_item);

        return item == null ? 0 : item.getLikeCount();
    }

    public static void setLikeCount(@Nullable VideoView view, int value) {
        if (view == null) {
            return;
        }

        VideoItem item = (VideoItem) view.getTag(R.id.vevod_video_item);

        if (item == null) {
            return;
        }

        item.setLikeCount(value);
    }

    public static boolean isILikeIt(@Nullable VideoView view) {
        if (view == null) {
            return false;
        }

        VideoItem item = (VideoItem) view.getTag(R.id.vevod_video_item);

        return item != null && item.isILikeIt();
    }

    public static void setILikeIt(@Nullable VideoView view, boolean value) {
        if (view == null) {
            return;
        }

        VideoItem item = (VideoItem) view.getTag(R.id.vevod_video_item);

        if (item == null) {
            return;
        }
        item.setILikeIt(value);
    }


    public static int getCommentCount(@Nullable VideoView view) {
        if (view == null) {
            return 0;
        }

        VideoItem item = (VideoItem) view.getTag(R.id.vevod_video_item);

        return item == null ? 0 : item.getCommentCount();
    }

    @Nullable
    public static String getVid(@Nullable VideoView view) {
        if (view == null) {
            return null;
        }

        VideoItem item = (VideoItem) view.getTag(R.id.vevod_video_item);

        return item == null ? null : item.getVid();
    }

    @Nullable
    public static VideoItem getVideoItem(@Nullable VideoView view) {
        if (view == null) {
            return null;
        }
        return (VideoItem) view.getTag(R.id.vevod_video_item);
    }
}
