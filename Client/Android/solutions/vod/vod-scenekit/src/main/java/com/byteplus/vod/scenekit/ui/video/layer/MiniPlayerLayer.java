// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;

import android.app.PendingIntent;
import android.app.PictureInPictureParams;
import android.app.RemoteAction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.graphics.drawable.Icon;
import android.os.Build;
import android.util.Rational;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.byteplus.vod.scenekit.ui.video.layer.helper.MiniPlayerHelper;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.settingskit.CenteredToast;

import java.util.ArrayList;

public class MiniPlayerLayer extends AnimateLayer {

    private static final String EXTRA_CONTROL_TYPE = "vevod_player_control_type";

    private static final int CONTROL_TYPE_PLAY = 0;
    private static final int CONTROL_TYPE_PAUSE = 1;
    private static final int CONTROL_TYPE_FORWARD = 2;
    private static final int CONTROL_TYPE_REWIND = 3;

    private static final int REQUEST_PLAY = 100;
    private static final int REQUEST_PAUSE = 101;
    private static final int REQUEST_FORWARD = 102;
    private static final int REQUEST_REWIND = 103;

    private PictureInPictureParams.Builder mPictureInPictureParamsBuilder;

    private final Dispatcher.EventListener mPlaybackListener = event -> {
        switch (event.code()) {
            case PlayerEvent.State.STARTED: {
                updatePauseAction();
                break;
            }
            case PlayerEvent.State.PAUSED: {
                updatePlayAction();
                break;
            }
            case PlayerEvent.State.COMPLETED:
            case PlayerEvent.State.ERROR:
            case PlayerEvent.State.STOPPED:
            case PlayerEvent.State.RELEASED: {
                L.d(this, "mini player completed");
                finishPictureInPictureMode();
                break;
            }
        }
    };

    private final String ACTION_PLAYER_CONTROL;

    private BroadcastReceiver mReceiver;

    public MiniPlayerLayer() {
        ACTION_PLAYER_CONTROL = "vevod_player_control:" + Integer.toHexString(hashCode());
    }


    @Override
    public String tag() {
        return "miniplayer_layer";
    }

