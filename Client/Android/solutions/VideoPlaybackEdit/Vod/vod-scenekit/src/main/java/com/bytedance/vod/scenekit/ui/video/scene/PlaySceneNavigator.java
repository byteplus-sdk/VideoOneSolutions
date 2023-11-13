// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.scene;


import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.playback.DisplayModeHelper;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.vod.scenekit.utils.UIUtils;
import com.bytedance.vod.scenekit.utils.ViewUtils;

public class PlaySceneNavigator {

    private static final String TAG = "PlaySceneNavigator";

    public static void navigateTo(VideoView videoView, PlaySceneInfo playSceneInfo) {
        ViewUtils.removeFromParent(videoView);
        playSceneInfo.container.addView(videoView, playSceneInfo.lp);
        videoView.setRatio(playSceneInfo.ratio);
        videoView.setRatioMode(playSceneInfo.ratioMode);
        videoView.setDisplayMode(playSceneInfo.displayMode);
        videoView.setPlayScene(playSceneInfo.videoScene);
        setSystemBarTheme(videoView, playSceneInfo);
        videoView.post(videoView::requestLayout);
    }

    public static void setSystemBarTheme(VideoView videoView, PlaySceneInfo playSceneInfo) {
        final Activity activity = (Activity) videoView.getContext();
        final View decorView = activity.getWindow().getDecorView();
        decorView.setSystemUiVisibility(playSceneInfo.systemUiVisibility);

        if (playSceneInfo.windowLp != null) {
            activity.getWindow().setAttributes(playSceneInfo.windowLp);
        }
    }

    public static class PlaySceneInfo {
        private final WindowManager.LayoutParams windowLp;
        private final ViewGroup container;
        private final ViewGroup.LayoutParams lp;
        @DisplayModeHelper.DisplayMode
        private final int displayMode;
        private final float ratio;
        private final int ratioMode;
        private final int systemUiVisibility;
        private final int videoScene;

        @Nullable
        public static PlaySceneInfo current(VideoView videoView) {
            Context context = videoView.getContext();
            if (!(context instanceof Activity)) return null;

            final Activity activity = (Activity) videoView.getContext();
            final View decorView = activity.getWindow().getDecorView();
            return new PlaySceneInfo(
                    videoView.getPlayScene(),
                    UIUtils.getWindowLayoutParams(videoView),
                    (ViewGroup) videoView.getParent(),
                    videoView.getLayoutParams(),
                    videoView.getDisplayMode(),
                    videoView.getRatio(),
                    videoView.getRatioMode(),
                    decorView.getSystemUiVisibility()
            );
        }

        public static PlaySceneInfo target(int videoScene, FrameLayout container, VideoView videoView, int systemUiVisibility) {
            FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) videoView.getLayoutParams();
            FrameLayout.LayoutParams copy = new FrameLayout.LayoutParams(layoutParams.width, layoutParams.height, layoutParams.gravity);
            return target(videoScene, container, copy, videoView.getDisplayMode(), videoView.getRatio(), videoView.getRatioMode(), systemUiVisibility);
        }

        public static PlaySceneInfo target(int videoScene, FrameLayout container, FrameLayout.LayoutParams layoutParams, int displayMode, float ratio, int ratioMode, int systemUiVisibility) {
            return new PlaySceneInfo(
                    videoScene,
                    UIUtils.getWindowLayoutParams(container),
                    container,
                    layoutParams,
                    displayMode,
                    ratio,
                    ratioMode,
                    systemUiVisibility
            );
        }

        public static PlaySceneInfo target(int videoScene, WindowManager.LayoutParams windowLp, FrameLayout container, FrameLayout.LayoutParams layoutParams, int displayMode, float ratio, int ratioMode, int systemUiVisibility) {
            return new PlaySceneInfo(
                    videoScene,
                    windowLp,
                    container,
                    layoutParams,
                    displayMode,
                    ratio,
                    ratioMode,
                    systemUiVisibility
            );
        }

        private PlaySceneInfo(int videoScene, WindowManager.LayoutParams windowLp, ViewGroup container, ViewGroup.LayoutParams lp, int displayMode, float ratio, int ratioMode, int systemUiVisibility) {
            this.videoScene = videoScene;
            this.windowLp = windowLp;
            this.container = container;
            this.lp = lp;
            this.displayMode = displayMode;
            this.ratio = ratio;
            this.ratioMode = ratioMode;
            this.systemUiVisibility = systemUiVisibility;
        }

        @Override
        public String toString() {
            return "PlaySceneInfo{" +
                    "windowLp=" + windowLp +
                    ", container=" + container +
                    ", lp=" + lp +
                    ", displayMode=" + displayMode +
                    ", ratio=" + ratio +
                    ", ratioMode=" + ratioMode +
                    ", systemUiVisibility=" + systemUiVisibility +
                    ", videoScene=" + videoScene +
                    '}';
        }
    }
}
