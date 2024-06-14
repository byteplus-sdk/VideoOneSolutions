// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.voddemo.ui.video.scene.longvideo;

import android.content.Context;

import androidx.annotation.NonNull;

import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.voddemo.R;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


class LongVideoDataTrans {

    void setList(LongVideoAdapter adapter, List<VideoItem> videoItems) {
        resetConfig();
        List<LongVideoAdapter.Item> items = createItems(videoItems);
        adapter.setItems(items);
    }

    private void resetConfig() {
        for (GroupConfig config : groupConfigs) {
            config.index = 0;
        }
    }

    @NonNull
    private List<LongVideoAdapter.Item> createItems(List<VideoItem> videoItems) {
        List<LongVideoAdapter.Item> items = new ArrayList<>();
        int index = 0;
        for (GroupConfig config : groupConfigs) {
            if (index >= videoItems.size()) break;
            if (config.isDone()) continue;

            if (config.type != GroupConfig.TYPE_PAGER) {
                if (config.index == 0) {
                    LongVideoAdapter.Item titleItem = new LongVideoAdapter.Item();
                    titleItem.type = LongVideoAdapter.Item.TYPE_GROUP_TITLE;
                    titleItem.title = config.title;
                    items.add(titleItem);
                }
            }

            if (config.type == GroupConfig.TYPE_COUNT) {

                if (config.count == -1) {
                    while (index < videoItems.size()) {
                        LongVideoAdapter.Item item = new LongVideoAdapter.Item();
                        item.type = LongVideoAdapter.Item.TYPE_VIDEO_ITEM;
                        item.videoItem = videoItems.get(index);
                        items.add(item);
                        index++;
                        config.index++;
                    }
                } else {
                    for (int i = 0; i < config.count && index < videoItems.size(); i++) {
                        LongVideoAdapter.Item item = new LongVideoAdapter.Item();
                        item.type = LongVideoAdapter.Item.TYPE_VIDEO_ITEM;
                        item.videoItem = videoItems.get(index);
                        items.add(item);
                        index++;
                        config.index++;
                    }
                }
            } else if (config.type == GroupConfig.TYPE_IDS) {

                for (VideoItem videoItem : videoItems) {
                    if (config.ids.contains(videoItem.getVid())) {
                        LongVideoAdapter.Item item = new LongVideoAdapter.Item();
                        item.type = LongVideoAdapter.Item.TYPE_VIDEO_ITEM;
                        item.videoItem = videoItem;
                        items.add(item);
                    }
                }
            } else if (config.type == GroupConfig.TYPE_PAGER) {
                LongVideoAdapter.Item header = new LongVideoAdapter.Item();
                header.videoItems = new ArrayList<>();
                header.type = LongVideoAdapter.Item.TYPE_HEADER_BANNER;
                for (int i = 0; i < Math.min(videoItems.size(), config.count); i++) {
                    header.videoItems.add(videoItems.get(i));
                    index++;
                    config.index++;
                }
                items.add(header);
            }
        }
        return items;
    }

    void append(LongVideoAdapter adapter, List<VideoItem> videoItems) {
        List<LongVideoAdapter.Item> items = createItems(videoItems);
        adapter.appendItems(items);
    }

    private final List<GroupConfig> groupConfigs = new ArrayList<>();

    LongVideoDataTrans(Context context) {
        GroupConfig headerConfig = new GroupConfig();
        headerConfig.type = GroupConfig.TYPE_PAGER;
        headerConfig.count = 4;

        GroupConfig groupConfig1 = new GroupConfig();
        groupConfig1.type = GroupConfig.TYPE_COUNT;
        groupConfig1.title = context.getString(R.string.vevod_long_video_title_hot_shows);
        groupConfig1.count = 4;

        GroupConfig groupConfig2 = new GroupConfig();
        groupConfig2.type = GroupConfig.TYPE_COUNT;
        groupConfig2.count = 4;
        groupConfig2.title = context.getString(R.string.vevod_long_video_title_today_recommend);

        GroupConfig groupConfig5 = new GroupConfig();
        groupConfig5.type = GroupConfig.TYPE_COUNT;
        groupConfig5.title = context.getString(R.string.vevod_long_video_title_recommend_for_you);
        groupConfig5.count = Integer.MAX_VALUE;

        groupConfigs.addAll(Arrays.asList(headerConfig, groupConfig1, groupConfig2, groupConfig5));
    }

    static class GroupConfig {
        final static int TYPE_COUNT = 0;
        final static int TYPE_IDS = 1;
        final static int TYPE_PAGER = 2;

        int type;
        int count;
        List<String> ids = new ArrayList<>();
        String title;

        int index;

        boolean isDone() {
            return index + 1 >= count;
        }
    }
}