    private final BaseActivity.IPictureInPictureCallback mPIPCallback = new BaseActivity.IPictureInPictureCallback() {
        @Override
        public void goIntoBackground() {
            tryGoIntoBackground();
        }

        @Override
        public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
            VideoView videoView = videoView();
            if (videoView == null) {
                return;
            }
            PlaybackController controller = videoView.controller();
            if (controller != null && isInPictureInPictureMode) {
                controller.addPlaybackListener(mPlaybackListener);
            } else if (controller != null) {
                controller.removePlaybackListener(mPlaybackListener);
            }
            videoView.setPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        }
    };

    @Override
    protected void onBindLayerHost(@NonNull VideoLayerHost layerHost) {
        super.onBindLayerHost(layerHost);
        BaseActivity.registerPictureInPictureCallback(mPIPCallback);
        L.d(this, "onBindLayerHost : " + this);
    }

    @Override
    protected void onUnbindLayerHost(@NonNull VideoLayerHost layerHost) {
        super.onUnbindLayerHost(layerHost);
        BaseActivity.unregisterPictureInPictureCallback(mPIPCallback);
        L.d(this, "onUnbindLayerHost : " + this);
    }

    private void tryGoIntoBackground() {
        L.d(this, "goIntoBackground");
        if (!MiniPlayerHelper.get().isMiniPlayerOn()) {
            return;
        }
        Context context = context();
        BaseActivity activity = (BaseActivity) context;
        if (activity == null || activity.isFinishing()) {
            return;
        }
        if (!MiniPlayerHelper.get().hasMiniPlayerPermission(context)) {
            CenteredToast.show(context, R.string.vevod_miniplayer_permission_denied);
            return;
        }
        if (!PlayScene.isFullScreenMode(playScene()) && playScene() != PlayScene.SCENE_DETAIL
                && playScene() != PlayScene.SCENE_SINGLE_FUNCTION) {
            return;
        }
        VideoView videoView = videoView();
        if (videoView == null) {
            return;
        }
        Player player = player();
        if (player == null || !player.isPlaying()) {
            return;
        }
        if (mPictureInPictureParamsBuilder == null) {
            mPictureInPictureParamsBuilder = new PictureInPictureParams.Builder();
        }
        if (player.isPaused()) {
            updatePlayAction();
        } else {
            updatePauseAction();
        }
        Rational aspectRatio = new Rational(videoView.getWidth(), videoView.getHeight());
        mPictureInPictureParamsBuilder.setAspectRatio(aspectRatio).build();
        boolean isSupport = activity.enterPictureInPictureMode(mPictureInPictureParamsBuilder.build());
        L.d(this, "enterPictureInPictureMode : " + isSupport);
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
        L.d(this, "onPictureInPictureModeChanged : " + isInPictureInPictureMode);
        Player player = player();
        if (isInPictureInPictureMode && player != null && player.isPlaying()) {
            mReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    if (intent == null
                            || !ACTION_PLAYER_CONTROL.equals(intent.getAction())) {
                        return;
                    }
                    final int type = intent.getIntExtra(EXTRA_CONTROL_TYPE, -1);
                    switch (type) {
                        case CONTROL_TYPE_PLAY: {
                            VideoView vv = videoView();
                            if (vv != null) {
                                Player player = vv.player();
                                if (player != null && player.isPlaying()) {
                                    return;
                                }
                                vv.startPlayback();
                                updatePauseAction();
                            }
                            break;
                        }
                        case CONTROL_TYPE_PAUSE: {
                            VideoView vv = videoView();
                            if (vv != null) {
                                Player player = vv.player();
                                if (player == null || player.isPaused()) {
                                    return;
                                }
                                vv.pausePlayback();
                                updatePlayAction();
                            }
                            break;
                        }
                        case CONTROL_TYPE_FORWARD: {
                            final Player player = player();
                            if (player != null && player.isInPlaybackState()) {
                                if (!player.isCompleted()) {
                                    long dur = player.getDuration();
                                    long seekTo = player.getCurrentPosition() + 10000;
                                    if (seekTo > dur) {
                                        seekTo = dur;
                                    }
                                    player.seekTo(seekTo);
                                }
                            }
                            break;
                        }
                        case CONTROL_TYPE_REWIND: {
                            final Player player = player();
                            if (player != null && player.isInPlaybackState()) {
                                if (!player.isCompleted()) {
                                    long seekTo = player.getCurrentPosition() - 10000;
                                    if (seekTo < 0) {
                                        seekTo = 0;
                                    }
                                    player.seekTo(seekTo);
                                }
                            }
                            break;
                        }
                    }
                }
            };
            BaseActivity activity = (BaseActivity) context();
            if (activity != null && !activity.isFinishing()) {
                ContextCompat.registerReceiver(
                        activity,
                        mReceiver,
                        new IntentFilter(ACTION_PLAYER_CONTROL),
                        ContextCompat.RECEIVER_NOT_EXPORTED);
            }
        } else if (mReceiver != null) {
            BaseActivity activity = (BaseActivity) context();
            if (activity != null && !activity.isFinishing()) {
                activity.unregisterReceiver(mReceiver);
            }
            mReceiver = null;
        }
    }

    private void finishPictureInPictureMode() {
        Context context = context();
        BaseActivity activity = (BaseActivity) context;
        if (activity == null || activity.isFinishing()) {
            return;
        }
        if (mReceiver != null) {
            activity.unregisterReceiver(mReceiver);
        }
        VideoView videoView = videoView();
        PlaybackController controller = videoView == null ? null : videoView.controller();
        if (controller != null) {
            controller.removePlaybackListener(mPlaybackListener);
        }
        if (videoView != null && videoView.isInPictureInPictureMode()) {
            activity.finish();
        }
    }

    private void updatePlayAction() {
        Context context = context();
        BaseActivity activity = (BaseActivity) context;
        if (activity == null || activity.isFinishing()) {
            return;
        }
        updatePictureInPictureActions(R.drawable.vevod_minplayer_play,
                context.getString(R.string.vevod_miniplayer_play), CONTROL_TYPE_PLAY, REQUEST_PLAY);
    }

    private void updatePauseAction() {
        Context context = context();
        BaseActivity activity = (BaseActivity) context;
        if (activity == null || activity.isFinishing()) {
            return;
        }
        updatePictureInPictureActions(R.drawable.vevod_minplayer_pause,
                context.getString(R.string.vevod_miniplayer_pause), CONTROL_TYPE_PAUSE, REQUEST_PAUSE);
    }

    private void updatePictureInPictureActions(
            @DrawableRes int iconId,
            String title,
            int controlType,
            int requestCode
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return;
        }
        final Context context = context();
        if (context == null) {
            return;
        }

        final ArrayList<RemoteAction> actions = new ArrayList<>();

        { // Rewind
            Intent intent = new Intent(ACTION_PLAYER_CONTROL);
            intent.setPackage(context.getPackageName());
            intent.putExtra(EXTRA_CONTROL_TYPE, CONTROL_TYPE_REWIND);

            final PendingIntent backwardIntent = PendingIntent.getBroadcast(
                    context,
                    REQUEST_REWIND,
                    intent,
                    PendingIntent.FLAG_IMMUTABLE);
            final Icon backwardIcon = Icon.createWithResource(context, R.drawable.vevod_minplayer_rewind);
            String backwardTitle = context.getString(R.string.vevod_miniplayer_rewind);
            actions.add(new RemoteAction(backwardIcon, backwardTitle, backwardTitle, backwardIntent));
        }

        { // Play/Pause
            Intent intent = new Intent(ACTION_PLAYER_CONTROL);
            intent.setPackage(context.getPackageName());
            intent.putExtra(EXTRA_CONTROL_TYPE, controlType);

            final PendingIntent playPauseIntent = PendingIntent.getBroadcast(
                    context,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_IMMUTABLE);
            final Icon icon = Icon.createWithResource(context, iconId);
            actions.add(new RemoteAction(icon, title, title, playPauseIntent));
        }

        { // Forward
            Intent intent = new Intent(ACTION_PLAYER_CONTROL);
            intent.setPackage(context.getPackageName());
            intent.putExtra(EXTRA_CONTROL_TYPE, CONTROL_TYPE_FORWARD);
            final PendingIntent forwardIntent =
                    PendingIntent.getBroadcast(
                            context,
                            REQUEST_FORWARD,
                            intent,
                            PendingIntent.FLAG_IMMUTABLE);
            final Icon forwardIcon = Icon.createWithResource(context, R.drawable.vevod_miniplayer_forward);
            String forwardTitle = context.getString(R.string.vevod_miniplayer_forward);
            actions.add(new RemoteAction(forwardIcon, forwardTitle, forwardTitle, forwardIntent));
        }

        BaseActivity activity = (BaseActivity) context;
        if (activity.isFinishing() || mPictureInPictureParamsBuilder == null) {
            return;
        }
        mPictureInPictureParamsBuilder.setActions(actions);
        activity.setPictureInPictureParams(mPictureInPictureParamsBuilder.build());
    }
}
