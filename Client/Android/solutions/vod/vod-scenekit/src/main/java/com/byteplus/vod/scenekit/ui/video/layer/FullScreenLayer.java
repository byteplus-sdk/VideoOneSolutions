// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.os.Build;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.PlaybackEvent;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.ui.video.scene.PlaySceneNavigator;
import com.byteplus.vod.scenekit.utils.OrientationHelper;
import com.byteplus.vod.scenekit.utils.UIUtils;

public class FullScreenLayer extends BaseLayer implements VideoLayerHost.BackPressedHandler {

    private PlaySceneNavigator.PlaySceneInfo mSceneInfo;
    private PlaySceneNavigator.PlaySceneInfo mFullScreenSceneInfo;
    private boolean mFullScreen;

    private OrientationHelper mOrientationHelper;

    private Lifecycle mLifeCycle;

    private boolean mEnableToggleFullScreenBySensor = true;

    private OnBackPressedCallback mBackPressedCallback;

    public static boolean isFullScreen(VideoView videoView) {
        FullScreenLayer fullScreenLayer = fullScreenLayer(videoView);
        if (fullScreenLayer != null) {
            return fullScreenLayer.isFullScreen();
        }
        return false;
    }

    public static void enterFullScreen(VideoView videoView) {
        FullScreenLayer fullScreenLayer = fullScreenLayer(videoView);
        if (fullScreenLayer != null) {
            fullScreenLayer.enterFullScreen(true);
        }
    }

    public static void exitFullScreen(VideoView videoView) {
        FullScreenLayer fullScreenLayer = fullScreenLayer(videoView);
        if (fullScreenLayer != null) {
            fullScreenLayer.exitFullScreen(true);
        }
    }

    public static void toggle(VideoView videoView, boolean changeOrientation) {
        FullScreenLayer fullScreenLayer = fullScreenLayer(videoView);
        if (fullScreenLayer != null) {
            fullScreenLayer.toggle(changeOrientation);
        }
    }

    @Nullable
    public static FullScreenLayer fullScreenLayer(VideoView videoView) {
        if (videoView != null) {
            VideoLayerHost layerHost = videoView.layerHost();
            if (layerHost != null) {
                return layerHost.findLayer(FullScreenLayer.class);
            }
        }
        return null;
    }

    public boolean isEnableToggleFullScreenBySensor() {
        return mEnableToggleFullScreenBySensor;
    }

    public void setEnableToggleFullScreenBySensor(boolean enableToggleFullScreenBySensor) {
        this.mEnableToggleFullScreenBySensor = enableToggleFullScreenBySensor;
    }

    @Override
    public String tag() {
        return "fullscreen";
    }

    @Override
    public boolean onBackPressed() {
        if (isFullScreen()) {
            exitFullScreen(true);
            return true;
        }
        return false;
    }

    @Override
    protected void onBindVideoView(@NonNull VideoView videoView) {
        if (mOrientationHelper == null) {
            mOrientationHelper = new OrientationHelper(activity(), (last, current) -> {
                final Context context = context();
                if (context == null) return;
                if (!mOrientationHelper.isEnabled()) return;

                L.v(mOrientationHelper, "orientationChanged", current);

                boolean enableAutoToggleFullScreen = mEnableToggleFullScreenBySensor
                        && OrientationHelper.isSystemAutoOrientationEnabled(context);

                switch (current) {
                    case OrientationHelper.ORIENTATION_0:
                        if (enableAutoToggleFullScreen
                                && player() != null
                                && !isLocked()) {
                            exitFullScreen();
                            if (!isFullScreen()) {
                                setRequestOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                            }
                        }
                        break;
                    case OrientationHelper.ORIENTATION_90:
                        if (enableAutoToggleFullScreen
                                && player() != null) {
                            enterFullScreen();
                        }
                        if (isFullScreen()) {
                            setRequestOrientation(ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE);
                        }
                        break;
                    case OrientationHelper.ORIENTATION_270:
                        if (enableAutoToggleFullScreen
                                && player() != null) {
                            enterFullScreen();
                        }
                        if (isFullScreen()) {
                            setRequestOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                        }
                        break;
                }
            });
            Context context = videoView.getContext();
            if (context instanceof FragmentActivity && getBackPressedCallback() != null) {
                ((FragmentActivity) context)
                        .getOnBackPressedDispatcher()
                        .addCallback((LifecycleOwner) videoView.getContext(), getBackPressedCallback());
            }
        }

        if (videoView.getContext() instanceof LifecycleOwner) {
            Lifecycle lifecycle = ((LifecycleOwner) videoView.getContext()).getLifecycle();
            if (lifecycle != null) {
                bindLifeCycle(lifecycle);
            }
        }
    }

    @Override
    protected void onUnBindVideoView(@NonNull VideoView videoView) {
        mOrientationHelper.disable();
        unBindLifeCycle();
        if (getBackPressedCallback() != null) {
            getBackPressedCallback().remove();
        }
    }

    private void bindLifeCycle(@NonNull Lifecycle lifecycle) {
        if (lifecycle != mLifeCycle) {
            if (mLifeCycle != null) {
                mLifeCycle.removeObserver(mLifecycleObserver);
            }
            mLifeCycle = lifecycle;
            mLifeCycle.addObserver(mLifecycleObserver);
        }
    }

    private void unBindLifeCycle() {
        if (mLifeCycle != null) {
            mLifeCycle.removeObserver(mLifecycleObserver);
            mLifeCycle = null;
        }
    }

