// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.player

import android.graphics.Bitmap
import android.view.Surface
import com.ss.videoarch.liveplayer.VeLivePayerAudioLoudnessInfo
import com.ss.videoarch.liveplayer.VeLivePlayer
import com.ss.videoarch.liveplayer.VeLivePlayerAudioFrame
import com.ss.videoarch.liveplayer.VeLivePlayerAudioVolume
import com.ss.videoarch.liveplayer.VeLivePlayerDef
import com.ss.videoarch.liveplayer.VeLivePlayerError
import com.ss.videoarch.liveplayer.VeLivePlayerObserver
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame
import org.json.JSONObject
import java.nio.ByteBuffer

/**
 * No-op base for [VeLivePlayerObserver] so subclasses override only the few
 * callbacks they care about.
 *
 * We deliberately keep our own copy inside live-sport instead of reusing
 * live-player's adapter: this module must stay self-contained so customers can
 * copy the whole `live-sport/` directory into their own project (see
 * `.localFiles/live-sport/TECH_DESIGN.md`).
 */
open class SportPlayerObserverAdapter : VeLivePlayerObserver {
    override fun onError(player: VeLivePlayer?, error: VeLivePlayerError?) {}
    override fun onFirstVideoFrameRender(player: VeLivePlayer?, isFirstFrame: Boolean) {}
    override fun onFirstAudioFrameRender(player: VeLivePlayer?, isFirstFrame: Boolean) {}
    override fun onStallStart(player: VeLivePlayer?) {}
    override fun onStallEnd(player: VeLivePlayer?) {}
    override fun onVideoRenderStall(player: VeLivePlayer?, stallTime: Long) {}
    override fun onAudioRenderStall(player: VeLivePlayer?, stallTime: Long) {}
    override fun onResolutionSwitch(
        player: VeLivePlayer?,
        resolution: VeLivePlayerDef.VeLivePlayerResolution?,
        error: VeLivePlayerError?,
        reason: VeLivePlayerDef.VeLivePlayerResolutionSwitchReason?,
    ) {}

    override fun onVideoSizeChanged(player: VeLivePlayer?, width: Int, height: Int) {}
    override fun onReceiveSeiMessage(player: VeLivePlayer?, message: String?) {}
    override fun onMainBackupSwitch(
        player: VeLivePlayer?,
        streamType: VeLivePlayerDef.VeLivePlayerStreamType?,
        error: VeLivePlayerError?,
    ) {}

    override fun onPlayerStatusUpdate(
        player: VeLivePlayer?,
        status: VeLivePlayerDef.VeLivePlayerStatus?,
    ) {}

    override fun onStatistics(player: VeLivePlayer?, statistics: VeLivePlayerStatistics?) {}
    override fun onSnapshotComplete(player: VeLivePlayer?, bitmap: Bitmap?) {}
    override fun onRenderVideoFrame(player: VeLivePlayer?, videoFrame: VeLivePlayerVideoFrame?) {}
    override fun onRenderAudioFrame(player: VeLivePlayer?, audioFrame: VeLivePlayerAudioFrame?) {}
    override fun onStreamFailedOpenSuperResolution(player: VeLivePlayer?, error: VeLivePlayerError?) {}
    override fun onAudioDeviceOpen(player: VeLivePlayer?, sampleRate: Int, channels: Int, bitDepth: Int) {}
    override fun onAudioDeviceClose(player: VeLivePlayer?) {}
    override fun onAudioDeviceRelease(player: VeLivePlayer?) {}
    override fun onBinarySeiUpdate(player: VeLivePlayer?, message: ByteBuffer?) {}
    override fun onMonitorLog(player: VeLivePlayer?, log: JSONObject?, type: String?) {}
    override fun onReportALog(player: VeLivePlayer?, level: Int, log: String?) {}
    override fun onResolutionDegrade(
        player: VeLivePlayer?,
        resolution: VeLivePlayerDef.VeLivePlayerResolution?,
    ) {}

    override fun onTextureRenderDrawFrame(player: VeLivePlayer?, surface: Surface?) {}
    override fun onHeadPoseUpdate(
        player: VeLivePlayer?,
        w: Float, x: Float, y: Float, z: Float,
        pitch: Float, yaw: Float, roll: Float,
    ) {}

    override fun onResponseSmoothSwitch(player: VeLivePlayer?, success: Boolean, taskId: Int) {}
    override fun onNetworkQualityChanged(player: VeLivePlayer?, quality: Int, msg: String?) {}
    override fun onAudioVolume(player: VeLivePlayer?, volumeInfo: VeLivePlayerAudioVolume?) {}
    override fun onLoudness(player: VeLivePlayer?, loudnessInfo: VeLivePayerAudioLoudnessInfo?) {}
    override fun onStreamFailedOpenSharpen(player: VeLivePlayer?, error: VeLivePlayerError?) {}
}
