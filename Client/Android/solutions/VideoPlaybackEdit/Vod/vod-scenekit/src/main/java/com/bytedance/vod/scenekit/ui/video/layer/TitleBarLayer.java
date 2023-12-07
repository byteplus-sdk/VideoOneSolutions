// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.vod.scenekit.ui.video.layer;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.bytedance.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.bytedance.vod.scenekit.utils.UIUtils;


public class TitleBarLayer extends AnimateLayer {
    private TextView mTitle;
    private View mTitleBar;

    private View mMore;

    private final int[] showInScenes;

    @Override
    public String tag() {
        return "title_bar";
    }

    public TitleBarLayer() {
        this(PlayScene.SCENE_UNKNOWN, PlayScene.SCENE_DETAIL, PlayScene.SCENE_FULLSCREEN);
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
            if (playScene() != PlayScene.SCENE_FULLSCREEN) {
                Toast.makeText(context(), "More is only supported in fullscreen for now!",
                        Toast.LENGTH_SHORT).show();
                return;
            }
            MoreDialogLayer layer = findLayer(MoreDialogLayer.class);
            if (layer != null) {
                layer.animateShow(false);
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
        if (playScene() == PlayScene.SCENE_FULLSCREEN) {
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
    }

    private void applyHalfScreenTheme() {
        setTitleBarHorizontalMargin(0);
        if (mTitle != null) {
            mTitle.setVisibility(View.GONE);
        }
        if (mMore != null) {
            mMore.setVisibility(View.GONE);
        }
    }

    private void setTitleBarHorizontalMargin(int margin) {
        if (mTitleBar == null) return;

        ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) mTitleBar.getLayoutParams();
        params.leftMargin = params.rightMargin = (int) UIUtils.dip2Px(context(), margin);
        mTitleBar.setLayoutParams(params);
    }
}
