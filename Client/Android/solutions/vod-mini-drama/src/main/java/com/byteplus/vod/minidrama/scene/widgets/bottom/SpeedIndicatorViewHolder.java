// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.bottom;

import android.graphics.ImageDecoder;
import android.graphics.drawable.AnimatedImageDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.core.content.res.ResourcesCompat;

import com.byteplus.minidrama.R;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.vod.minidrama.scene.widgets.DramaVideoSceneView;
import com.byteplus.vod.minidrama.scene.widgets.adatper.ViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaGestureLayer;
import com.byteplus.vod.minidrama.scene.widgets.viewholder.DramaEpisodeVideoViewHolder;

import java.io.IOException;
import java.util.Locale;

public class SpeedIndicatorViewHolder implements DramaGestureLayer.DramaGestureContract {
    private final DramaVideoSceneView mSceneView;
    private final View mSpeedIndicatorView;
    private final TextView mSpeedDescView;
    private final ImageView mSpeedArrow;

    public SpeedIndicatorViewHolder(View view, DramaVideoSceneView sceneView) {
        mSceneView = sceneView;
        mSpeedIndicatorView = view.findViewById(R.id.bottomBarCardSpeedIndicator);
        mSpeedDescView = view.findViewById(R.id.speedDesc);
        mSpeedArrow = view.findViewById(R.id.speedArrow);
        showSpeedIndicator(false);
    }

    @Override
    public boolean isSpeedIndicatorShowing() {
        return mSpeedIndicatorView.getVisibility() == View.VISIBLE;
    }

    @Override
    public void showSpeedIndicator(boolean show) {
        if (show) {
            final ViewHolder viewHolder = mSceneView.pageView().getCurrentViewHolder();
            if (!(viewHolder instanceof DramaEpisodeVideoViewHolder)) {
                return;
            }
            VideoView videoView = ((DramaEpisodeVideoViewHolder) viewHolder).videoView;
            if (videoView == null) return;
            final Player player = videoView.player();
            if (player == null || !player.isPlaying()) return;

            mSpeedIndicatorView.setVisibility(View.VISIBLE);
            mSpeedDescView.setText(String.format(Locale.getDefault(), mSpeedDescView.getResources().getString(R.string.vevod_video_bottom_bar_card_speed_desc), player.getSpeed()));

            Drawable drawable = mSpeedArrow.getDrawable();
            if (drawable == null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    try {
                        drawable = (AnimatedImageDrawable) ImageDecoder.decodeDrawable(ImageDecoder.createSource(mSpeedDescView.getResources(), R.drawable.vevod_mini_drama_video_bottom_card_speed_ic));
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                if (drawable == null) {
                    drawable = ResourcesCompat.getDrawable(mSpeedDescView.getResources(), R.drawable.vevod_mini_drama_video_bottom_card_speed_ic, null);
                }
                mSpeedArrow.setImageDrawable(drawable);
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                if (drawable instanceof AnimatedImageDrawable) {
                    AnimatedImageDrawable gif = (AnimatedImageDrawable) drawable;
                    gif.start();
                }
            }
        } else {
            mSpeedIndicatorView.setVisibility(View.GONE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                Drawable drawable = mSpeedArrow.getDrawable();
                if (drawable instanceof AnimatedImageDrawable) {
                    AnimatedImageDrawable gif = (AnimatedImageDrawable) drawable;
                    gif.stop();
                }
            }
        }
    }
}
