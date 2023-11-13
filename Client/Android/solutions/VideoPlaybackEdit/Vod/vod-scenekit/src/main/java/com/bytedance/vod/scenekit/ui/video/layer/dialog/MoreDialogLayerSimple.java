// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.vod.scenekit.ui.video.layer.dialog;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;

import androidx.annotation.FloatRange;
import androidx.annotation.NonNull;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.player.event.ActionSetLooping;
import com.bytedance.playerkit.player.playback.PlaybackController;
import com.bytedance.playerkit.player.playback.VideoLayerHost;
import com.bytedance.playerkit.player.playback.VideoView;
import com.bytedance.playerkit.utils.event.Dispatcher;
import com.bytedance.vod.scenekit.ui.video.layer.Layers;
import com.bytedance.vod.scenekit.databinding.VevodMoreDialogLayerSimpleBinding;
import com.bytedance.vod.scenekit.ui.video.layer.GestureLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;
import com.vertcdemo.base.ReportDialog;


public class MoreDialogLayerSimple extends MoreDialogLayer implements VolumeReceiver.SyncVolumeHandler {

    private static final int MAX_VALUE = 100;

    private VevodMoreDialogLayerSimpleBinding binding;

    @Override
    public String tag() {
        return "more_dialog_simple";
    }

    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        Context context = parent.getContext();
        binding = VevodMoreDialogLayerSimpleBinding.inflate(LayoutInflater.from(context), parent, false);

        binding.loopOn.setOnClickListener(v -> setLoop(true));
        binding.loopOff.setOnClickListener(v -> setLoop(false));

        binding.volume.setMax(MAX_VALUE);
        binding.volume.setOnSeekBarChangeListener(new OnSeekBarChangeAdapter() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    float volume = ((float) progress) / MAX_VALUE;
                    setVolume(volume);
                }
            }
        });

        binding.brightness.setMax(MAX_VALUE);
        binding.brightness.setOnSeekBarChangeListener(new OnSeekBarChangeAdapter() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    float brightness = ((float) progress) / MAX_VALUE;
                    setBrightness(brightness);
                }
            }
        });

        binding.report.setOnClickListener(v -> ReportDialog.show(context));

        binding.getRoot().setOnClickListener(v -> animateDismiss());

        setAnimateDismissListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                GestureLayer layer = layerHost().findLayer(GestureLayer.class);
                if (layer != null) {
                    layer.showController();
                }
            }
        });

        return binding.getRoot();
    }

    private VolumeReceiver mVolumeReceiver;

    @Override
    protected void onBindLayerHost(@NonNull VideoLayerHost layerHost) {
        super.onBindLayerHost(layerHost);
        if (mVolumeReceiver == null) {
            mVolumeReceiver = new VolumeReceiver(this);
        }
        mVolumeReceiver.register(activity());
    }

    @Override
    protected void onBindVideoView(@NonNull VideoView videoView) {
        super.onBindVideoView(videoView);
    }

    @Override
    protected void onUnbindLayerHost(@NonNull VideoLayerHost layerHost) {
        super.onUnbindLayerHost(layerHost);
        if (mVolumeReceiver != null) {
            mVolumeReceiver.unregister(activity());
        }
    }

    public void setVolume(@FloatRange(from = 0, to = 1.0) float value) {
        final Player player = player();
        if (player == null || !player.isInPlaybackState()) {
            return;
        }
        player.setVolume(value, value);
    }

    public void setBrightness(@FloatRange(from = 0, to = 1.0) float value) {
        Activity activity = activity();
        if (activity == null) return;


        BrightnessHelper.set(activity, value);
    }

    void syncBrightness() {
        Activity activity = activity();
        if (activity == null) return;

        float brightness = BrightnessHelper.get(activity);
        binding.brightness.setProgress((int) (MAX_VALUE * brightness));
    }

    @Override
    public void syncVolume() {
        if (binding == null) return;
        final Player player = player();
        if (player == null) {
            binding.volume.setProgress(50);
        } else {
            float[] volume = player.getVolume();
            float left = volume[0];
            binding.volume.setProgress((int) (MAX_VALUE * left));
        }
    }

    @Override
    public void show() {
        super.show();
        syncViewLoopState();
        syncBrightness();
        syncVolume();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (playScene() != PlayScene.SCENE_FULLSCREEN) {
            dismiss();
        }
    }

    public void setLoop(boolean loop) {
        final Player player = player();
        if (player == null || !player.isInPlaybackState()) {
            return;
        }
        player.setLooping(loop);
    }

    public void setViewLoop(boolean loop) {
        if (isShowing()) {
            binding.loopOn.setSelected(loop);
            binding.loopOff.setSelected(!loop);
        }
    }

    private void syncViewLoopState() {
        final Player player = player();
        if (player == null || !player.isInPlaybackState()) {
            return;
        }
        setViewLoop(player.isLooping());
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    final Dispatcher.EventListener mPlaybackListener = event -> {
        switch (event.code()) {
            case PlayerEvent.Action.SET_LOOPING:
                setViewLoop(event.cast(ActionSetLooping.class).isLooping);
                break;
        }
    };

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.MORE_DIALOG_LAYER_BACK_PRIORITY;
    }
}
