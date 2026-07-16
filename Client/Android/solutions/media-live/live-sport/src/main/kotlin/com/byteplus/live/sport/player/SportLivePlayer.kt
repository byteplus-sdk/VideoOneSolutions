// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.player

import android.content.Context
import android.graphics.SurfaceTexture
import android.text.TextUtils
import android.util.Log
import android.view.Surface
import android.view.TextureView
import com.ss.videoarch.liveplayer.ILivePlayer
import com.ss.videoarch.liveplayer.VeLivePlayer
import com.ss.videoarch.liveplayer.VeLivePlayerConfiguration
import com.ss.videoarch.liveplayer.VeLivePlayerDef
import com.ss.videoarch.liveplayer.VeLivePlayerError
import com.ss.videoarch.liveplayer.VeLivePlayerProperty
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics
import com.ss.videoarch.liveplayer.VeLivePlayerStreamData
import com.ss.videoarch.liveplayer.VideoLiveManager
import org.json.JSONObject

/**
 * Single entry point to the TTSDK [VeLivePlayer] for the sports-streaming demo.
 *
 * Why a dedicated wrapper instead of reusing live-player's `LivePlayerImpl`:
 * that one is coupled to the `PreferenceUtil` singleton and cannot host the
 * independent, per-instance configuration this scene needs (multi-camera switch,
 * compare page double instances). See `.localFiles/live-sport/TECH_DESIGN.md`.
 *
 * Responsibilities:
 *  - Own exactly one [VeLivePlayer] instance at a time (SDK recommends a fresh
 *    instance per playback; never reuse after [destroy]).
 *  - Render onto a caller-provided [TextureView]; the [SurfaceTexture] survives
 *    player rebuilds, so RTM→FLV fallback only re-attaches the cached [Surface].
 *  - Encapsulate the RTM-first → FLV fallback strategy (see `.localFiles/RTM规则`).
 *
 * Threading: all SDK calls happen on the thread that drives this object
 * (the UI thread in practice). Listener callbacks are posted by the SDK and are
 * forwarded as-is.
 */
class SportLivePlayer(context: Context) {

    // Hold only the application context: the TTSDK strategy manager is a global
    // singleton that retains the VideoLiveManager (and its context) in a static
    // listener map even after destroy(), so passing an Activity here leaks it.
    private val context: Context = context.applicationContext

    /** UI-facing callbacks. All methods have empty defaults so callers override only what they need. */
    interface Listener {
        fun onFirstFrame() {}
        fun onError(code: Int, msg: String) {}
        fun onStallStart() {}
        fun onStallEnd() {}
        fun onVideoSizeChanged(width: Int, height: Int) {}
        /**
         * The playing tier changed.
         * @param byAbr true when the ABR algorithm picked it automatically;
         *        false when it resulted from a manual [switchResolution] call.
         */
        fun onResolutionSwitch(resolution: Resolution, byAbr: Boolean) {}
        fun onStats(stats: SportPlayerStats) {}

        /**
         * RTM playback failed and the player has been rebuilt to play FLV.
         * The UI should refresh capability availability (resolution / ABR may
         * now apply if the FLV config carries multiple tiers).
         */
        fun onProtocolFallback() {}

        /** Super-resolution failed to open; the UI should turn its toggle back off. */
        fun onSrFailed() {}

        /** Sharpen failed to open; the UI should turn its toggle back off. */
        fun onSharpenFailed() {}
    }

    private var player: VeLivePlayer? = null
    private var listener: Listener? = null
    private var config: SportPlayerConfig? = null
    private var boundTextureView: TextureView? = null
    private var renderFillMode: SportRenderFillMode = SportRenderFillMode.ASPECT_FIT

    /**
     * Cached render target. The TextureView's SurfaceTexture is stable across
     * player rebuilds, so we keep the [Surface] and re-apply it whenever a new
     * [VeLivePlayer] is created (e.g. RTM→FLV fallback).
     */
    private var surface: Surface? = null

    /** Which protocol the current player instance is pulling. */
    private var playingFlv: Boolean = false

    /** Guard so RTM→FLV fallback happens at most once per [play] session. */
    private var fallbackDone: Boolean = false

