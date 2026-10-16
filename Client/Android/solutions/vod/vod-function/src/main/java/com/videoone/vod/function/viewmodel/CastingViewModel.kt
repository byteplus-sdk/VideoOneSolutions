// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.vod.function.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.byteplus.playerkit.player.source.MediaSource
import com.byteplus.vodcast.api.CastDevice
import com.byteplus.vodcast.api.CastError
import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.api.ICastController
import com.byteplus.vodcast.api.LoadOptions
import com.byteplus.vodcast.api.MediaItem
import com.byteplus.vodcast.api.MediaMetadata

/**
 * 投屏播控 ViewModel（M2 重构版）。
 *
 * - 通过 [CastSdk.controller] 获取 [ICastController]，不再依赖任何旧入口（ICastAdapter / ChromecastAdapter）。
 * - 仅在 [CastSessionState.canEmitProgress] 时把进度回调到 LiveData。
 */
class CastingViewModel : ViewModel() {

    companion object {
        const val TAG = "CAST_DEMO"
    }

    /** 当前会话状态，默认 IDLE。 */
    val inCastingState: MutableLiveData<CastSessionState> = MutableLiveData(CastSessionState.IDLE)

    /** 远端进度（仅 PLAYING / PAUSED / BUFFERING 等可发进度状态下更新）。 */
    val remoteProgress: MutableLiveData<Long> = MutableLiveData(0L)

    /** 远端总时长。 */
    val remoteDuration: MutableLiveData<Long> = MutableLiveData(0L)

    /** 当前选中设备。 */
    val selectedDevice: MutableLiveData<CastDevice?> = MutableLiveData(null)

    /** 最近一次 SDK 错误，供 UI 弹出提示后自行清空。 */
    val castError: MutableLiveData<CastError?> = MutableLiveData(null)

    /** 注意：构造时 SDK 必须已 register；若投屏不可用（如无 Google Play Services）则为 null，所有调用安全降级。 */
    private val controller: ICastController? = CastSdk.controllerOrNull()

    private val listener = object : ICastController.Listener {
        override fun onStateChanged(state: CastSessionState) {
            Log.d(TAG, "onStateChanged: $state")
            inCastingState.value = state
        }

        override fun onProgressChanged(progressMs: Long, durationMs: Long) {
            // 仅在 canEmitProgress 状态下更新（R-PROGRESS）
            val state = inCastingState.value
            if (state != null && state.canEmitProgress) {
                remoteProgress.value = progressMs
                remoteDuration.value = durationMs
            }
        }

        override fun onError(error: CastError) {
            Log.w(TAG, "onError: $error")
            castError.value = error
        }

        override fun onDeviceChanged(device: CastDevice?) {
            Log.d(TAG, "onDeviceChanged: $device")
            selectedDevice.value = device
        }
    }

    init {
        controller?.addListener(listener)
    }

    /**
     * 注入媒体源 + 目标设备：内部组装 MediaItem，先 connect 后 load。
     */
    fun injectMediaSourceAndDevice(
        mediaSource: MediaSource?,
        device: CastDevice?,
        currentSpeed: Float = 1f,
        progress: Long = 0L
    ) {
        Log.d(TAG, "injectMediaSourceAndDevice: source=$mediaSource, device=$device, speed=$currentSpeed, progress=$progress")
        val controller = this.controller ?: return
        device ?: return
        val item = composeMediaItem(mediaSource, currentSpeed, progress) ?: return
        selectedDevice.value = device
        controller.connect(device)
        controller.load(
            item,
            LoadOptions(autoplay = true, playPositionMs = progress, speed = currentSpeed)
        )
    }

    fun endSession() {
        controller?.endSession()
    }

    fun setSpeed(speed: Float) {
        controller?.setSpeed(speed)
    }

    fun remoteSeekTo(progress: Long) {
        controller?.seekTo(progress)
    }

    fun getSelectCastingDevice(): CastDevice? = selectedDevice.value

    fun isCastingState(): Boolean = inCastingState.value?.isCasting == true

    /** 把 PlayerKit MediaSource 转协议无关 [MediaItem]；缺关键字段返回 null。 */
    private fun composeMediaItem(
        mediaSource: MediaSource?,
        currentSpeed: Float,
        progress: Long
    ): MediaItem? {
        mediaSource ?: return null
        val url = mediaSource.tracks?.firstOrNull()?.url ?: return null
        val title = mediaSource.mediaId
        val coverUrl = mediaSource.coverUrl
        return MediaItem(
            contentUrl = url,
            startPositionMs = progress,
            speed = currentSpeed,
            autoplay = true,
            metadata = MediaMetadata(title = title, coverUrl = coverUrl)
        )
    }

    override fun onCleared() {
        controller?.removeListener(listener)
        controller?.disconnect(true)
        super.onCleared()
    }
}
