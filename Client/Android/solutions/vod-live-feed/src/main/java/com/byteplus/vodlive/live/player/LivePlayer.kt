// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live.player

import android.content.Context
import android.graphics.Bitmap
import android.graphics.SurfaceTexture
import android.os.SystemClock
import android.view.Surface
import android.view.TextureView
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.widget.FrameLayout
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.utils.playerLog
import com.ss.videoarch.liveplayer.ILivePlayer
import com.ss.videoarch.liveplayer.VeLivePlayer
import com.ss.videoarch.liveplayer.VeLivePlayerConfiguration
import com.ss.videoarch.liveplayer.VeLivePlayerDef
import com.ss.videoarch.liveplayer.VeLivePlayerProperty
import com.ss.videoarch.liveplayer.VideoLiveManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class LivePlayer(
    context: Context,
    var scene: PlayerScene = PlayerScene.DEFAULT,
    val identity: String = "${SystemClock.uptimeMillis()}"
) {
    init {
        playerLog(TAG, "CREATE [$identity]")
    }

    var roomId: String = ""
        private set

    private var isPreloading: Boolean = false

    val displayMode = DisplayMode()

    private var snapshotBitmap: Bitmap? = null

    fun clearSnapshot(): Bitmap? {
        val snapshot = snapshotBitmap ?: return null
        snapshotBitmap = null
        return snapshot
    }

    fun createSnapshot(): Bitmap? {
        val videoView = this.videoView ?: return null
        return runCatching {
            if (DOWN_SAMPLE_SNAPSHOT) {
                // Down-sample the video to a smaller size & convert to RGB_565
                if (!videoView.isAvailable || videoView.width <= 0 || videoView.height <= 0) {
                    return null
                }
                val bitmap = Bitmap.createBitmap(
                    videoView.resources.displayMetrics,
                    videoView.width / 2,
                    videoView.height / 2,
                    Bitmap.Config.RGB_565
                )
                videoView.getBitmap(bitmap)
            } else {
                videoView.bitmap
            }
        }.getOrNull()
    }

    fun snapshot() {
        snapshotBitmap = createSnapshot()
    }

    private val playerObserver = object : VeLivePlayerObserverAdapter(identity) {
        override fun onFirstAudioFrameRender(player: VeLivePlayer, isFirstFrame: Boolean) {
            super.onFirstAudioFrameRender(player, isFirstFrame)
            mainScope.launch {
                playerLog(TAG, "[$identity] onFirstAudioFrameRender: isPreloading: $isPreloading")
                if (isPreloading) {
                    isPreloading = false
                    player.pause()
                }
            }
        }

        override fun onVideoSizeChanged(player: VeLivePlayer, width: Int, height: Int) {
            displayMode.setVideoSize(width, height)
        }
    }

    private val player: VeLivePlayer by lazy {
        VideoLiveManager(context.applicationContext).apply {
            val config = VeLivePlayerConfiguration().apply {
                enableSei = false
                statisticsCallbackInterval = 5 // per seconds
                enableStatisticsCallback = false
            }

            setConfig(config)
            setRenderFillMode(VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit)
            setObserver(playerObserver)

            // FIXME: 暂时关闭离屏渲染，否则会导致播放器无渲染
            // 1.42.3 之后的版本无此问题
            setProperty(
                VeLivePlayerProperty.VeLivePlayerKeySetOpenTextureRender,
                ILivePlayer.DISABLE
            )

            // Set the start-up buffer time to 1000ms (Default: 3000ms)
            setProperty(
                VeLivePlayerProperty.VeLivePlayerKeySetStartPlayAudioBufferThresholdMs, 1000
            )
        }
    }

    private var playUrl: String? = null

    private fun setPlayUrl(url: String) {
        if (playUrl == url) return
        playUrl = url
        player.setPlayUrl(url)
    }

    fun startWithUrl(item: LiveFeedItem, mute: Boolean = false, preload: Boolean = false) {
        val liveUrl = item.liveUrl ?: return
        this.roomId = item.roomId
        setPlayUrl(liveUrl)
        start(mute, preload)
    }

    fun start(mute: Boolean = false, preload: Boolean = false) {
        playerLog(TAG, "[$identity] start: mute: $mute; preload: $preload")
        this.isPreloading = preload
        player.setMute(mute || preload)
        player.play()
    }

    fun stop() {
        playerLog(TAG, "[$identity] stop")
        player.stop()
    }

    fun release() {
        videoView?.detachFromParent()
        videoView = null

        playerLog(TAG, "RELEASE [$identity]")
        player.destroy()
    }

    private var videoView: TextureView? = null

    private val textureListener = LivePlayerTextureListener(this)

    fun attach(containerView: FrameLayout) {
        val context = containerView.context

        val displayView = containerView.getChildAt(0)
        if (displayView != null && videoView === displayView) {
            playerLog(TAG, "skip attach")
            return
        }
        playerLog(TAG, "attach")

        containerView.removeAllViews()

        val videoView = this.videoView ?: createTextureView(context, textureListener).also {
            this.videoView = it
        }

        videoView.detachFromParent()

        containerView.addView(videoView, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
        displayMode.updateView(containerView, videoView)
    }

    fun detach() {
        this.videoView?.detachFromParent()
        displayMode.setContainerView(null)
    }

    fun setSurfaceTexture(surface: SurfaceTexture?) {
        if (surface == null) {
            player.setSurface(null)
        } else {
            player.setSurface(Surface(surface))
        }
    }

    fun onFirstSurfaceTextureUpdated() {
        if (playerObserver.isFirstVideoFrameRendered) {
            // Fake First Frame Rendered
            playerLog(TAG, "Fake first frame rendered")
        }
    }

    var isShared = false
        private set

    fun updateScene(scene: PlayerScene, isShared: Boolean = false) {
        this.scene = scene
        this.isShared = isShared
    }

    companion object {
        private const val TAG = "LivePlayer"

        private const val DOWN_SAMPLE_SNAPSHOT = false

        private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

        private fun View.detachFromParent() {
            val parent = this.parent as? ViewGroup ?: return
            parent.removeView(this)
        }

        private fun createTextureView(
            context: Context,
            listener: TextureView.SurfaceTextureListener
        ) =
            TextureView(context).apply {
                surfaceTextureListener = listener
            }
    }
}