    /**
     * Desired mute state, kept independent of the player lifecycle. The SDK
     * player is created lazily in [buildAndStart] (and rebuilt on RTM→FLV
     * fallback), so we remember the intent here and re-apply it after every
     * (re)build instead of dropping calls made before the player exists.
     */
    private var muted: Boolean = false

    /** True once [destroy] is called; the instance must not be reused afterwards. */
    private var destroyed: Boolean = false

    /**
     * Whether resolution switching / ABR currently applies. RTM is single-stream,
     * so this is only true while pulling FLV with more than one tier.
     */
    val isResolutionSwitchAvailable: Boolean
        get() = playingFlv && (config?.flvStreams?.size ?: 0) > 1

    /** True while the active player is pulling an FLV stream (post-fallback included). */
    val isPlayingFlv: Boolean
        get() = playingFlv

    fun setListener(l: Listener) {
        listener = l
    }

    fun setConfig(config: SportPlayerConfig) {
        this.config = config
    }

    /**
     * Bind the render surface. Must be called before [play]. The listener keeps
     * the cached [Surface] up to date so player rebuilds can re-attach without
     * recreating the TextureView.
     */
    fun bindTextureView(view: TextureView) {
        boundTextureView = view
        view.surfaceTextureListener = object : TextureView.SurfaceTextureListener {
            override fun onSurfaceTextureAvailable(st: SurfaceTexture, width: Int, height: Int) {
                if (boundTextureView !== view) return
                Log.i(TAG, "onSurfaceTextureAvailable ${width}x$height, attaching surface to player=${player != null}")
                surface?.release()
                surface = Surface(st)
                player?.setSurface(surface)
            }

            override fun onSurfaceTextureSizeChanged(st: SurfaceTexture, width: Int, height: Int) {
                if (boundTextureView !== view) return
                Log.d(TAG, "onSurfaceTextureSizeChanged ${width}x$height")
            }

            override fun onSurfaceTextureDestroyed(st: SurfaceTexture): Boolean {
                if (boundTextureView !== view) return true
                Log.i(TAG, "onSurfaceTextureDestroyed")
                surface?.release()
                surface = null
                return true
            }

            override fun onSurfaceTextureUpdated(st: SurfaceTexture) {}
        }
        // TextureView may already be attached (e.g. re-bind on a recycled view).
        if (view.isAvailable) {
            Log.i(TAG, "bindTextureView: surface already available, reuse it")
            surface?.release()
            surface = Surface(view.surfaceTexture)
            player?.setSurface(surface)
        } else {
            Log.i(TAG, "bindTextureView: surface not yet available, waiting for callback")
        }
    }

    /**
     * Build a fresh player from [config] and start playback. For [PlayStrategy.RTM_FIRST]
     * this starts with RTM; an [VeLivePlayer.onError] then triggers [fallbackToFlv].
     */
    fun play() {
        val cfg = config ?: error("setConfig must be called before play")
        check(!destroyed) { "SportLivePlayer is destroyed and cannot be reused" }
        fallbackDone = false
        val startWithFlv = cfg.strategy == PlayStrategy.FLV_ONLY ||
            cfg.singleStream?.format == SingleStreamFormat.FLV
        Log.i(TAG, "play() strategy=${cfg.strategy} startWithFlv=$startWithFlv flvStreams=${cfg.flvStreams.size} single=${cfg.singleStream?.format} abr=${cfg.enableABR} lowLatencyFlv=${cfg.enableLowLatencyFlv} sr=${cfg.enableSR} sharpen=${cfg.enableSharpen}")
        buildAndStart(cfg, useFlv = startWithFlv)
    }

    fun pause() {
        player?.pause()
    }

    fun stop() {
        player?.stop()
    }

    /**
     * Stop, release and forget the player instance. After this the object is
     * inert; create a new [SportLivePlayer] for further playback.
     */
    fun destroy() {
        destroyed = true
        player?.destroy()
        player = null
        surface?.release()
        surface = null
    }

    /**
     * Manually switch FLV resolution tier. No-op (returns false) for RTM since it
     * is single-stream. The result also arrives asynchronously via
     * [Listener.onResolutionSwitch].
     *
     * @return true if the SDK accepted the switch request.
     */
    fun switchResolution(r: Resolution): Boolean {
        return player?.switchResolution(toSdkResolution(r)) ?: false
    }

