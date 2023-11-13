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

import com.bytedance.playerkit.player.playback.VideoLayerHost;
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

    @Override
    public String tag() {
        return "title_bar";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_title_bar_layer, parent, false);
        View back = view.findViewById(R.id.back);
        View search = view.findViewById(R.id.search);
        View cast = view.findViewById(R.id.cast);
        View more = view.findViewById(R.id.more);
        mMore = more;

        mTitle = view.findViewById(R.id.title);
        mTitleBar = view.findViewById(R.id.titleBar);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Activity activity = activity();
                if (activity != null) {
                    activity.onBackPressed();
                }
            }
        });

        search.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(activity(), "Search is not supported yet!", Toast.LENGTH_SHORT).show();
            }
        });

        cast.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(activity(), "Cast is not supported yet!", Toast.LENGTH_SHORT).show();
            }
        });

        more.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (playScene() != PlayScene.SCENE_FULLSCREEN) {
                    Toast.makeText(context(), "More is only supported in fullscreen for now!",
                            Toast.LENGTH_SHORT).show();
                    return;
                }
                VideoLayerHost layerHost = layerHost();
                if (layerHost == null) return;
                MoreDialogLayer layer = layerHost.findLayer(MoreDialogLayer.class);
                if (layer != null) {
                    layer.animateShow(false);
                }
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
        applyTheme();
        if (!checkShow()) {
            dismiss();
        }
    }

    private boolean checkShow() {
        switch (playScene()) {
            case PlayScene.SCENE_FULLSCREEN:
            case PlayScene.SCENE_DETAIL:
            case PlayScene.SCENE_UNKNOWN:
                return true;
            default:
                return false;
        }
    }

    private String resolveTitle() {
        VideoView videoView = videoView();
        if (videoView != null) {
            MediaSource mediaSource = videoView.getDataSource();
            if (mediaSource != null) {
                VideoItem videoItem = VideoItem.get(mediaSource);
                if (videoItem != null) {
                    return videoItem.getTitle();
                }
            }
        }
        return null;
    }

    public void applyTheme() {
        if (playScene() == PlayScene.SCENE_FULLSCREEN) {
            applyFullScreenTheme();
        } else {
            applyHalfScreenTheme();
        }
    }

    private void applyFullScreenTheme() {
        setTitleBarLeftRightMargin(44);
        if (mTitle != null) {
            mTitle.setVisibility(View.VISIBLE);
        }

        if (mMore != null) {
            mMore.setVisibility(View.VISIBLE);
        }
    }

    private void applyHalfScreenTheme() {
        setTitleBarLeftRightMargin(0);
        if (mTitle != null) {
            mTitle.setVisibility(View.GONE);
        }
        if (mMore != null) {
            mMore.setVisibility(View.GONE);
        }
    }

    private void setTitleBarLeftRightMargin(int marginDp) {
        if (mTitleBar == null) return;

        ViewGroup.MarginLayoutParams titleBarLP = (ViewGroup.MarginLayoutParams) mTitleBar.getLayoutParams();
        if (titleBarLP != null) {
            int margin = (int) UIUtils.dip2Px(context(), marginDp);
            titleBarLP.leftMargin = margin;
            titleBarLP.rightMargin = margin;
            mTitleBar.setLayoutParams(titleBarLP);
        }
    }
}