    private final LifecycleObserver mLifecycleObserver = new LifecycleEventObserver() {
        @Override
        public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
            switch (event) {
                case ON_RESUME: {
                    VideoView videoView = videoView();
                    if (videoView == null) return;
                    if (!isFullScreen()) return;
                    if (mFullScreenSceneInfo == null) return;
                    PlaySceneNavigator.setSystemBarTheme(videoView, mFullScreenSceneInfo);
                    break;
                }
            }
        }
    };

    @Override
    protected void onBindLayerHost(@NonNull VideoLayerHost layerHost) {
        layerHost.registerBackPressedHandler(this, 0);
    }

    @Override
    protected void onUnbindLayerHost(@NonNull VideoLayerHost layerHost) {
        layerHost.unregisterBackPressedHandler(this);

    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    private final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {

        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlaybackEvent.Action.START_PLAYBACK:
                    enableOrientation();
                    break;

                case PlaybackEvent.Action.STOP_PLAYBACK:
                    disableOrientation();
                    break;
            }
        }
    };

    private void enableOrientation() {
        if (mOrientationHelper != null) {
            mOrientationHelper.enable();
        }
    }

    private void disableOrientation() {
        if (mOrientationHelper != null) {
            mOrientationHelper.disable();
        }
    }

    public void toggle(boolean changeOrientation) {
        if (isFullScreen()) {
            exitFullScreen(changeOrientation);
        } else {
            enterFullScreen(changeOrientation);
        }
    }

    public void enterFullScreen(boolean changeOrientation) {
        FragmentActivity activity = activity();
        if (activity == null) return;

        enterFullScreen();

        if (changeOrientation) {
            final int targetOrientation;
            if (mOrientationHelper != null
                    && mOrientationHelper.isEnabled()
                    && mOrientationHelper.getOrientation() == OrientationHelper.ORIENTATION_90) {
                targetOrientation = ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
            } else {
                targetOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            }
            setRequestOrientation(targetOrientation);
        }
    }

    public void exitFullScreen(boolean changeOrientation) {
        exitFullScreen();
        if (changeOrientation) {
            setRequestOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    public boolean isFullScreen() {
        final VideoView videoView = videoView();
        if (videoView == null) return false;

        final ViewGroup parent = (ViewGroup) videoView.getParent();
        if (parent == null) return false;

        return parent.getId() == android.R.id.content &&
                mFullScreen && PlayScene.isFullScreenMode(playScene());
    }

    protected void afterExitFullScreen() {

    }

    protected OnBackPressedCallback getBackPressedCallback() {
        if (mBackPressedCallback == null) {
            mBackPressedCallback = new OnBackPressedCallback(false) {
                @Override
                public void handleOnBackPressed() {
                    exitFullScreen(true);
                }
            };
        }
        return mBackPressedCallback;
    }

    private void exitFullScreen() {
        if (!isFullScreen()) return;

        final FragmentActivity activity = activity();
        if (activity == null) return;

        final VideoView videoView = videoView();
        if (videoView == null) return;

        if (mSceneInfo == null) return;

        L.d(this, "exitFullScreen");
        if (getBackPressedCallback() != null) {
            getBackPressedCallback().setEnabled(false);
        }

        VideoLayerHost host = layerHost();
        if (host != null) {
            host.setLocked(false);
        }

        PlaySceneNavigator.navigateTo(videoView, mSceneInfo);
        activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

        mFullScreen = false;

        afterExitFullScreen();
    }

    private void enterFullScreen() {
        if (isFullScreen()) return;

        final FragmentActivity activity = activity();
        if (activity == null) return;

        final VideoView videoView = videoView();
        if (videoView == null) return;

        final ViewGroup parent = (ViewGroup) videoView.getParent();
        if (parent == null) return;

        L.d(this, "enterFullScreen");
        if (getBackPressedCallback() != null) {
            getBackPressedCallback().setEnabled(true);
        }

        mSceneInfo = PlaySceneNavigator.PlaySceneInfo.current(videoView);

        if (mFullScreenSceneInfo == null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                if (UIUtils.hasDisplayCutout(activity.getWindow())) {
                    activity.getWindow().getAttributes().layoutInDisplayCutoutMode =
                            WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
                }
            }
            mFullScreenSceneInfo = PlaySceneNavigator.PlaySceneInfo.target(
                    PlayScene.SCENE_FULLSCREEN,
                    activity.findViewById(android.R.id.content),
                    new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, Gravity.CENTER),
                    DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT,
                    -1,
                    videoView.getRatioMode(),
                    getUiOptions(activity)
            );
        }
        PlaySceneNavigator.navigateTo(videoView, mFullScreenSceneInfo);

        activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        mFullScreen = true;
    }

    private int getUiOptions(Activity activity) {
        final View decorView = activity.getWindow().getDecorView();

        int uiOptions = decorView.getSystemUiVisibility();
        uiOptions |= View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                // Set the content to appear under the system bars so that the
                // content doesn't resize when the system bars hide and show.
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                // Hide the nav bar and status bar
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN;

        return uiOptions;
    }

    private void setRequestOrientation(int targetOrientation) {
        final Activity activity = activity();
        if (activity == null || activity.isFinishing()) return;

        if (activity.getRequestedOrientation() != targetOrientation) {
            L.v(this, "setRequestOrientation", targetOrientation);
            activity.runOnUiThread(() ->
                    activity.setRequestedOrientation(targetOrientation)
            );
        }
    }

    private float calVideoRatio() {
        float ratio = 16 / 9f;
        final Player player = player();
        if (player != null) {
            int width = player.getVideoWidth();
            int height = player.getVideoHeight();
            if (width > 0 && height > 0) {
                ratio = width / (float) height;
            }
        }
        return ratio;
    }
}