    fun setMute(mute: Boolean) {
        muted = mute
        player?.setMute(mute)
    }

    fun setVolume(v: Float) {
        player?.setPlayerVolume(v)
    }

    /** Toggle super-resolution at runtime. Works on both RTM and FLV. */
    fun setSrEnabled(enable: Boolean) {
        player?.setEnableSuperResolution(enable)
    }

    /** Toggle sharpen at runtime. Works on both RTM and FLV. */
    fun setSharpenEnabled(enable: Boolean) {
        player?.setEnableSharpen(enable)
    }

    fun setRenderFillMode(mode: SportRenderFillMode) {
        renderFillMode = mode
        player?.let { applyRenderFillMode(it) }
    }

    // region internal

    private fun buildAndStart(cfg: SportPlayerConfig, useFlv: Boolean) {
        // Always start from a clean instance; the SDK does not support reusing a
        // player across stream-data changes reliably.
        player?.destroy()

        val p = VideoLiveManager(context)
        player = p
        playingFlv = useFlv
        Log.i(TAG, "buildAndStart useFlv=$useFlv, new VideoLiveManager created")

        val sdkConfig = VeLivePlayerConfiguration().apply {
            enableSei = cfg.enableSei
            enableStatisticsCallback = true
            statisticsCallbackInterval = STATS_INTERVAL_SEC
        }
        p.setConfig(sdkConfig)
        p.setObserver(observer)
        applyRenderFillMode(p)

        // ABR is an FLV-only algorithm; only enable it when actually pulling FLV.
        val abrOn = useFlv && cfg.enableABR
        Log.d(TAG, "buildAndStart: ABR algorithm ${if (abrOn) "ENABLE" else "DISABLE"}")
        p.setProperty(
            VeLivePlayerProperty.VeLivePlayerKeySetABRAlgorithm,
            if (abrOn) ILivePlayer.ENABLE else ILivePlayer.DISABLE,
        )

        // Low-latency FLV is configured via a JSON property and only matters for FLV.
        if (useFlv && cfg.enableLowLatencyFlv) {
            Log.d(TAG, "buildAndStart: enabling low-latency FLV")
            applyLowLatencyFlv(p)
        }

        when (cfg.strategy) {
            // Single user-provided URL: let the SDK auto-detect the protocol
            // (RTM / FLV / HLS / RTMPS) from the URL scheme & extension. See
            // VeLivePlayer_API.md §2.5 — setPlayUrl is the dedicated single-URL
            // entry point and does the protocol sniffing internally, so we must
            // NOT also call setPlayStreamData (that would override it).
            PlayStrategy.SINGLE_STREAM -> {
                val url = cfg.singleStream?.url ?: error("singleStream is required for SINGLE_STREAM")
                Log.i(TAG, "buildAndStart: setPlayUrl format=${cfg.singleStream?.format} url=$url")
                p.setPlayUrl(url)
            }
            PlayStrategy.FLV_ONLY -> p.setPlayStreamData(buildFlvStreamData(cfg))
            PlayStrategy.RTM_FIRST -> p.setPlayStreamData(
                if (useFlv) buildFlvStreamData(cfg) else buildRtmStreamData(cfg)
            )
        }

        if (surface != null) {
            Log.i(TAG, "buildAndStart: attaching cached surface")
            p.setSurface(surface)
        } else {
            Log.w(TAG, "buildAndStart: surface is NULL — playback will have no video until surface becomes available")
        }

        // SR/Sharpen are runtime toggles but we apply the initial state up front.
        if (cfg.enableSR) p.setEnableSuperResolution(true)
        if (cfg.enableSharpen) p.setEnableSharpen(true)

        // Re-apply the desired mute state: the player is brand new here, so any
        // setMute() made before this build (or before an RTM→FLV rebuild) would
        // otherwise be lost.
        p.setMute(muted)

        Log.i(TAG, "buildAndStart: calling play()")
        p.play()
    }

