// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.input.media;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;

import com.byteplus.vod.input.media.views.SampleShortVideoPageView;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.utils.UIUtils;

import java.util.ArrayList;

public class SampleShortVideoActivity extends BaseActivity {

    public static final String EXTRA_VIDEO_ITEMS = "extra_video_items";

    public static void intentInto(Activity activity, ArrayList<VideoItem> videoItems) {
        Intent intent = new Intent(activity, SampleShortVideoActivity.class);
        intent.putExtra(EXTRA_VIDEO_ITEMS, videoItems);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        ArrayList<VideoItem> videoItems = (ArrayList<VideoItem>) intent.getSerializableExtra(EXTRA_VIDEO_ITEMS);

        SampleShortVideoPageView pageView = new SampleShortVideoPageView(this);

        pageView.setLifeCycle(getLifecycle());
        pageView.setItems(videoItems);
        setContentView(pageView);

        UIUtils.setSystemBarTheme(
                this,
                Color.TRANSPARENT,
                false,
                true,
                Color.BLACK,
                false,
                false
        );
    }
}
