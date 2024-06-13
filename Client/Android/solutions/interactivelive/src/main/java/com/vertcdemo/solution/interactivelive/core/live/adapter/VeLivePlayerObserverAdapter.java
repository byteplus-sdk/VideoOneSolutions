// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live.adapter;

import android.graphics.Bitmap;

import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerAudioFrame;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VeLivePlayerError;
import com.ss.videoarch.liveplayer.VeLivePlayerObserver;
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics;
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame;
import com.vertcdemo.solution.interactivelive.core.live.LLog;

public class VeLivePlayerObserverAdapter implements VeLivePlayerObserver {
    private static final String TAG = "PlayerObserver";

    @Override
    public void onError(VeLivePlayer player, VeLivePlayerError error) {
        LLog.d(TAG, "onError: Code:" + error.mErrorCode + "; Msg:" + error.mErrorMsg);
    }

    @Override
    public void onFirstVideoFrameRender(VeLivePlayer player, boolean isFirstFrame) {
        LLog.d(TAG, "onFirstVideoFrameRender: isFirstFrame: " + isFirstFrame);
    }

    @Override
    public void onFirstAudioFrameRender(VeLivePlayer player, boolean isFirstFrame) {
        LLog.d(TAG, "onFirstAudioFrameRender: isFirstFrame: " + isFirstFrame);
    }

    @Override
    public void onStallStart(VeLivePlayer player) {
        LLog.d(TAG, "onStallStart: ");
    }

    @Override
    public void onStallEnd(VeLivePlayer player) {
        LLog.d(TAG, "onStallEnd: ");
    }

    @Override
    public void onVideoRenderStall(VeLivePlayer player, long stallTime) {
        LLog.d(TAG, "onVideoRenderStall: stallTime: " + stallTime);
    }

    @Override
    public void onAudioRenderStall(VeLivePlayer player, long stallTime) {
        LLog.d(TAG, "onAudioRenderStall: stallTime: " + stallTime);
    }

    @Override
    public void onResolutionSwitch(VeLivePlayer player,
                                   VeLivePlayerDef.VeLivePlayerResolution resolution,
                                   VeLivePlayerError error,
                                   VeLivePlayerDef.VeLivePlayerResolutionSwitchReason reason) {
        LLog.d(TAG, "onResolutionSwitch: resolution: " + resolution + "; error: " + error + "; reason:" + reason);
    }

    @Override
    public void onVideoSizeChanged(VeLivePlayer player,
                                   int width,
                                   int height) {
        LLog.d(TAG, "onVideoSizeChanged: width: " + width + "; height: " + height);
    }

    @Override
    public void onReceiveSeiMessage(VeLivePlayer player,
                                    String message) {
        LLog.d(TAG, "onReceiveSeiMessage: message: " + message);
    }

    @Override
    public void onMainBackupSwitch(VeLivePlayer player,
                                   VeLivePlayerDef.VeLivePlayerStreamType streamType,
                                   VeLivePlayerError error) {
        LLog.d(TAG, "onMainBackupSwitch: streamType: " + streamType + "; error: " + error);
    }

    @Override
    public void onPlayerStatusUpdate(VeLivePlayer player,
                                     VeLivePlayerDef.VeLivePlayerStatus status) {
        LLog.d(TAG, "onPlayerStatusUpdate: status: " + status);
    }

    @Override
    public void onStatistics(VeLivePlayer player,
                             VeLivePlayerStatistics statistics) {
        LLog.d(TAG, "onStatistics: url: " + statistics.url);
        LLog.d(TAG, "onStatistics: fps: " + statistics.fps
                + "; protocol: " + statistics.protocol
                + "; format: " + statistics.format);
    }

    @Override
    public void onSnapshotComplete(VeLivePlayer player, Bitmap bitmap) {
        LLog.d(TAG, "onSnapshotComplete: ");
    }

    @Override
    public void onRenderVideoFrame(VeLivePlayer player,
                                   VeLivePlayerVideoFrame videoFrame) {
        LLog.d(TAG, "onRenderVideoFrame: ");
    }

    @Override
    public void onRenderAudioFrame(VeLivePlayer player,
                                   VeLivePlayerAudioFrame audioFrame) {
        LLog.d(TAG, "onRenderAudioFrame: ");
    }

    @Override
    public void onStreamFailedOpenSuperResolution(VeLivePlayer player,
                                                  VeLivePlayerError error) {
        LLog.d(TAG, "onStreamFailedOpenSuperResolution: error: " + error);
    }

    @Override
    public void onStreamFailedOpenSharpen(VeLivePlayer veLivePlayer, VeLivePlayerError error) {
        LLog.d(TAG, "onStreamFailedOpenSharpen: error: " + error);
    }
}
