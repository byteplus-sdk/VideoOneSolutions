// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.os.Build;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vodcast.api.CastSdk;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.CastingDeviceSearchDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.helper.MiniPlayerHelper;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.utils.UIUtils;
import com.byteplus.vod.settingskit.CenteredToast;

public class TitleBarLayer extends AnimateLayer implements GestureControllable {
    private TextView mTitle;
    private View mTitleBar;

    private View mMore;

    private View mCasting;

    private ImageView mMiniPlayer;

    private final int[] showInScenes;

    private boolean enableCasting = false;

    @Override
    public String tag() {
        return "title_bar";
    }

    public TitleBarLayer() {
        this(PlayScene.SCENE_NONE, PlayScene.SCENE_DETAIL, PlayScene.SCENE_FULLSCREEN, PlayScene.SCENE_SINGLE_FUNCTION);
    }

    public TitleBarLayer(int... scenes) {
        showInScenes = scenes;
    }

    public void enableCasting(boolean enableCasting) {
        this.enableCasting = enableCasting;
        if (mCasting == null) {
            return;
        }
        // B10: 不再要求全屏才显示，按 enableCasting 决定
        mCasting.setVisibility(enableCasting ? View.VISIBLE : View.GONE);
    }


    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_title_bar_layer, parent, false);
        View back = view.findViewById(R.id.back);
        back.setOnClickListener(v -> {
            Activity activity = activity();
            if (activity != null) {
                activity.onBackPressed();
            }
        });

        mTitle = view.findViewById(R.id.title);
        mTitleBar = view.findViewById(R.id.titleBar);

        mMore = view.findViewById(R.id.more);
        mMore.setOnClickListener(v -> {
            if (!isFullScreen()) {
                Toast.makeText(context(), "More is only supported in fullscreen for now!",
                        Toast.LENGTH_SHORT).show();
                return;
            }
            MoreDialogLayer layer = findLayer(MoreDialogLayer.class);
            if (layer != null) {
                layer.animateShow(false);
            }
        });

        mCasting = view.findViewById(R.id.casting);
        mCasting.setOnClickListener(v -> {
            boolean fullScreen = isFullScreen();
            Log.d("CAST_DEMO", "Click casting button,fullScreen mode = " + fullScreen);
            // 入口预检 1 —— 投屏是否可用（已注册 + Google Play Services 可用 + impl 已 install）
            if (!CastSdk.isAvailable()) {
                Log.w("CAST_DEMO", "CastSdk unavailable, ignore casting click");
                CenteredToast.show(v.getContext(), "当前设备不支持投屏");
                return;
            }
            // 入口预检 2 —— 当前是否有可用网络（API 21+）
            if (!hasInternet(v.getContext())) {
                CenteredToast.show(v.getContext(), "无网络，请检查网络连接");
                return;
            }
            // 非全屏也允许打开设备搜索弹窗
            CastingDeviceSearchDialogLayer layer = findLayer(CastingDeviceSearchDialogLayer.class);
            if (layer != null) {
                layer.animateShow(false);
            }
        });
        mCasting.setVisibility(enableCasting ? View.VISIBLE : View.GONE);

        mMiniPlayer = view.findViewById(R.id.miniplayer);
        mMiniPlayer.setOnClickListener(v -> {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                CenteredToast.show(v.getContext(), "OS's version is low, does not support PIP");
                return;
            }
            boolean newValue = !v.isSelected();
            if (newValue && !MiniPlayerHelper.get().hasMiniPlayerPermission(v.getContext())) {
                CenteredToast.show(v.getContext(), R.string.vevod_miniplayer_permission_denied);
                return;
            }
            mMiniPlayer.setSelected(newValue);
            VideoSettings.option(VideoSettings.COMMON_IS_MINIPLAYER_ON).saveUserValue(newValue);
            if (newValue) {
                CenteredToast.show(v.getContext(), R.string.vevod_miniplayer_open_success);
            }
        });
        return view;
    }

    private boolean isFullScreen() {
        return PlayScene.isFullScreenMode(playScene());
    }

    /**
     * 判断当前是否存在可联网的网络。优先使用 API 23+ 的 NetworkCapabilities；
     * 在更老的设备上退化为 ConnectivityManager#getActiveNetworkInfo（已 deprecated 但仍可用）。
     */
    private boolean hasInternet(Context ctx) {
        if (ctx == null) return true; // 上下文异常时不阻塞用户
        ConnectivityManager cm = ContextCompat.getSystemService(ctx, ConnectivityManager.class);
        if (cm == null) return true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Network active = cm.getActiveNetwork();
            if (active == null) return false;
            NetworkCapabilities caps = cm.getNetworkCapabilities(active);
            return caps != null && caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET);
        } else {
            return cm.getActiveNetworkInfo() != null && cm.getActiveNetworkInfo().isConnected();
        }
    }

    @Override
    public void show() {
        if (!checkShow()) {
            return;
        }
        super.show();
        mTitle.setText(resolveTitle());
        applyTheme();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!checkShow()) {
            dismiss();
        } else {
            applyTheme();
        }
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        if (isInPictureInPictureMode) {
            dismiss();
        } else {
            show();
        }
    }

    protected boolean checkShow() {
        int scene = playScene();
        for (int showInScene : showInScenes) {
            if (scene == showInScene) {
                return true;
            }
        }

        return false;
    }

    @Override
    protected boolean preventAnimateDismiss() {
        final Player player = player();
        return player != null && player.isPaused();
    }

    protected String resolveTitle() {
        VideoView videoView = videoView();
        if (videoView == null) {
            return null;
        }
        MediaSource mediaSource = videoView.getDataSource();
        if (mediaSource == null) {
            return null;
        }
        VideoItem videoItem = VideoItem.get(mediaSource);
        if (videoItem != null) {
            return videoItem.getTitle();
        }
        return null;
    }

    public void refreshTitle() {
        mTitle.setText(resolveTitle());
    }

    private void applyTheme() {
        if (isFullScreen()) {
            applyFullScreenTheme();
        } else if (playScene() == PlayScene.SCENE_DETAIL) {
            applyHalfScreenTheme();
        } else {
            applyHalfScreenTheme();
        }
    }

    private void applyFullScreenTheme() {
        setTitleBarHorizontalMargin(44);
        if (mTitle != null) {
            mTitle.setVisibility(View.VISIBLE);
        }

        if (mCasting != null) {
            mCasting.setVisibility(enableCasting ? View.VISIBLE : View.GONE);
        }

        if (mMore != null) {
            mMore.setVisibility(View.VISIBLE);
        }
        if (mMiniPlayer != null) {
            mMiniPlayer.setVisibility(View.GONE);
        }
    }

    private void applyHalfScreenTheme() {
        setTitleBarHorizontalMargin(0);
        if (mTitle != null) {
            mTitle.setVisibility(View.INVISIBLE);
        }
        if (mMore != null) {
            mMore.setVisibility(View.GONE);
        }
        if (mCasting != null) {
            // Casting is only supported in fullscreen (landscape); hide the entry on half-screen.
            mCasting.setVisibility(View.GONE);
        }
        if (mMiniPlayer != null) {
            MiniPlayerLayer miniPlayerLayer = findLayer(MiniPlayerLayer.class);
            if (miniPlayerLayer == null) {
                mMiniPlayer.setVisibility(View.GONE);
            } else {
                mMiniPlayer.setVisibility(View.VISIBLE);
                mMiniPlayer.setSelected(MiniPlayerHelper.get().isMiniPlayerOn());
            }
        }
    }

    private void setTitleBarHorizontalMargin(int margin) {
        if (mTitleBar == null) return;

        ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) mTitleBar.getLayoutParams();
        params.leftMargin = params.rightMargin = (int) UIUtils.dip2Px(context(), margin);
        mTitleBar.setLayoutParams(params);
    }
}
