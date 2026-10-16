// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.vod.function.fragment

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.fragment.app.viewModels
import com.byteplus.playerkit.player.AVPlayer
import com.byteplus.playerkit.player.PlayerEvent
import com.byteplus.playerkit.player.adapter.PlayerAdapter
import com.byteplus.playerkit.player.event.StatePrepared
import com.byteplus.playerkit.player.playback.VideoLayer
import com.byteplus.playerkit.player.playback.VideoLayerHost
import com.byteplus.playerkit.player.source.MediaSource
import com.byteplus.vod.scenekit.ui.video.layer.CastingModeLayer
import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer
import com.byteplus.vod.scenekit.ui.video.layer.TimeProgressBarLayer
import com.byteplus.vod.scenekit.ui.video.layer.TitleBarLayer
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer
import com.byteplus.vod.scenekit.ui.video.layer.dialog.CastingDeviceSearchDialogLayer
import com.byteplus.vod.scenekit.ui.video.layer.dialog.MoreDialogLayerSimple
import com.byteplus.vod.scenekit.ui.video.layer.dialog.SpeedSelectDialogLayer
import com.byteplus.vod.settingskit.CenteredToast
import com.byteplus.vodcast.api.CastDevice
import com.byteplus.vodcast.api.CastErrorCode
import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.CastSessionState
import com.byteplus.vodcast.api.IDiscovery
import com.byteplus.vodcast.api.LocalPlayerHook
import com.vertcdemo.core.utils.AppUtil
import com.videoone.vod.function.viewmodel.CastingViewModel
import com.videoone.vod.function.viewmodel.CastingViewModelFactory

class CastingFunctionFragment : VodFunctionFragment() {

    companion object {
        const val TAG = "CAST_DEMO"
    }

    private var currentMediaSource: MediaSource? = null

    /** 本地播放器钩子（B1 / B2 / B7）。生命周期与 Fragment view 绑定。 */
    private var localPlayerHook: LocalPlayerHook? = null

    /** 设备发现监听：用于按是否有可用设备切换投屏按钮显隐。 */
    private var castDeviceListener: IDiscovery.Listener? = null

    /**
     * 直接持有设备搜索弹窗 Layer 的引用，用于销毁时释放其对单例 discovery 的监听。
     * 不能在 onDestroyView 里临时 findLayer：用户按返回键时基类会先把 videoView 置空，
     * 导致 findLayer 返回 null、清理逻辑被跳过，进而泄漏 Fragment / Activity。
     */
    private var castDeviceSearchLayer: CastingDeviceSearchDialogLayer? = null

    private val viewModel: CastingViewModel by viewModels { CastingViewModelFactory() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        // Register cast SDK before super.onViewCreated(), because super will create
        // and bind layers that may access CastSdk immediately.
        CastSdk.register(AppUtil.applicationContext)
        super.onViewCreated(view, savedInstanceState)

        // Casting requires Google Play Services + a successfully installed impl. On devices
        // without it (or when bootstrap failed), keep the entry hidden and skip all casting
        // wiring so nothing can crash.
        if (!CastSdk.isAvailable()) {
            Log.w(TAG, "Casting unavailable (no Google Play Services or impl not installed); hiding cast UI")
            videoView.layerHost()?.findLayer(TitleBarLayer::class.java)?.enableCasting(false)
            return
        }

        // 把生命周期绑给 SDK（生命周期感知的 discovery start/stop）
        CastSdk.addLifecycleObserver(this)

        // 安装本地播放器钩子：把本地 AVPlayer 状态映射到 SDK，供 PlaybackBridge 在
        // 投屏 CONNECTED 时暂停本地、DISCONNECTED 时按远端进度恢复（B1 / B2 / B7）。
        installLocalPlayerHook()

        addCastingDataSourceListener()
        // Only reveal the cast button once at least one Chromecast device is discovered.
        observeCastDeviceAvailability()

        videoView.layerHost()?.findLayer(CastingDeviceSearchDialogLayer::class.java)
            ?.also { castDeviceSearchLayer = it }
            ?.setOnCastingDeviceSelectedListener { device ->
                viewModel.injectMediaSourceAndDevice(
                    currentMediaSource,
                    device,
                    getSpeed(),
                    getPlaybackProgress()
                )
            }
        videoView.layerHost()?.findLayer(SpeedSelectDialogLayer::class.java)
            ?.setSpeedSelectListener { speed ->
                viewModel.setSpeed(speed)
            }

        videoView.layerHost()?.findLayer(TimeProgressBarLayer::class.java)
            ?.setProgressSeekListener { progress ->
                viewModel.remoteSeekTo(progress)
            }

        observeData(view)
    }

