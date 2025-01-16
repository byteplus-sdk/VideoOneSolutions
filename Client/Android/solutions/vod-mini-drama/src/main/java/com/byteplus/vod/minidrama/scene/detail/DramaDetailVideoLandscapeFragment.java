// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.vod.minidrama.scene.widgets.adatper.ViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoLayer;
import com.byteplus.vod.minidrama.scene.widgets.viewholder.DramaEpisodeVideoViewLandscapeHolder;
import com.byteplus.vod.scenekit.data.model.ItemType;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.utils.UIUtils;

import java.util.List;

public class DramaDetailVideoLandscapeFragment extends DramaDetailVideoFragment{

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (requireActivity().getRequestedOrientation() != ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            requireActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }

        final View decorView = requireActivity().getWindow().getDecorView();
        decorView.setSystemUiVisibility(getUiOptions(requireActivity()));

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            if (UIUtils.hasDisplayCutout(requireActivity().getWindow())) {
                requireActivity().getWindow().getAttributes().layoutInDisplayCutoutMode =
                        WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            }
        }
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

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        binding.bottomBarCardSpeedIndicator.setVisibility(View.GONE);
        binding.bottomBarCardSelectEpisode.setVisibility(View.GONE);
        binding.bottomBarCardSpeedSelector.setVisibility(View.GONE);

        mSceneView.pageView().viewPager().setOrientation(ViewPager2.ORIENTATION_HORIZONTAL);
        mSceneView.pageView().viewPager().setNestedScrollingEnabled(false);
        mSceneView.pageView().viewPager().setUserInputEnabled(false);
    }

    @Override
    protected ViewHolder.Factory getViewHolderFactory() {
        return new DetailDramaVideoLandscapeViewHolderFactory();
    }

    @Override
    protected void setItems(List<ViewItem> items) {
        super.setItems(items);
        if (items != null && !items.isEmpty()) {
            binding.getRoot().post(() -> {
                binding.back.setVisibility(View.GONE);
                binding.titleBar.setVisibility(View.GONE);
                binding.guidelineTop.setVisibility(View.GONE);
                binding.title.setVisibility(View.GONE);
            });
        }
    }

    private class DetailDramaVideoLandscapeViewHolderFactory extends DetailDramaVideoViewHolderFactory{

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            if (viewType == ItemType.ITEM_TYPE_VIDEO) {
                final DramaEpisodeVideoViewLandscapeHolder viewHolder = new DramaEpisodeVideoViewLandscapeHolder(
                        DramaDetailVideoLandscapeFragment.this,
                        new FrameLayout(parent.getContext()),
                        DramaVideoLayer.Type.DETAIL_LANDSCAPE,
                        mSpeedIndicator);
                final VideoView videoView = viewHolder.videoView;
                final PlaybackController controller = videoView == null ? null : videoView.controller();
                if (controller != null) {
                    controller.addPlaybackListener(event -> {
                        if (event.code() == PlayerEvent.State.COMPLETED) {
                            onPlayerStateCompleted(event);
                        }
                    });
                }
                return viewHolder;
            }
            return super.onCreateViewHolder(parent, viewType);
        }
    }
}