    /**
     * RTM-first fallback: a fatal RTM error tears down the player and rebuilds it
     * on FLV. Triggered at most once; a subsequent FLV failure surfaces normally
     * via [Listener.onError].
     */
    private fun fallbackToFlv() {
        val cfg = config ?: return
        if (cfg.strategy != PlayStrategy.RTM_FIRST || fallbackDone || destroyed) return
        fallbackDone = true
        Log.w(TAG, "RTM playback failed, falling back to FLV")
        buildAndStart(cfg, useFlv = true)
        listener?.onProtocolFallback()
    }

    private fun applyLowLatencyFlv(p: VeLivePlayer) {
        // Per VeLivePlayer_API.md §3.2: low-latency FLV (2-3s) is enabled through
        // a JSON payload, not a plain integer property.
        val json = JSONObject().apply { put("EnableLowLatencyFLV", 1) }
        p.setProperty(VeLivePlayerProperty.VeLivePlayerKeySetParamsLowLatencyFLV, json)
    }

    private fun buildRtmStreamData(cfg: SportPlayerConfig): VeLivePlayerStreamData {
        Log.i(TAG, "buildRtmStreamData url=${cfg.rtmUrl}")
        val stream = VeLivePlayerStreamData.VeLivePlayerStream().apply {
            url = cfg.rtmUrl
            format = VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatRTM
            streamType = VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain
            resolution = toSdkResolution(Resolution.ORIGIN)
        }
        return VeLivePlayerStreamData().apply {
            // RTM is single-stream: no ABR, no multi-tier, no default-resolution juggling.
            mainStreamList = arrayListOf(stream)
            defaultFormat = VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatRTM
        }
    }

    private fun buildFlvStreamData(cfg: SportPlayerConfig): VeLivePlayerStreamData {
        cfg.flvStreams.forEachIndexed { i, s ->
            Log.i(TAG, "buildFlvStreamData[$i] res=${s.resolution} bitrate=${s.bitrateKbps} url=${s.url}")
        }
        Log.i(TAG, "buildFlvStreamData enableABR=${cfg.enableABR} defaultResolution=${cfg.defaultResolution}")
        val streams = cfg.flvStreams.map { spec ->
            VeLivePlayerStreamData.VeLivePlayerStream().apply {
                url = spec.url
                // ABR currently only supports FLV; bitrate must match the transcode config.
                format = VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatFLV
                streamType = VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain
                resolution = toSdkResolution(spec.resolution)
                bitrate = spec.bitrateKbps
            }
        }
        return VeLivePlayerStreamData().apply {
            enableABR = cfg.enableABR
            mainStreamList = ArrayList(streams)
            defaultFormat = VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatFLV
            cfg.defaultResolution?.let { defaultResolution = toSdkResolution(it) }
        }
    }

