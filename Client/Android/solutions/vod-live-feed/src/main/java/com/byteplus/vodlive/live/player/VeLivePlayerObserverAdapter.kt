package com.byteplus.vodlive.live.player

import android.graphics.Bitmap
import android.view.Surface
import com.byteplus.vodlive.utils.playerLog
import com.ss.videoarch.liveplayer.VeLivePayerAudioLoudnessInfo
import com.ss.videoarch.liveplayer.VeLivePayerAudioVolume
import com.ss.videoarch.liveplayer.VeLivePlayer
import com.ss.videoarch.liveplayer.VeLivePlayerAudioFrame
import com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerResolution
import com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerResolutionSwitchReason
import com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerStatus
import com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerStreamType
import com.ss.videoarch.liveplayer.VeLivePlayerError
import com.ss.videoarch.liveplayer.VeLivePlayerObserver
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame
import org.json.JSONObject
import java.nio.ByteBuffer

private const val TAG = "PlayerObserver"

open class VeLivePlayerObserverAdapter(private val tag: String) : VeLivePlayerObserver {
    var isFirstVideoFrameRendered = false
        private set

    override fun onError(player: VeLivePlayer, error: VeLivePlayerError) {
        playerLog(TAG, "[$tag] onError: ${error.string()}")
    }

    override fun onPlayerStatusUpdate(
        player: VeLivePlayer,
        status: VeLivePlayerStatus
    ) {
        playerLog(TAG, "[$tag] onPlayerStatusUpdate: status: $status")
        if (status == VeLivePlayerStatus.VeLivePlayerStatusStopped
            || status == VeLivePlayerStatus.VeLivePlayerStatusPaused
        ) {
            isFirstVideoFrameRendered = false
        }
    }

    override fun onFirstVideoFrameRender(player: VeLivePlayer, isFirstFrame: Boolean) {
        playerLog(TAG, "[$tag] onFirstVideoFrameRender: isFirstFrame: $isFirstFrame")
        isFirstVideoFrameRendered = isFirstFrame
    }

    override fun onFirstAudioFrameRender(player: VeLivePlayer, isFirstFrame: Boolean) {
        playerLog(TAG, "[$tag] onFirstAudioFrameRender: isFirstFrame: $isFirstFrame")
    }

    override fun onStallStart(player: VeLivePlayer) {
        playerLog(TAG, "[$tag] onStallStart: ")
    }

    override fun onStallEnd(player: VeLivePlayer) {
        playerLog(TAG, "[$tag] onStallEnd: ")
    }

    override fun onVideoRenderStall(player: VeLivePlayer, stallTime: Long) {
        playerLog(TAG, "[$tag] onVideoRenderStall: stallTime: $stallTime")
    }

    override fun onAudioRenderStall(player: VeLivePlayer, stallTime: Long) {
        playerLog(TAG, "[$tag] onAudioRenderStall: stallTime: $stallTime")
    }

    override fun onResolutionSwitch(
        player: VeLivePlayer,
        resolution: VeLivePlayerResolution,
        error: VeLivePlayerError,
        reason: VeLivePlayerResolutionSwitchReason
    ) {
        playerLog(
            TAG,
            "[$tag] onResolutionSwitch: resolution: $resolution; error: $error; reason:$reason"
        )
    }

    override fun onVideoSizeChanged(
        player: VeLivePlayer,
        width: Int,
        height: Int
    ) {
        playerLog(TAG, "[$tag] onVideoSizeChanged: width: $width; height: $height")
    }

    override fun onReceiveSeiMessage(
        player: VeLivePlayer,
        message: String
    ) {
        playerLog(TAG, "[$tag] onReceiveSeiMessage: message: $message")
    }

    override fun onMainBackupSwitch(
        player: VeLivePlayer,
        streamType: VeLivePlayerStreamType,
        error: VeLivePlayerError
    ) {
        playerLog(TAG, "[$tag] onMainBackupSwitch: streamType: $streamType; error: $error")
    }