    /**
     * 仅当发现至少一台 Chromecast 设备时才展示投屏按钮，无设备时隐藏，避免点击后无目标可投或误触。
     */
    private fun observeCastDeviceAvailability() {
        val discovery = CastSdk.discoveryOrNull() ?: return
        fun syncButton(devices: List<CastDevice>) {
            videoView.layerHost()?.findLayer(TitleBarLayer::class.java)
                ?.enableCasting(devices.isNotEmpty())
        }
        // Reflect the current snapshot immediately, then track changes.
        syncButton(discovery.currentDevices())
        castDeviceListener = object : IDiscovery.Listener {
            override fun onDevicesChanged(devices: List<CastDevice>) {
                syncButton(devices)
            }
        }.also { discovery.addListener(it) }
        discovery.start()
    }

    private fun installLocalPlayerHook() {
        val hook = object : LocalPlayerHook {
            override fun currentLocalPositionMs(): Long =
                videoView?.controller()?.player()?.currentPosition ?: 0L

            override fun currentLocalDurationMs(): Long =
                videoView?.controller()?.player()?.duration ?: 0L

            override fun isLocalCompleted(): Boolean =
                videoView?.controller()?.player()?.isCompleted == true

            override fun currentLocalSpeed(): Float =
                videoView?.controller()?.player()?.speed ?: 1f

            override fun pauseLocalPlayback() {
                val player = videoView?.controller()?.player() ?: return
                if (player.isInPlaybackState && !player.isPaused) {
                    Log.d(TAG, "LocalPlayerHook#pauseLocalPlayback")
                    player.pause()
                }
            }

            override fun resumeLocalPlayback(progressMs: Long) {
                val player = videoView?.controller()?.player() ?: return
                Log.d(TAG, "LocalPlayerHook#resumeLocalPlayback: progress=$progressMs")
                runCatching {
                    if (progressMs > 0L) player.seekTo(progressMs)
                    if (!player.isPlaying) player.start()
                }
            }
        }
        localPlayerHook = hook
        CastSdk.installLocalPlayerHook(hook)
    }

    private fun getPlaybackProgress(): Long {
        return videoView?.controller()?.player()?.currentPosition ?: 0L
    }

    private fun getSpeed(): Float {
        return videoView?.controller()?.player()?.speed ?: 1f
    }

    private fun observeData(view: View) {
        val avPlayer: AVPlayer? = videoView?.controller()?.player() as? AVPlayer

        avPlayer?.addPlayerListener { event ->
            if (event is StatePrepared) {
                val code = event.code()
                if (code == PlayerEvent.State.PREPARED ||
                    code == PlayerEvent.State.STARTED ||
                    code == PlayerEvent.State.COMPLETED ||
                    code == PlayerEvent.State.PAUSED
                ) {
                    // 投屏中本地不应继续播放
                    if (viewModel.inCastingState.value?.isCasting == true) {
                        Log.d(TAG, "addPlayerListener --- observeLiveData: 暂停本地播放")
                        view.post {
                            videoView?.player()?.pause()
                            viewModel.inCastingState.value?.let { dealCastingState(it) }
                        }
                    }
                }
            }
        }

        viewModel.inCastingState.observe(viewLifecycleOwner) { state ->
            dealCastingState(state)
        }
        viewModel.remoteDuration.observe(viewLifecycleOwner) {
            if (it != null && it != 0L) {
                videoView?.layerHost()?.findLayer(TimeProgressBarLayer::class.java)
                    ?.setCastingDuration(it)
            }
        }

        viewModel.remoteProgress.observe(viewLifecycleOwner) {
            if (it != null && it != 0L) {
                videoView?.layerHost()?.findLayer(TimeProgressBarLayer::class.java)
                    ?.setCastingProgress(it)
            }
        }

        viewModel.castError.observe(viewLifecycleOwner) { error ->
            error ?: return@observe
            val message = when (error.code) {
                CastErrorCode.SESSION_TAKEN_OVER ->
                    "The cast session was taken over by another device"
                CastErrorCode.SESSION_ENDED_BY_RECEIVER ->
                    "Casting ended by the receiver"
                CastErrorCode.SESSION_START_FAILED ->
                    "Failed to connect to the device, please try again"
                CastErrorCode.DEVICE_UNAVAILABLE ->
                    "The device is unavailable"
                CastErrorCode.MEDIA_LOAD_FAILED ->
                    "This video cannot be cast to the device"
                else -> null
            }
            message?.let { context?.let { ctx -> CenteredToast.show(ctx, it) } }
            // Consume the error so it is not re-shown on configuration change.
            viewModel.castError.value = null
        }
    }

