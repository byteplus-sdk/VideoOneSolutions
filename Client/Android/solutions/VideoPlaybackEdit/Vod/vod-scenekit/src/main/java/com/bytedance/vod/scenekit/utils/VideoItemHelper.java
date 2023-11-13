// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.utils;

import android.content.Context;

import androidx.annotation.NonNull;

import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.R;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class VideoItemHelper {
    public static String formatPlayCountAndCreateTime(@NonNull Context context, @NonNull VideoItem videoItem) {
        return context.getString(R.string.vevod_feed_video_description,
                formatPlayCount(context, videoItem.getPlayCount()),
                formatCreateTime(context, videoItem.getCreateTime())
        );
    }

    private static String formatPlayCount(Context context, int playCount) {
        if (playCount < 0) {
            return String.valueOf(1);
        } else if (Locale.getDefault().getLanguage().equals("zh")) {
            if (playCount < 10_000) {
                return String.valueOf(playCount);
            } else {
                return context.getString(R.string.vevod_feed_video_count_ten_thousand_zh, playCount / 10_000.F);
            }
        } else {
            if (playCount < 1000) {
                return String.valueOf(playCount);
            } else if (playCount < 1_000_000) {
                return context.getString(R.string.vevod_feed_video_count_thousand, playCount / 1000.F);
            } else {
                return context.getString(R.string.vevod_feed_video_count_million, playCount / 1_000_000.F);
            }
        }
    }

    private static final SimpleDateFormat CREATE_TIME_FORMAT = new SimpleDateFormat("dd/MM/yyyy", Locale.ENGLISH);

    private static String formatCreateTime(Context context, Date createTime) {
        if (createTime == null) {
            return "";
        }
        return CREATE_TIME_FORMAT.format(createTime);
    }
}