    override fun onStatistics(
        player: VeLivePlayer,
        statistics: VeLivePlayerStatistics
    ) {
        playerLog(TAG, "[$tag] onStatistics: url: " + statistics.url)
        playerLog(
            TAG, "[$tag] onStatistics: fps: " + statistics.fps
                    + "; protocol: " + statistics.protocol
                    + "; format: " + statistics.format
        )
    }

    override fun onSnapshotComplete(player: VeLivePlayer, bitmap: Bitmap) {
        playerLog(TAG, "[$tag] onSnapshotComplete: ")
    }

    override fun onRenderVideoFrame(
        player: VeLivePlayer,
        videoFrame: VeLivePlayerVideoFrame
    ) {
        playerLog(TAG, "[$tag] onRenderVideoFrame: ")
    }

    override fun onRenderAudioFrame(
        player: VeLivePlayer,
        audioFrame: VeLivePlayerAudioFrame
    ) {
        playerLog(TAG, "[$tag] onRenderAudioFrame: ")
    }

    override fun onStreamFailedOpenSuperResolution(
        player: VeLivePlayer,
        error: VeLivePlayerError
    ) {
        playerLog(TAG, "[$tag] onStreamFailedOpenSuperResolution: error: $error")
    }

    override fun onAudioDeviceOpen(player: VeLivePlayer, sampleRate: Int, channels: Int, format: Int) {
        playerLog(TAG, "[$tag] onAudioDeviceOpen")
    }

    override fun onAudioDeviceClose(player: VeLivePlayer) {
        playerLog(TAG, "[$tag] onAudioDeviceClose")
    }

    override fun onAudioDeviceRelease(player: VeLivePlayer) {
        playerLog(TAG, "[$tag] onAudioDeviceRelease")
    }

    override fun onBinarySeiUpdate(player: VeLivePlayer, buffer: ByteBuffer?) {
        playerLog(TAG, "[$tag] onBinarySeiUpdate")
    }

    override fun onMonitorLog(player: VeLivePlayer, event: JSONObject?, tag: String?) {
        playerLog(TAG, "[$tag] onMonitorLog: event: $event; tag: $tag")
    }

    override fun onReportALog(player: VeLivePlayer, logLevel: Int, info: String?) {
        playerLog(TAG, "[$tag] onReportALog: logLevel: $logLevel; info: $info")
    }

    override fun onResolutionDegrade(player: VeLivePlayer, resolution: VeLivePlayerResolution?) {
        playerLog(TAG, "[$tag] onResolutionDegrade")
    }

    override fun onTextureRenderDrawFrame(player: VeLivePlayer, renderSurface: Surface?) {
        playerLog(TAG, "[$tag] onTextureRenderDrawFrame")
    }

    override fun onHeadPoseUpdate(
        player: VeLivePlayer,
        quatX: Float,
        quatY: Float,
        quatZ: Float,
        quatW: Float,
        posX: Float,
        posY: Float,
        posZ: Float
    ) {
        playerLog(TAG, "[$tag] onHeadPoseUpdate")
    }

    override fun onResponseSmoothSwitch(player: VeLivePlayer, success: Boolean, errorCode: Int) {
        playerLog(TAG, "[$tag] onResponseSmoothSwitch")
    }

    override fun onNetworkQualityChanged(player: VeLivePlayer, behavior: Int, detail: String?) {
        playerLog(TAG, "[$tag] onNetworkQualityChanged")
    }

    override fun onAudioVolume(player: VeLivePlayer, volumeInfo: VeLivePayerAudioVolume) {
        playerLog(TAG, "[$tag] onAudioVolume")
    }

    override fun onLoudness(player: VeLivePlayer, loudnessInfo: VeLivePayerAudioLoudnessInfo) {
        playerLog(TAG, "[$tag] onLoudness")
    }

    override fun onStreamFailedOpenSharpen(veLivePlayer: VeLivePlayer, error: VeLivePlayerError) {
        playerLog(TAG, "[$tag] onStreamFailedOpenSharpen: error: $error")
    }
}