    /**
     * 处理新协议无关的会话状态。
     * 注意：相比旧实现，这里**不再**在「非全屏」时强制 endSession（B10：允许非全屏触发投屏）。
     */
    private fun dealCastingState(state: CastSessionState) {
        // CastingMode UI 在「连接中 + 已投屏（含 LOADING/PLAYING/PAUSED 等）」时启用（B5）
        videoView?.layerHost()?.findLayer(TimeProgressBarLayer::class.java)
            ?.setInCastingMode(state == CastSessionState.CONNECTING || state.isCasting)

        Log.d(TAG, "observeLiveData: inCastingState = $state")
        if (state == CastSessionState.CONNECTING) {
            videoView?.layerHost()?.findLayer(LoadingLayer::class.java)?.animateShow(false)
        }

        if (state.isCasting) {
            // 投屏状态 暂停本地播放
            Log.d(
                TAG,
                "observeLiveData:isCasting state, 暂停本地播放,permission = " +
                        "${videoView?.player()?.isInPlaybackState == true}"
            )
            if (videoView?.player()?.isInPlaybackState == true) {
                Log.d(TAG, "observeLiveData: 暂停本地播放")
                videoView?.player()?.pause()
            }

            videoView?.layerHost()?.findLayer(LoadingLayer::class.java)?.animateDismiss()

            allowDismissOtherLayers(false)

            videoView?.layerHost()?.findLayer(CastingDeviceSearchDialogLayer::class.java)
                ?.animateDismiss()
            // 显示投屏 Layer
            videoView?.layerHost()?.findLayer(CastingModeLayer::class.java)
                ?.let { castingModeLayer ->
                    castingModeLayer.animateShow(false)
                    castingModeLayer.setCastingDeviceName(
                        viewModel.getSelectCastingDevice()?.name ?: "Chromecast"
                    )
                }
        } else {
            allowDismissOtherLayers(true)
        }
        videoView?.layerHost()?.findLayer(GestureLayer::class.java)
            ?.setInCastingMode(state.isCasting)

        videoView?.layerHost()?.findLayer(MoreDialogLayerSimple::class.java)
            ?.setInCasting(state.isCasting)

        if (state == CastSessionState.DISCONNECTED ||
            state == CastSessionState.IDLE ||
            state == CastSessionState.ERROR
        ) {
            videoView?.layerHost()?.findLayer(CastingModeLayer::class.java)
                ?.animateDismiss()
        }
    }

    private fun allowDismissOtherLayers(allow: Boolean) {
        val layerSize = videoView?.layerHost()?.layerSize() ?: 0
        for (i in 0 until layerSize) {
            val layer: VideoLayer? = videoView?.layerHost()?.findLayer(i)
            if (layer is DialogLayer) {
                layer.setDismissOtherLayers(allow)
            }
        }
    }

    private fun addCastingDataSourceListener() {
        val player = videoView.player()
        if (player is AVPlayer) {
            player.setMediaSourceUpdateListener(AVPlayer.MediaSourceUpdateListener { type, source ->
                activity?.runOnUiThread {
                    if (type == PlayerAdapter.MediaSourceUpdateReason.MEDIA_SOURCE_UPDATE_REASON_PLAY_INFO_FETCHED) {
                        Log.d(TAG, "onMediaSourceUpdate: source = $source")
                        currentMediaSource = source
                    }
                }
            })
        }
    }

    override fun addFunctionLayer(layerHost: VideoLayerHost) {
        // 新协议无关入口：DialogLayer 内部通过 CastSdk 拿 discovery / controller，无需外部传入 adapter
        layerHost.addLayer(CastingDeviceSearchDialogLayer())
    }

    override fun preInsertLayer(layerHost: VideoLayerHost?) {
        layerHost?.addLayer(
            CastingModeLayer(
                onClickSwitchDevice = {
                    // B10：非全屏也允许切换设备弹窗，由 DialogLayer 自身决定显示
                    videoView.layerHost()?.findLayer(CastingDeviceSearchDialogLayer::class.java)
                        ?.show()
                },
                onClickEndSession = {
                    viewModel.endSession()
                }
            )
        )
    }

    override fun onDestroyView() {
        // 防止跨页面持有上一个 Fragment 的本地播放器
        if (localPlayerHook != null) {
            CastSdk.installLocalPlayerHook(null)
            localPlayerHook = null
        }
        castDeviceListener?.let { listener ->
            CastSdk.discoveryOrNull()?.removeListener(listener)
            castDeviceListener = null
        }
        // 单例 discovery 会通过弹窗 Layer 的监听器长期持有本 Fragment / Activity。
        // 用提前持有的字段释放，而不是 findLayer：返回键退出时基类已把 videoView 置空，
        // findLayer 会拿不到 Layer 导致清理被跳过。
        castDeviceSearchLayer?.releaseDiscovery()
        castDeviceSearchLayer = null
        super.onDestroyView()
    }
}
