// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player;

import android.graphics.Bitmap;
import android.view.Surface;

import com.ss.videoarch.liveplayer.VeLivePayerAudioLoudnessInfo;
import com.ss.videoarch.liveplayer.VeLivePayerAudioVolume;
import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerAudioFrame;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VeLivePlayerError;
import com.ss.videoarch.liveplayer.VeLivePlayerObserver;
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics;
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame;

import org.json.JSONObject;

import java.nio.ByteBuffer;

public class VeLivePlayerObserverAdapter implements VeLivePlayerObserver {
    @Override
    public void onError(VeLivePlayer veLivePlayer, VeLivePlayerError veLivePlayerError) {

    }

    @Override
    public void onFirstVideoFrameRender(VeLivePlayer veLivePlayer, boolean b) {

    }

    @Override
    public void onFirstAudioFrameRender(VeLivePlayer veLivePlayer, boolean b) {

    }

    @Override
    public void onStallStart(VeLivePlayer veLivePlayer) {

    }

    @Override
    public void onStallEnd(VeLivePlayer veLivePlayer) {

    }

    @Override
    public void onVideoRenderStall(VeLivePlayer veLivePlayer, long l) {

    }

    @Override
    public void onAudioRenderStall(VeLivePlayer veLivePlayer, long l) {

    }

    @Override
    public void onResolutionSwitch(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution, VeLivePlayerError veLivePlayerError, VeLivePlayerDef.VeLivePlayerResolutionSwitchReason veLivePlayerResolutionSwitchReason) {

    }

    @Override
    public void onVideoSizeChanged(VeLivePlayer veLivePlayer, int i, int i1) {

    }

    @Override
    public void onReceiveSeiMessage(VeLivePlayer veLivePlayer, String s) {

    }

    @Override
    public void onMainBackupSwitch(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerStreamType veLivePlayerStreamType, VeLivePlayerError veLivePlayerError) {

    }

    @Override
    public void onPlayerStatusUpdate(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerStatus veLivePlayerStatus) {

    }

    @Override
    public void onStatistics(VeLivePlayer veLivePlayer, VeLivePlayerStatistics veLivePlayerStatistics) {

    }

    @Override
    public void onSnapshotComplete(VeLivePlayer veLivePlayer, Bitmap bitmap) {

    }

    @Override
    public void onRenderVideoFrame(VeLivePlayer veLivePlayer, VeLivePlayerVideoFrame veLivePlayerVideoFrame) {

    }

    @Override
    public void onRenderAudioFrame(VeLivePlayer veLivePlayer, VeLivePlayerAudioFrame veLivePlayerAudioFrame) {

    }

    @Override
    public void onStreamFailedOpenSuperResolution(VeLivePlayer veLivePlayer, VeLivePlayerError veLivePlayerError) {

    }

    @Override
    public void onAudioDeviceOpen(VeLivePlayer veLivePlayer, int i, int i1, int i2) {

    }

    @Override
    public void onAudioDeviceClose(VeLivePlayer veLivePlayer) {

    }

    @Override
    public void onAudioDeviceRelease(VeLivePlayer veLivePlayer) {

    }

    @Override
    public void onBinarySeiUpdate(VeLivePlayer veLivePlayer, ByteBuffer byteBuffer) {

    }

    @Override
    public void onMonitorLog(VeLivePlayer veLivePlayer, JSONObject jsonObject, String s) {

    }

    @Override
    public void onReportALog(VeLivePlayer veLivePlayer, int i, String s) {

    }

    @Override
    public void onResolutionDegrade(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution) {

    }

    @Override
    public void onTextureRenderDrawFrame(VeLivePlayer veLivePlayer, Surface surface) {

    }

    @Override
    public void onHeadPoseUpdate(VeLivePlayer veLivePlayer, float v, float v1, float v2, float v3, float v4, float v5, float v6) {

    }

    @Override
    public void onResponseSmoothSwitch(VeLivePlayer veLivePlayer, boolean b, int i) {

    }

    @Override
    public void onNetworkQualityChanged(VeLivePlayer veLivePlayer, int i, String s) {

    }

    @Override
    public void onAudioVolume(VeLivePlayer veLivePlayer, VeLivePayerAudioVolume veLivePayerAudioVolume) {

    }

    @Override
    public void onLoudness(VeLivePlayer veLivePlayer, VeLivePayerAudioLoudnessInfo veLivePayerAudioLoudnessInfo) {

    }

    @Override
    public void onStreamFailedOpenSharpen(VeLivePlayer veLivePlayer, VeLivePlayerError veLivePlayerError) {

    }
}
