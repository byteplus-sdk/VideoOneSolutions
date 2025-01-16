// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.input.media;

import android.app.Activity;
import android.content.ActivityNotFoundException;
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
import com.byteplus.vod.scenekit.ui.video.scene.feedvideo.IFeedVideoStrategyConfig;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.util.ArrayList;

public class SampleFeedVideoActivity extends BaseActivity implements FeedVideoPageView.DetailPageNavigator {
    private static final String ACTION_VIDEO_DETAILS = "com.byteplus.vod.scenekit.action.VIDEO_DETAILS";

    private static final String EXTRA_VIDEO_SCENE = "extra_video_scene";
    private static final String EXTRA_ARGS = "extra_args";
    public static final String EXTRA_VIDEO_ITEMS = "extra_video_items";

    public static final String EXTRA_MEDIA_SOURCE = "extra_media_source";
    public static final String EXTRA_CONTINUES_PLAYBACK = "extra_continues_playback";

    public static void intentInto(Activity activity, ArrayList<VideoItem> videoItems) {
        Intent intent = new Intent(activity, SampleFeedVideoActivity.class);
        intent.putExtra(EXTRA_VIDEO_ITEMS, videoItems);
        activity.startActivity(intent);
    }

    private FeedVideoSceneView mSceneView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        ArrayList<VideoItem> videoItems = (ArrayList<VideoItem>) intent.getSerializableExtra(EXTRA_VIDEO_ITEMS);

        mSceneView = new FeedVideoSceneView(this, new NoMiniPlayerStrategyConfig());
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

        Bundle args = new Bundle();
        args.putSerializable(EXTRA_MEDIA_SOURCE, source);
        args.putBoolean(EXTRA_CONTINUES_PLAYBACK, continuesPlayback);

        Intent intent = new Intent(ACTION_VIDEO_DETAILS);
        intent.putExtra(EXTRA_VIDEO_SCENE, PlayScene.SCENE_DETAIL);
        intent.putExtra(EXTRA_ARGS, args);
        intent.setPackage(getPackageName());
        try {
            startActivity(intent);
        } catch (ActivityNotFoundException ignored) {

        }
    }

    static class NoMiniPlayerStrategyConfig implements IFeedVideoStrategyConfig {
        @Override
        public boolean miniPlayerEnabled() {
            return false;
        }
    }
}
