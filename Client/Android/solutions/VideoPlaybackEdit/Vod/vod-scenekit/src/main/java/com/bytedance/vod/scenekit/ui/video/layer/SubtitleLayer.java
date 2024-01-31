/*
 * Copyright (C) 2023 bytedance
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Create Date : 2023/6/12
 */

package com.bytedance.vod.scenekit.ui.video.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.content.res.Configuration;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.event.InfoSubtitleInfoReady;
import com.bytedance.playerkit.player.event.InfoSubtitleTextUpdate;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.PlaybackEvent;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.player.source.SubtitleText;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.bytedance.vod.scenekit.utils.UIUtils;
import com.bytedance.vod.settingskit.CenteredToast;

public class SubtitleLayer extends AnimateLayer {

    private TextView mSubText;

    @Nullable
    @Override
    public String tag() {
        return "subtitle";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        final View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_subtitle_layer, parent, false);
        mSubText = view.findViewById(R.id.subtitle);
        return view;
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
                case PlayerEvent.State.COMPLETED:
                    if (mSubText != null) {
                        mSubText.setText("");
                    }
                    dismiss();
                    break;
                case PlaybackEvent.Action.STOP_PLAYBACK:
                    dismiss();
                    break;
                case PlayerEvent.Info.SUBTITLE_STATE_CHANGED: {
                    applyVisible();
                    break;
                }
                case PlayerEvent.Info.SUBTITLE_TEXT_UPDATE: {
                    applyVisible();
                    InfoSubtitleTextUpdate e = event.cast(InfoSubtitleTextUpdate.class);
                    SubtitleText subtitleText = e.subtitleText;
                    if (subtitleText != null && mSubText != null) {
                        mSubText.setText(subtitleText.text);
                    }
                    break;
                }
                case PlayerEvent.Info.SUBTITLE_CHANGED: {
                    if (mSubText != null) {
                        mSubText.setText("");
                    }
                    break;
                }
                case PlayerEvent.Info.SUBTITLE_LIST_INFO_READY:{
                    InfoSubtitleInfoReady cast = event.cast(InfoSubtitleInfoReady.class);
                    if (cast.subtitles == null || cast.subtitles.isEmpty()) {
                        CenteredToast.show(context(), R.string.vevod_subtitle_obtain_failed);
                    }
                    break;
                }
            }
        }
    };

    @Override
    public void show() {
        super.show();
        applyTheme();
    }

    public void applyVisible() {
        Player player = player();
        if (player == null) {
            dismiss();
            return;
        }
        VideoView videoView = videoView();
        if (player.isSubtitleEnabled()
                && (videoView != null && !videoView.isInPictureInPictureMode())) {
            show();
        } else {
            dismiss();
        }
    }

    public void applyTheme() {
        if (isFullScreenMode(playScene())) {
            applyFullScreenTheme();
        } else {
            applyHalfScreenTheme();
        }
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        if (isInPictureInPictureMode) {
            dismiss();
        } else {
            applyVisible();
        }
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        applyTheme();
    }

    private void applyHalfScreenTheme() {
        if (mSubText == null) return;

        mSubText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        ((ViewGroup.MarginLayoutParams) mSubText.getLayoutParams()).bottomMargin = (int) UIUtils.dip2Px(context(), 12);
        mSubText.requestLayout();
    }

    private void applyFullScreenTheme() {
        if (mSubText == null) return;

        mSubText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 22);
        ((ViewGroup.MarginLayoutParams) mSubText.getLayoutParams()).bottomMargin = (int) UIUtils.dip2Px(context(), 16);
        mSubText.requestLayout();
    }
}