    private val observer = object : SportPlayerObserverAdapter() {
        override fun onError(p: VeLivePlayer?, error: VeLivePlayerError?) {
            val code = error?.mErrorCode ?: ERROR_CODE_UNKNOWN
            val msg = error?.mErrorMsg.orEmpty()
            val subCode = error?.mSubCode ?: 0
            Log.e(TAG, "onError code=$code subCode=$subCode msg=$msg playingFlv=$playingFlv fallbackDone=$fallbackDone")
            // Only the initial RTM attempt should fall back; once on FLV (or after
            // a fallback) the error is real and surfaces to the UI.
            if (config?.strategy == PlayStrategy.RTM_FIRST && !playingFlv && !fallbackDone) {
                fallbackToFlv()
            } else {
                listener?.onError(code, msg)
            }
        }

        override fun onFirstVideoFrameRender(p: VeLivePlayer?, isFirstFrame: Boolean) {
            Log.i(TAG, "onFirstVideoFrameRender isFirstFrame=$isFirstFrame")
            listener?.onFirstFrame()
        }

        override fun onFirstAudioFrameRender(p: VeLivePlayer?, isFirstFrame: Boolean) {
            Log.i(TAG, "onFirstAudioFrameRender isFirstFrame=$isFirstFrame")
        }

        override fun onStallStart(p: VeLivePlayer?) {
            Log.w(TAG, "onStallStart")
            listener?.onStallStart()
        }

        override fun onStallEnd(p: VeLivePlayer?) {
            Log.i(TAG, "onStallEnd")
            listener?.onStallEnd()
        }

        override fun onPlayerStatusUpdate(
            p: VeLivePlayer?,
            status: VeLivePlayerDef.VeLivePlayerStatus?,
        ) {
            Log.i(TAG, "onPlayerStatusUpdate status=$status")
        }

        override fun onVideoSizeChanged(p: VeLivePlayer?, width: Int, height: Int) {
            Log.i(TAG, "onVideoSizeChanged ${width}x$height")
            listener?.onVideoSizeChanged(width, height)
        }

        override fun onResolutionSwitch(
            p: VeLivePlayer?,
            resolution: VeLivePlayerDef.VeLivePlayerResolution?,
            error: VeLivePlayerError?,
            reason: VeLivePlayerDef.VeLivePlayerResolutionSwitchReason?,
        ) {
            Log.i(TAG, "onResolutionSwitch res=${resolution?.resolutionStr} reason=$reason err=${error?.mErrorMsg}")
            // VeLiveplayerResolutionSwitchByAuto == triggered by the ABR algorithm;
            // anything else (Manual) is a result of our switchResolution() call.
            val byAbr = reason ==
                VeLivePlayerDef.VeLivePlayerResolutionSwitchReason.VeLiveplayerResolutionSwitchByAuto
            listener?.onResolutionSwitch(fromSdkResolution(resolution), byAbr)
        }

        private var statsLogCount = 0
        override fun onStatistics(p: VeLivePlayer?, statistics: VeLivePlayerStatistics?) {
            statistics ?: return
            // Log the first few stats ticks (and then every 5s) to confirm the
            // stream is actually flowing without flooding logcat.
            if (statsLogCount < 3 || statsLogCount % 5 == 0) {
                Log.i(TAG, "onStatistics delay=${statistics.delayMs}ms bitrate=${statistics.bitrate}kbps fps=${statistics.fps} ${statistics.width}x${statistics.height} codec=${statistics.videoCodec} hwDecode=${statistics.isHardwareDecode} url=${statistics.url}")
            }
            statsLogCount++
            // bytevc1 is the SDK's internal name for H.265; present it the same way
            // live-player does for consistency across the app.
            val codec = if (TextUtils.equals(statistics.videoCodec, "bytevc1")) {
                "H.265"
            } else {
                statistics.videoCodec.orEmpty()
            }
            listener?.onStats(
                SportPlayerStats(
                    delayMs = statistics.delayMs,
                    bitrateKbps = statistics.bitrate,
                    fps = statistics.fps,
                    videoCodec = codec,
                    width = statistics.width,
                    height = statistics.height,
                )
            )
        }

        override fun onStreamFailedOpenSuperResolution(p: VeLivePlayer?, error: VeLivePlayerError?) {
            Log.w(TAG, "super-resolution failed: ${error?.mErrorMsg}")
            listener?.onSrFailed()
        }

        override fun onStreamFailedOpenSharpen(p: VeLivePlayer?, error: VeLivePlayerError?) {
            Log.w(TAG, "sharpen failed: ${error?.mErrorMsg}")
            listener?.onSharpenFailed()
        }
    }

    private fun toSdkResolution(r: Resolution): VeLivePlayerDef.VeLivePlayerResolution =
        VeLivePlayerDef.VeLivePlayerResolution(r.sdkValue)

    private fun fromSdkResolution(r: VeLivePlayerDef.VeLivePlayerResolution?): Resolution =
        Resolution.from(r?.resolutionStr)

    private fun applyRenderFillMode(p: VeLivePlayer) {
        val sdkMode = when (renderFillMode) {
            SportRenderFillMode.ASPECT_FIT ->
                VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit
            SportRenderFillMode.ASPECT_FILL ->
                VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFill
            SportRenderFillMode.FULL_FILL ->
                VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeFullFill
        }
        p.setRenderFillMode(sdkMode)
    }

    // endregion

    companion object {
        private const val TAG = "SportLivePlayer"

        /** 1s statistics cadence so the delay/bitrate overlays update smoothly. */
        private const val STATS_INTERVAL_SEC = 1

        /** Surfaced when the SDK reports an error without a code. */
        private const val ERROR_CODE_UNKNOWN = -999
    }
}
