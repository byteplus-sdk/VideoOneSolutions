// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.app.Activity;
import android.content.res.Configuration;
import android.os.Build;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer;
import com.byteplus.vod.scenekit.ui.video.layer.helper.MiniPlayerHelper;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.utils.UIUtils;
import com.byteplus.vod.settingskit.CenteredToast;


public class TitleBarLayer extends AnimateLayer {
    private TextView mTitle;
    private View mTitleBar;

    private View mMore;

    private ImageView mMiniPlayer;

    private final int[] showInScenes;

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
            if (!PlayScene.isFullScreenMode(playScene())) {
                Toast.makeText(context(), "More is only supported in fullscreen for now!",
                        Toast.LENGTH_SHORT).show();
                return;
            }
            MoreDialogLayer layer = findLayer(MoreDialogLayer.class);
            if (layer != null) {
                layer.animateShow(false);
            }
        });

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

    private String resolveTitle() {
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

    private void applyTheme() {
        if (PlayScene.isFullScreenMode(playScene())) {
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
