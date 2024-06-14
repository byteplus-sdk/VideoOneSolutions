// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.utils;

import android.content.Context;

import androidx.annotation.NonNull;

import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.data.model.VideoItem;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class FormatHelper {
    public static String formatCountAndCreateTime(@NonNull Context context, @NonNull VideoItem videoItem) {
        return context.getString(R.string.vevod_feed_video_description,
                formatCount(context, videoItem.getPlayCount()),
                formatCreateTime(context, videoItem.getCreateTime())
        );
    }

    public static String formatDuration(@NonNull Context context, @NonNull VideoItem videoItem) {
        long durationInSeconds = videoItem.getDuration() / 1000;
        long minutes = durationInSeconds / 60;
        long seconds = durationInSeconds % 60;
        return String.format(Locale.ENGLISH, "%1$02d:%2$02d", minutes, seconds);
    }

    public static String formatCount(Context context, int playCount) {
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

    public static String formatCreateTime(Context context, Date createTime) {
        if (createTime == null) {
            return "";
        }
        return CREATE_TIME_FORMAT.format(createTime);
    }
}
