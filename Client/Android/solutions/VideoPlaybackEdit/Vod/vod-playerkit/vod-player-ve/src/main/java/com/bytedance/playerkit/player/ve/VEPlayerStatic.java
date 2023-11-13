// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.playerkit.player.ve;

import android.view.Surface;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.playerkit.utils.L;
import com.pandora.common.env.Env;
import com.ss.ttvideoengine.debugtool2.DebugTool;
import com.ss.ttvideoengine.strategy.StrategyManager;
import com.ss.ttvideoengine.strategy.StrategySettings;

import org.json.JSONObject;

import java.util.List;

public class VEPlayerStatic {

    private static int CurrentScene = SceneFeed.SCENE_UNKNOWN;
    private static boolean SceneStrategyEnabled = false;

    public synchronized static void setSceneStrategyEnabled(int veScene, boolean enabled) {
        L.d(VEPlayerStatic.class, "setSceneStrategyEnabled", SceneFeed.mapScene(veScene), enabled);
        if (CurrentScene != veScene) {
            if (SceneStrategyEnabled) {
                VEPlayer.clearSceneStrategy();
                SceneStrategyEnabled = false;
            }
        }
        CurrentScene = veScene;
        if (SceneStrategyEnabled != enabled) {
            SceneStrategyEnabled = enabled;
            if (enabled) {
                VEPlayer.setSceneStrategyEnabled(veScene);
            } else {
                VEPlayer.clearSceneStrategy();
            }
        }
    }

    public static void setMediaSources(List<MediaSource> mediaSources) {
        VEPlayer.setMediaSources(mediaSources);
    }

    public static void addMediaSources(List<MediaSource> mediaSources) {
        VEPlayer.addMediaSources(mediaSources);
    }

    public static void renderFrame(MediaSource mediaSource, Surface surface, int[] frameInfo) {
        VEPlayer.renderFrame(mediaSource, surface, frameInfo);
    }

    public static String getDeviceId() {
        return VEPlayer.getDeviceId();
    }

    public static String getSDKVersion() {
        return Env.getVersion();
    }

    @Nullable
    public static JSONObject getPreloadConfig(int scene) {
        switch (scene) {
            case SceneFeed.SCENE_SHORT_VIDEO: // Short
                return StrategySettings.getInstance().getPreload(StrategyManager.STRATEGY_SCENE_SMALL_VIDEO);
            case SceneFeed.SCENE_FEED_VIDEO: // Feed
                return StrategySettings.getInstance().getPreload(StrategyManager.STRATEGY_SCENE_SHORT_VIDEO);
        }
        return null;
    }
    public static void setDebugToolContainerView(ViewGroup containerView) {
        DebugTool.release();
        DebugTool.setContainerView(containerView);
    }
    public static void releaseDebugTool() {
        DebugTool.release();
    }
}
