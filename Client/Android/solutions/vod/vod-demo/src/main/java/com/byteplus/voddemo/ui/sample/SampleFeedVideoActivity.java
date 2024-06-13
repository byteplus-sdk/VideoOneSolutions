// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.voddemo.ui.sample;


import static com.byteplus.vod.scenekit.ui.video.scene.PlayScene.SCENE_DETAIL;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;

import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoPageView;
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.FeedVideoSceneView;
import com.byteplus.voddemo.ui.video.scene.VideoActivity;

import java.util.ArrayList;

public class SampleFeedVideoActivity extends BaseActivity implements FeedVideoPageView.DetailPageNavigator {

    public static final String EXTRA_VIDEO_ITEMS = "extra_video_items";

    public static void intentInto(Activity activity, ArrayList<VideoItem> videoItems) {
        Intent intent = new Intent(activity, SampleFeedVideoActivity.class);
        intent.putExtra(EXTRA_VIDEO_ITEMS, videoItems);
        activity.startActivity(intent);
    }

    private FeedVideoSceneView mSceneView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ArrayList<VideoItem> videoItems = (ArrayList<VideoItem>) getIntent().getSerializableExtra(EXTRA_VIDEO_ITEMS);

        mSceneView = new FeedVideoSceneView(this);
        mSceneView.setRefreshEnabled(false);
        mSceneView.setLoadMoreEnabled(false);

        mSceneView.pageView().setLifeCycle(getLifecycle());
        mSceneView.pageView().setItems(videoItems);
        mSceneView.setBackgroundColor(Color.LTGRAY);
        mSceneView.setDetailPageNavigator(this);
        setContentView(mSceneView);
    }

    @Override
    public void onBackPressed() {
        if (mSceneView.onBackPressed()) {
            return;
        }
        super.onBackPressed();
    }

    @Override
    public void enterDetail(FeedVideoViewHolder holder) {
        final VideoView videoView = holder.getSharedVideoView();
        if (videoView == null) return;

        final MediaSource source = videoView.getDataSource();
        if (source == null) return;

        final PlaybackController controller = videoView.controller();

        boolean continuesPlayback = false;
        if (controller != null) {
            continuesPlayback = controller.player() != null;
            controller.unbindPlayer();
        }
        final Bundle bundle = SampleDetailVideoFragment.createBundle(source, continuesPlayback);
        VideoActivity.intentInto(this, SCENE_DETAIL, bundle);
    }
}
