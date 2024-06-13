// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.vod.scenekit.ui.video.layer.dialog;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.SeekBar;

import androidx.annotation.NonNull;
import androidx.core.math.MathUtils;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer;
import com.byteplus.vod.scenekit.ui.video.layer.Layers;
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.utils.UIUtils;


public class VolumeBrightnessDialogLayer extends DialogLayer implements VolumeReceiver.SyncVolumeHandler {
    public static final int TYPE_VOLUME = 0;
    public static final int TYPE_BRIGHTNESS = 1;

    private SeekBar mSeekBar;
    private View mSeekBarContainer;
    private int mType;

    private VolumeReceiver mVolume;

    @Override
    public String tag() {
        return "volume_brightness";
    }

    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_volume_brightness_layer, parent, false);
        mSeekBarContainer = view.findViewById(R.id.seekBarContainer);
        mSeekBar = view.findViewById(R.id.seekBar);
        mSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    animateShow(true);
                    if (mType == TYPE_VOLUME) {
                        setVolumeByProgress(progress);
                    } else {
                        setBrightnessByProgress(progress);
                    }
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                animateDismiss();
            }
        });
        mSeekBar.setMax(100);
        view.setOnClickListener(v -> animateDismiss());

        setAnimateDismissListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                GestureLayer layer = findLayer(GestureLayer.class);
                if (layer != null) {
                    layer.showController();
                }
            }
        });
        return view;
    }

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.VOLUME_BRIGHTNESS_DIALOG_BACK_PRIORITY;
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!PlayScene.isFullScreenMode(toScene)) {
            dismiss();
        }
    }

    @Override
    public void onVideoViewAttachedToWindow(@NonNull VideoView videoView) {
        super.onVideoViewAttachedToWindow(videoView);
        if (mVolume == null) {
            mVolume = new VolumeReceiver(this);
        }
        mVolume.register(activity());
    }

    @Override
    public void onVideoViewDetachedFromWindow(@NonNull VideoView videoView) {
        if (mVolume != null) {
            mVolume.unregister(activity());
        }
        super.onVideoViewDetachedFromWindow(videoView);
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    private final Dispatcher.EventListener mPlaybackListener = event -> {
        switch (event.code()) {
            case PlayerEvent.State.STOPPED:
            case PlayerEvent.State.RELEASED:
                dismiss();
                break;
        }
    };

    public void setBrightnessByProgress(int progress) {
        Activity activity = activity();
        if (activity == null) return;
        L.v(this, "setBrightnessByProgress", progress);

        float screenBrightness = mapProgress2Brightness(progress);
        BrightnessHelper.set(activity, screenBrightness);

        if (mSeekBar != null) {
            mSeekBar.setProgress(progress);
        }
    }

    public int getBrightByProgress() {
        Activity activity = activity();
        if (activity == null) return 0;

        float brightness = BrightnessHelper.get(activity);

        return Math.max(mapBrightness2Progress(brightness), 0);
    }

    private int mVolumeProgress = -1;

    public void setVolumeByProgress(int progress) {
        L.v(this, "setVolumeByProgress", progress);
        if (mVolumeProgress == progress) {
            return;
        }
        mVolumeProgress = progress;
        final Player player = player();
        if (player != null) {
            float volume = mapProgress2Volume(progress);
            player.setVolume(volume, volume);
        }
    }

    public int getVolumeByProgress() {
        if (mVolumeProgress < 0) {
            mVolumeProgress = Math.max(mapVolume2Progress(getPlayerVolume()), 0);
        }

        L.v(this, "getVolumeByProgress", mVolumeProgress);
        return mVolumeProgress;
    }

    private float getPlayerVolume() {
        final Player player = player();
        if (player != null) {
            float[] volume = player.getVolume();
            return volume[0];
        } else {
            return 0.F;
        }
    }

    public void setType(int type) {
        mType = type;
    }

    @Override
    public void show() {
        super.show();
        if (mType == TYPE_VOLUME) {
            syncVolume();
        } else {
            syncBrightness();
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
        mVolumeProgress = -1;
    }

    @Override
    public void syncVolume() {
        if (!isShowing()) return;

        int volumeProgress = mapVolume2Progress(getPlayerVolume());
        mSeekBar.setProgress(volumeProgress);

        if (mSeekBarContainer == null) return;

        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) mSeekBarContainer.getLayoutParams();
        if (lp != null) {
            lp.gravity = Gravity.RIGHT | Gravity.CENTER_VERTICAL;
            lp.leftMargin = 0;
            lp.rightMargin = (int) UIUtils.dip2Px(context(), 64);
            mSeekBarContainer.setLayoutParams(lp);
        }
    }

    private void syncBrightness() {
        Activity activity = activity();
        if (activity == null) return;

        float brightness = BrightnessHelper.get(activity);
        mSeekBar.setProgress(MathUtils.clamp(mapBrightness2Progress(brightness), 0, 100));

        if (mSeekBarContainer == null) return;

        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) mSeekBarContainer.getLayoutParams();
        if (lp != null) {
            lp.gravity = Gravity.LEFT | Gravity.CENTER_VERTICAL;
            lp.leftMargin = (int) UIUtils.dip2Px(context(), 64);
            lp.rightMargin = 0;
            mSeekBarContainer.setLayoutParams(lp);
        }
    }

    public static int mapVolume2Progress(float volume) {
        return (int) (volume * 100);
    }

    public static float mapProgress2Volume(int progress) {
        return progress / 100f;
    }

    public static int mapBrightness2Progress(float brightness) {
        return (int) (brightness * 100);
    }

    public static float mapProgress2Brightness(int progress) {
        return progress / 100f;
    }
}
