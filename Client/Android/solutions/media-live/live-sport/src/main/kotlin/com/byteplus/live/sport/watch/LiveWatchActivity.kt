// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch

import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.util.Log
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.TextureView
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.constraintlayout.widget.Guideline
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.byteplus.live.sport.R
import com.byteplus.live.sport.data.SportChannel
import com.byteplus.live.sport.data.SportChannelRepo
import com.byteplus.live.sport.fullscreen.LandscapeCameraPanel
import com.byteplus.live.sport.fullscreen.LandscapeCommentComposer
import com.byteplus.live.sport.fullscreen.LandscapeController
import com.byteplus.live.sport.fullscreen.LandscapeGiftPanel
import com.byteplus.live.sport.fullscreen.LandscapePlayerSettingsPanel
import com.byteplus.live.sport.fullscreen.LandscapeQualityPanel
import com.byteplus.live.sport.fullscreen.OrientationSensorHelper
import com.byteplus.live.sport.keyboard.KeyboardHeightProvider
import com.byteplus.live.sport.player.PlayStrategy
import com.byteplus.live.sport.player.PullProtocolOption
import com.byteplus.live.sport.player.Resolution
import com.byteplus.live.sport.player.SingleStream
import com.byteplus.live.sport.player.SingleStreamFormat
import com.byteplus.live.sport.player.SportPlayerConfig
import com.byteplus.live.sport.player.SportRenderFillMode
import com.byteplus.live.sport.player.SportLivePlayer
import com.byteplus.live.sport.player.SportPlayerStats
import com.byteplus.live.sport.stream.CustomStreamFormat
import com.byteplus.live.sport.stream.CustomStreamSettingsBinder
import com.byteplus.live.sport.stream.CustomStreamSettingsPanel
import com.byteplus.live.sport.stream.CustomStreamUrl
import com.byteplus.live.sport.stream.CustomStreamUrlParser
import com.byteplus.live.sport.watch.camera.CameraListAdapter
import com.byteplus.live.sport.watch.comment.CommentSpacingDecoration
import com.byteplus.live.sport.watch.comment.LiveCommentAdapter
import com.byteplus.live.sport.watch.comment.LiveCommentItem
import com.byteplus.live.sport.watch.danmaku.DanmakuView
import com.byteplus.live.sport.watch.gift.GiftNoticeData
import com.byteplus.live.sport.watch.gift.GiftNoticeTrayHost
import com.byteplus.live.sport.watch.like.LikeBurstView
import com.byteplus.live.sport.watch.like.ThumbFloatingView
import com.byteplus.live.sport.watch.panel.GiftBinder
import com.byteplus.live.sport.watch.panel.GiftPanel
import com.byteplus.live.sport.watch.panel.PlayerSettingsBinder
import com.byteplus.live.sport.watch.panel.PlayerSettingsPanel

/**
 * Live Watch page — playback + chat + interactions for a single sports stream.
 *
 * Five vertical regions: Top / Player / Camera / Chat (RecyclerView) /
 * Actions (input + gift + settings).
 *
 * Soft-keyboard handling (input bar follows the IME):
 *  - Manifest declares `windowSoftInputMode=adjustNothing` so the system
 *    never resizes or pans the window.
 *  - [KeyboardHeightProvider] reports how many pixels the input bar should be
 *    moved up; the listener translates the input bar and chat list together,
 *    leaving the player and top region untouched.
 */
class LiveWatchActivity : AppCompatActivity() {

    private var isFollowed: Boolean = false
    private lateinit var regionChat: RecyclerView
    private lateinit var regionActions: View
    private lateinit var commentInput: EditText
    private lateinit var commentAdapter: LiveCommentAdapter
    private lateinit var giftNoticeTrayHost: GiftNoticeTrayHost
    private var keyboardHeightProvider: KeyboardHeightProvider? = null

    // --- Player / multi-camera ---
    private lateinit var playerTexture: TextureView
    private lateinit var verticalPlayerTexture: TextureView
    private lateinit var verticalPlayerContainer: View
    private lateinit var cameraList: RecyclerView
    private lateinit var cameraAdapter: CameraListAdapter
    private var player: SportLivePlayer? = null
    private val channels = mutableListOf<SportChannel>()
    private var currentChannel: SportChannel? = null
    private var customStreamMode = false
    private var customStreamUrl: CustomStreamUrl? = null
    private var customLowLatencyFlv = false
    private var videoAspectWidth = 16
    private var videoAspectHeight = 9
    private var customVideoPortrait: Boolean? = null

    // Play/pause control. Tracks the user's intent (play vs pause) so the button
    // icon stays correct across channel switches and lifecycle events.
    private lateinit var btnPlayPause: ImageButton
    private var userPaused = false

    // Feature toggle states owned by the host; default per product:
    // ABR on, SR/Sharpen off.
    private var srEnabled = false
    private var sharpenEnabled = false

    // Currently active pull-protocol option. Initialised from the channel's
    // declared strategy + low-latency-FLV flag when [prepareChannel] runs;
    // re-pointed when the user saves a protocol change in the settings panel.
    private var protocolOption: PullProtocolOption = PullProtocolOption.FLV_LOW_LATENCY

    // Resolution state for ABR. The resolution chip row was removed in v3.0
    // (Figma node 10904:17076), so users only flip the ABR switch:
    //   abrOn == true  → adaptive bitrate, no pinned tier.
    //   abrOn == false → start on [pinnedResolution] (defaults to the channel's
    //                    first declared tier).
    private var abrOn = true
    private var pinnedResolution: Resolution? = null

    // --- Landscape / fullscreen ---
    // The landscape overlay is mounted on the DecorView (no Activity recreation,
    // no setContentView swap); the player's TextureView is moved into it so
    // playback never restarts. See LandscapeController.
    private var landscapeController: LandscapeController? = null
    // Danmaku overlay lives inside the landscape overlay, so it only exists
    // while in fullscreen. Null when portrait.
    private var landscapeDanmaku: DanmakuView? = null
    private lateinit var orientationSensor: OrientationSensorHelper
    // When true the user explicitly locked the orientation in landscape; the
    // sensor must not auto-rotate or auto-exit until unlocked.
    private var orientationLocked = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.live_sport_activity_watch)
        // Base page is portrait-locked; landscape is entered explicitly through
        // the overlay (rotate button / gravity sensor), never by the system
        // auto-rotating the portrait layout itself.
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT

        WindowCompat.getInsetsController(window, window.decorView)
            .isAppearanceLightStatusBars = false

        val statusBarGuide = findViewById<Guideline>(R.id.guideline_status_bar)
        val navBarGuide = findViewById<Guideline>(R.id.guideline_nav_bar)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.root)) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            statusBarGuide.setGuidelineBegin(bars.top)
            navBarGuide.setGuidelineEnd(bars.bottom)
            insets
        }

        readCustomStreamIntent()
        bindTopRegion()
        bindPlayer()
        bindCameraList()
        bindCommentList()
        bindActionsBar()
        bindGiftNoticeTray()
        bindKeyboardHeight()
        bindOrientation()
    }

    private fun readCustomStreamIntent() {
        customStreamMode = intent.getBooleanExtra(EXTRA_CUSTOM_STREAM_MODE, false)
        if (!customStreamMode) return
        val url = intent.getStringExtra(EXTRA_CUSTOM_STREAM_URL).orEmpty()
        val parsedFormat = runCatching {
            CustomStreamFormat.valueOf(intent.getStringExtra(EXTRA_CUSTOM_STREAM_FORMAT).orEmpty())
        }.getOrNull()
        val parsedUrl = CustomStreamUrlParser.parse(url)
        customStreamUrl = if (parsedUrl != null && (parsedFormat == null || parsedUrl.format == parsedFormat)) {
            parsedUrl
        } else {
            null
        }
        customLowLatencyFlv = intent.getBooleanExtra(EXTRA_CUSTOM_STREAM_LOW_LATENCY, false)
        srEnabled = intent.getBooleanExtra(EXTRA_CUSTOM_STREAM_SR, false)
        sharpenEnabled = intent.getBooleanExtra(EXTRA_CUSTOM_STREAM_SHARPEN, false)
    }

    override fun onResume() {
        super.onResume()
        // Foreground: resume playback unless the user explicitly paused. Safe to
        // call right after onCreate's initial config — play() (re)builds the
        // underlying player from the current config.
        if ((currentChannel != null || customStreamUrl != null) && !userPaused) player?.play()
        orientationSensor.enable()
    }

    override fun onPause() {
        super.onPause()
        // Background: pause playback. For RTM the SDK treats pause as stop and
        // would force a reconnect on resume; SportLivePlayer rebuilds on next
        // play() anyway, so pause is safe here.
        player?.pause()
        orientationSensor.disable()
    }

    override fun onDestroy() {
        keyboardHeightProvider?.destroySelf()
        keyboardHeightProvider = null
        if (this::giftNoticeTrayHost.isInitialized) {
            giftNoticeTrayHost.clear()
        }
        player?.destroy()
        player = null
        super.onDestroy()
    }

    /**
     * Back press first leaves landscape (if showing) instead of finishing, so
     * the system Back gesture mirrors the on-screen back arrow.
     */
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (landscapeController?.isShowing == true) {
            exitLandscape()
            return
        }
        @Suppress("DEPRECATION")
        super.onBackPressed()
    }

    private fun bindTopRegion() {
        findViewById<ImageView>(R.id.btn_close).setOnClickListener { finish() }

        val followBtn = findViewById<TextView>(R.id.btn_follow)
        followBtn.setOnClickListener { toggleFollow() }
        applyFollowState(followBtn)
    }

    /** Flip the follow state and refresh every follow button currently shown. */
    private fun toggleFollow() {
        isFollowed = !isFollowed
        findViewById<TextView?>(R.id.btn_follow)?.let { applyFollowState(it) }
        landscapeController
            ?.let { window.decorView.findViewById<TextView?>(R.id.btn_landscape_follow) }
            ?.let { applyFollowState(it) }
    }

    private fun applyFollowState(btn: TextView) {
        if (isFollowed) {
            btn.setBackgroundResource(R.drawable.live_sport_btn_followed)
            btn.setText(R.string.live_sport_watch_followed)
        } else {
            btn.setBackgroundResource(R.drawable.live_sport_btn_follow)
            btn.setText(R.string.live_sport_watch_follow)
        }
    }

    // region player + multi-camera

    private fun bindPlayer() {
        // Make sure TTSDK is initialised even if this page is launched directly
        // (e.g. during development) without passing through the directory page.
        com.byteplus.live.sport.player.SportLiveEnv.ensureInitialized(this)
        playerTexture = findViewById(R.id.player_texture)
        verticalPlayerTexture = findViewById(R.id.vertical_player_texture)
        verticalPlayerContainer = findViewById(R.id.vertical_player_container)
        // Build the single player instance; bind the surface once. Switching
        // channels rebuilds the underlying VeLivePlayer but keeps this object
        // and the TextureView's SurfaceTexture.
        player = SportLivePlayer(this).apply {
            setListener(playerListener)
            bindTextureView(playerTexture)
        }

        if (customStreamMode) {
            prepareCustomStream(resetVideoMode = true)
        } else {
            channels.clear()
            channels.addAll(SportChannelRepo.load(this))
            if (channels.isEmpty()) {
                Toast.makeText(this, R.string.live_sport_watch_channels_empty, Toast.LENGTH_SHORT).show()
                return
            }
            // Only prepare the config here; onResume() starts playback so we don't
            // build the player twice during the onCreate→onResume sequence.
            prepareChannel(channels[0])
        }

        bindPlayerControls()
    }

    private fun bindPlayerControls() {
        btnPlayPause = findViewById(R.id.btn_play_pause)
        // isSelected == true → playing → shows the Pause icon.
        btnPlayPause.isSelected = true
        btnPlayPause.setOnClickListener { togglePlayPause() }

        // Rotate enters landscape fullscreen.
        findViewById<ImageButton>(R.id.btn_rotate).setOnClickListener { enterLandscape() }

        // Double-tap the player to "like". Portrait has no single-tap action.
        val burst = findViewById<LikeBurstView>(R.id.like_burst)
        val floating = findViewById<ThumbFloatingView>(R.id.thumb_floating)
        configureFloating(floating)
        attachLikeGesture(
            burstView = burst,
            floatingView = floating,
            anchorButton = { findViewById(R.id.btn_settings) },
            onSingleTap = null,
        )

        // The vertical (custom-stream portrait) surface gets its own burst layer
        // but shares the portrait floating overlay anchored above the settings
        // button.
        val verticalBurst = findViewById<LikeBurstView>(R.id.vertical_like_burst)
        attachLikeGesture(
            burstView = verticalBurst,
            floatingView = floating,
            anchorButton = { findViewById(R.id.btn_settings) },
            onSingleTap = null,
        )
    }

    /**
     * Default like-icon set: the five floating-thumb artworks. Multi-colour
     * PNGs, so callers must NOT tint them.
     */
    private fun likeIcons() = LIKE_ICON_RES.mapNotNull { resId -> ContextCompat.getDrawable(this, resId) }

    /** Configure a floating overlay with the shared icon set (fixed 32dp). */
    private fun configureFloating(floatingView: ThumbFloatingView) {
        floatingView.setIcons(likeIcons())
    }

    /**
     * Wire a double-tap "like" gesture onto [burstView]: each double-tap (and
     * each subsequent tap while the gesture detector reports double-taps) both
     * bursts a heart at the touch point AND rises a floating heart from above
     * [anchorButton]. [onSingleTap] runs on a confirmed single tap (used in
     * landscape to toggle controls); pass null for none.
     *
     * Using onSingleTapConfirmed means a real single tap is delayed by the
     * double-tap timeout — acceptable per product.
     */
    @SuppressLint("ClickableViewAccessibility")
    private fun attachLikeGesture(
        burstView: LikeBurstView,
        floatingView: ThumbFloatingView,
        anchorButton: () -> View?,
        onSingleTap: (() -> Unit)?,
    ) {
        burstView.setIcons(likeIcons())
        // Keep each PNG's own colours (no random tint) and a fixed burst size.
        burstView.setPalette(intArrayOf())
        burstView.iconMinSizeDp = BURST_ICON_SIZE_DP
        burstView.iconMaxSizeDp = BURST_ICON_SIZE_DP
        val detector = GestureDetector(
            this,
            object : GestureDetector.SimpleOnGestureListener() {
                // MUST return true so the detector keeps receiving MOVE/UP after
                // DOWN; otherwise neither single- nor double-tap is detected.
                override fun onDown(e: MotionEvent): Boolean = true

                // Fires on the 2nd tap's ACTION_DOWN (and for further taps while
                // the double-tap session continues), so each like maps to one
                // heart without the double-count onDoubleTap would add.
                override fun onDoubleTapEvent(e: MotionEvent): Boolean {
                    if (e.action == MotionEvent.ACTION_DOWN) {
                        burstView.like(e.x, e.y)
                        spawnFloating(floatingView, anchorButton())
                    }
                    return true
                }

                override fun onSingleTapConfirmed(e: MotionEvent): Boolean {
                    onSingleTap?.invoke()
                    return true
                }
            },
        )
        burstView.isClickable = true
        burstView.setOnTouchListener { _, event -> detector.onTouchEvent(event) }
    }

    /**
     * Launch one floating heart from above [anchor] (its top-centre), converted
     * into [floatingView]'s own coordinates. We resolve the anchor against the
     * floating view's parent container, so the same anchor still works after the
     * landscape controls auto-hide (their layout position stays valid even while
     * hidden). Only fall back when the anchor has never been laid out.
     */
    private fun spawnFloating(floatingView: ThumbFloatingView, anchor: View?) {
        if (floatingView.width == 0 || floatingView.height == 0) return
        val floatingHost = floatingView.parent as? ViewGroup
        val anchorX: Float
        val anchorY: Float
        if (floatingHost != null && anchor != null && anchor.width > 0 && anchor.height > 0) {
            val rect = android.graphics.Rect(0, 0, anchor.width, anchor.height)
            floatingHost.offsetDescendantRectToMyCoords(anchor, rect)
            anchorX = rect.exactCenterX()
            anchorY = rect.top.toFloat()
        } else {
            anchorX = floatingView.width - dpToPx(FLOATING_FALLBACK_RIGHT_DP).toFloat()
            anchorY = floatingView.height - dpToPx(FLOATING_FALLBACK_BOTTOM_DP).toFloat()
        }
        floatingView.spawn(anchorX, anchorY)
    }

    /** Flip play/pause and sync every play/pause button currently shown. */
    private fun togglePlayPause() {
        if (userPaused) {
            userPaused = false
            player?.play()
        } else {
            userPaused = true
            player?.pause()
        }
        val playing = !userPaused
        btnPlayPause.isSelected = playing
        window.decorView.findViewById<ImageButton?>(R.id.btn_landscape_play_pause)
            ?.isSelected = playing
    }

    private fun bindCameraList() {
        cameraList = findViewById(R.id.camera_list)
        if (customStreamMode) {
            findViewById<View>(R.id.region_camera).visibility = View.GONE
            return
        }
        if (channels.isEmpty()) {
            findViewById<View>(R.id.region_camera).visibility = View.GONE
            return
        }
        cameraAdapter = CameraListAdapter { _, channel ->
            // User tapped a camera while the page is active → switch and play
            // immediately. A switch always resumes (clears any manual pause).
            userPaused = false
            btnPlayPause.isSelected = true
            prepareChannel(channel)
            player?.play()
        }
        cameraList.layoutManager =
            LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        cameraList.adapter = cameraAdapter
        cameraList.addItemDecoration(
            com.byteplus.live.sport.watch.camera.CameraSpacingDecoration(dpToPx(CAMERA_ITEM_GAP_DP))
        )
        cameraAdapter.submit(channels, selected = 0)

        // Size items so the first CameraListAdapter.FILL_COUNT entries exactly
        // fill the list width with no scrolling (per product requirement).
        cameraList.viewTreeObserver.addOnGlobalLayoutListener(
            object : ViewTreeObserver.OnGlobalLayoutListener {
                override fun onGlobalLayout() {
                    val width = cameraList.width - cameraList.paddingStart - cameraList.paddingEnd
                    if (width <= 0) return
                    cameraAdapter.setFillWidth(width, dpToPx(CAMERA_ITEM_GAP_DP))
                    cameraList.viewTreeObserver.removeOnGlobalLayoutListener(this)
                }
            }
        )

        // Expand/collapse the camera list. The header row stays; only the list
        // toggles. Settings stay on the bottom action bar's settings icon.
        val toggle = findViewById<ImageButton>(R.id.btn_camera_toggle)
        toggle.setOnClickListener {
            val collapsed = cameraList.visibility != View.VISIBLE
            cameraList.visibility = if (collapsed) View.VISIBLE else View.GONE
            // Expanded → "up" arrow (tap to collapse); collapsed → "down" arrow.
            toggle.setImageResource(
                if (collapsed) R.drawable.live_sport_ic_arrow_up
                else R.drawable.live_sport_ic_arrow_down
            )
        }
    }

    /**
     * Prepare the player for [channel]: reset the per-channel state (protocol
     * option / ABR / pinned tier) to whatever the channel's JSON declares as
     * its initial preference, then push the config. Does NOT start playback —
     * callers decide when to call play() (onResume for the initial channel,
     * immediately for a user-driven switch).
     */
    private fun prepareChannel(channel: SportChannel) {
        val p = player ?: return
        currentChannel = channel
        customVideoPortrait = null
        applyHorizontalVideoMode()
        // Reset to the channel's declared initial preference.
        protocolOption = PullProtocolOption.from(channel.strategy, channel.lowLatencyFlv)
        abrOn = channel.abr && channel.hasMultipleTiers
        pinnedResolution = null
        p.setConfig(buildConfig(channel))
        refreshLandscapeQualityVisibility()
    }

    private fun prepareCustomStream(resetVideoMode: Boolean) {
        val p = player ?: return
        val stream = customStreamUrl
        if (stream == null) {
            Toast.makeText(this, R.string.live_sport_custom_stream_url_error, Toast.LENGTH_SHORT).show()
            finish()
            return
        }
        currentChannel = null
        abrOn = false
        pinnedResolution = null
        if (resetVideoMode) {
            customVideoPortrait = null
            applyHorizontalVideoMode()
        }
        p.setConfig(buildCustomStreamConfig(stream))
        p.setRenderFillMode(SportRenderFillMode.ASPECT_FIT)
    }

    /** Build the SDK config from the current channel + resolution/feature state. */
    private fun buildConfig(channel: SportChannel) = channel.toPlayerConfig(
        protocol = protocolOption,
        abrAuto = abrOn,
        pinnedResolution = pinnedResolution,
        enableSR = srEnabled,
        enableSharpen = sharpenEnabled,
    )

    private fun buildCustomStreamConfig(stream: CustomStreamUrl): SportPlayerConfig {
        val format = when (stream.format) {
            CustomStreamFormat.FLV -> SingleStreamFormat.FLV
            CustomStreamFormat.RTM -> SingleStreamFormat.RTM
            CustomStreamFormat.HLS -> SingleStreamFormat.HLS
            CustomStreamFormat.RTMPS -> SingleStreamFormat.RTMPS
        }
        return SportPlayerConfig(
            strategy = PlayStrategy.SINGLE_STREAM,
            singleStream = SingleStream(format = format, url = stream.url),
            // Low-latency FLV is an FLV-only feature; ignored for the other protocols.
            enableLowLatencyFlv = stream.format == CustomStreamFormat.FLV && customLowLatencyFlv,
            enableSR = srEnabled,
            enableSharpen = sharpenEnabled,
        )
    }

    /** Rebuild the player with the current state and start playback. */
    private fun rebuildAndPlay() {
        if (customStreamMode) {
            prepareCustomStream(resetVideoMode = false)
            player?.play()
            return
        }
        val channel = currentChannel ?: return
        player?.setConfig(buildConfig(channel))
        player?.play()
    }

    private fun openSettingsPanel() {
        if (customStreamMode) {
            openCustomStreamSettingsPanel()
            return
        }
        val channel = currentChannel ?: return
        PlayerSettingsPanel(this, settingsCallback).show(
            PlayerSettingsBinder.State(
                protocol = protocolOption,
                rtmSupported = channel.rtmSupported,
                multiTierFlv = channel.hasMultipleTiers,
                abrOn = abrOn,
                srOn = srEnabled,
                sharpenOn = sharpenEnabled,
            )
        )
    }

    private fun openCustomStreamSettingsPanel() {
        CustomStreamSettingsPanel(
            context = this,
            state = CustomStreamSettingsBinder.State(
                url = customStreamUrl?.url.orEmpty(),
                lowLatencyFlv = customLowLatencyFlv,
                srOn = srEnabled,
                sharpenOn = sharpenEnabled,
            ),
            onApply = { applyCustomStreamSettings(it) },
        ).show()
    }

    private fun applyCustomStreamSettings(result: CustomStreamSettingsBinder.Result) {
        val streamChanged = customStreamUrl != result.streamUrl ||
            customLowLatencyFlv != result.lowLatencyFlv
        val srChanged = srEnabled != result.srOn
        val sharpenChanged = sharpenEnabled != result.sharpenOn

        customStreamUrl = result.streamUrl
        customLowLatencyFlv = result.lowLatencyFlv
        srEnabled = result.srOn
        sharpenEnabled = result.sharpenOn

        if (streamChanged) {
            customVideoPortrait = null
            applyHorizontalVideoMode()
            rebuildAndPlay()
            return
        }
        if (srChanged) player?.setSrEnabled(srEnabled)
        if (sharpenChanged) player?.setSharpenEnabled(sharpenEnabled)
    }

    private fun onCustomVideoSize(width: Int, height: Int) {
        if (!customStreamMode || width <= 0 || height <= 0) return
        videoAspectWidth = width
        videoAspectHeight = height
        landscapeController?.updateVideoAspectRatio(width, height)
        val portrait = height > width
        if (customVideoPortrait == portrait) return
        customVideoPortrait = portrait
        if (portrait) {
            applyVerticalVideoMode()
        } else {
            applyHorizontalVideoMode()
        }
    }

    private fun applyHorizontalVideoMode() {
        if (!this::verticalPlayerContainer.isInitialized || !this::playerTexture.isInitialized) return
        verticalPlayerContainer.visibility = View.GONE
        findViewById<View>(R.id.region_player).visibility = View.VISIBLE
        player?.bindTextureView(playerTexture)
        player?.setRenderFillMode(SportRenderFillMode.ASPECT_FIT)
        if (this::btnPlayPause.isInitialized) {
            btnPlayPause.visibility = View.VISIBLE
            findViewById<ImageButton>(R.id.btn_rotate).visibility = View.VISIBLE
        }
        if (customStreamMode) {
            findViewById<View>(R.id.region_camera).visibility = View.GONE
            findViewById<View>(R.id.camera_region_shadow).visibility = View.GONE
        }
        if (this::regionChat.isInitialized) restoreChatLayout()
    }

    private fun applyVerticalVideoMode() {
        if (!this::verticalPlayerContainer.isInitialized || !this::verticalPlayerTexture.isInitialized) return
        findViewById<View>(R.id.region_player).visibility = View.GONE
        findViewById<View>(R.id.region_camera).visibility = View.GONE
        findViewById<View>(R.id.camera_region_shadow).visibility = View.GONE
        verticalPlayerContainer.visibility = View.VISIBLE
        player?.bindTextureView(verticalPlayerTexture)
        player?.setRenderFillMode(SportRenderFillMode.ASPECT_FILL)
        if (this::btnPlayPause.isInitialized) {
            btnPlayPause.visibility = View.GONE
            findViewById<ImageButton>(R.id.btn_rotate).visibility = View.GONE
        }
        if (this::regionChat.isInitialized) applyVerticalChatLayout()
    }

    private fun restoreChatLayout() {
        val root = findViewById<ConstraintLayout>(R.id.root)
        val set = ConstraintSet()
        set.clone(root)
        set.constrainHeight(R.id.region_chat, 0)
        // In custom-stream mode the multi-camera region is hidden, so anchor the
        // chat top to the player bottom instead of the GONE camera region.
        val chatTopAnchor = if (customStreamMode) R.id.region_player else R.id.region_camera
        set.connect(R.id.region_chat, ConstraintSet.TOP, chatTopAnchor, ConstraintSet.BOTTOM)
        set.connect(R.id.region_chat, ConstraintSet.BOTTOM, R.id.region_actions, ConstraintSet.TOP)
        set.applyTo(root)
        regionChat.setPadding(
            dpToPx(12f),
            dpToPx(8f),
            dpToPx(92f),
            dpToPx(8f),
        )
    }

    private fun applyVerticalChatLayout() {
        val root = findViewById<ConstraintLayout>(R.id.root)
        val set = ConstraintSet()
        set.clone(root)
        set.constrainHeight(R.id.region_chat, dpToPx(VERTICAL_CHAT_HEIGHT_DP))
        set.clear(R.id.region_chat, ConstraintSet.TOP)
        set.connect(R.id.region_chat, ConstraintSet.BOTTOM, R.id.region_actions, ConstraintSet.TOP)
        set.applyTo(root)
        regionChat.setPadding(
            dpToPx(12f),
            dpToPx(8f),
            dpToPx(92f),
            dpToPx(8f),
        )
    }

    // endregion

    // region landscape / orientation

    /**
     * Wire the device-orientation watcher. It reports the physical orientation
     * even when system auto-rotate is off, so the page can auto-enter landscape
     * and flip between the two landscape directions like a typical video app.
     */
    private fun bindOrientation() {
        orientationSensor = OrientationSensorHelper(this) { orientation ->
            if (orientationLocked) return@OrientationSensorHelper
            when (orientation) {
                OrientationSensorHelper.DeviceOrientation.PORTRAIT -> {
                    if (landscapeController?.isShowing == true) exitLandscape()
                }
                OrientationSensorHelper.DeviceOrientation.LANDSCAPE_LEFT -> {
                    if (customStreamMode && customVideoPortrait != false) return@OrientationSensorHelper
                    enterLandscape(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE)
                }
                OrientationSensorHelper.DeviceOrientation.LANDSCAPE_RIGHT -> {
                    if (customStreamMode && customVideoPortrait != false) return@OrientationSensorHelper
                    enterLandscape(ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE)
                }
            }
        }
    }

    /**
     * Enter landscape fullscreen. Pins the requested orientation, then mounts
     * the landscape overlay (moving the TextureView into it) the first time.
     * When already showing, only the orientation is updated — this is how the
     * sensor flips between the two landscape directions.
     */
    private fun enterLandscape(
        orientation: Int = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
    ) {
        requestedOrientation = orientation
        val existing = landscapeController
        if (existing != null && existing.isShowing) return

        val controller = LandscapeController(
            activity = this,
            portraitPlayerContainer = findViewById(R.id.region_player),
            playerTexture = playerTexture,
        )
        landscapeController = controller
        controller.enter { root -> bindLandscapeControls(root) }
        controller.updateVideoAspectRatio(videoAspectWidth, videoAspectHeight)
    }

    /** Leave landscape: tear down the overlay and return to portrait. */
    private fun exitLandscape() {
        orientationLocked = false
        landscapeDanmaku = null
        landscapeController?.exit()
        landscapeController = null
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    }

    /** Bind the landscape overlay's controls onto the shared host state. */
    private fun bindLandscapeControls(root: View) {
        // Reuse the same follow / play-pause state the portrait controls drive.
        root.findViewById<TextView>(R.id.btn_landscape_follow).let {
            applyFollowState(it)
            it.setOnClickListener { toggleFollow() }
        }
        root.findViewById<ImageButton>(R.id.btn_landscape_play_pause).apply {
            isSelected = !userPaused
            setOnClickListener { togglePlayPause() }
        }
        root.findViewById<View>(R.id.btn_landscape_back).setOnClickListener { exitLandscape() }
        root.findViewById<ImageButton>(R.id.btn_landscape_settings).setOnClickListener {
            openLandscapeSettings()
        }
        root.findViewById<ImageButton>(R.id.btn_landscape_gift).setOnClickListener {
            openLandscapeGiftPanel()
        }
        root.findViewById<View>(R.id.btn_landscape_multi_camera).setOnClickListener {
            openLandscapeCameraPanel()
        }
        root.findViewById<View>(R.id.btn_landscape_quality).setOnClickListener {
            openLandscapeQualityPanel()
        }
        // RTM has no quality picker — hide the entry button while the user is
        // on RTM. Re-evaluated whenever the protocol changes (settings save /
        // channel switch).
        refreshLandscapeQualityVisibility(root)
        if (customStreamMode) {
            root.findViewById<View>(R.id.btn_landscape_quality).visibility = View.GONE
            root.findViewById<View>(R.id.btn_landscape_multi_camera).visibility = View.GONE
            // Settings is portrait-only for custom-stream playback.
            root.findViewById<View>(R.id.btn_landscape_settings).visibility = View.GONE
        }

        // Single tap toggles controls; double tap likes (handles locked state
        // via onVideoTapped, which no-ops the toggle while locked). The floating
        // stream rises from above the gift button and keeps the same anchor even
        // when the controls auto-hide.
        val landscapeBurst = root.findViewById<LikeBurstView>(R.id.landscape_like_burst)
        val landscapeFloating = root.findViewById<ThumbFloatingView>(R.id.landscape_thumb_floating)
        configureFloating(landscapeFloating)
        attachLikeGesture(
            burstView = landscapeBurst,
            floatingView = landscapeFloating,
            anchorButton = { root.findViewById(R.id.btn_landscape_gift) },
            onSingleTap = { landscapeController?.onVideoTapped() },
        )

        // Scrolling danmaku canvas over the video. Held while the overlay is up;
        // cleared on exit.
        landscapeDanmaku = root.findViewById(R.id.landscape_danmaku)

        // Small inline input is a launcher only: tapping it opens the
        // full-width composer above the keyboard (Activity stays adjustNothing).
        // The composer owns the real editing + IME.
        val landscapeInput = root.findViewById<EditText>(R.id.landscape_comment_input)
        landscapeInput.isFocusable = false
        landscapeInput.isCursorVisible = false
        landscapeInput.setOnClickListener { openLandscapeComposer(landscapeInput) }

        // Lock toggle: hide all controls except the lock button + pin orientation.
        val lockBtn = root.findViewById<ImageButton>(R.id.btn_landscape_lock)
        lockBtn.setOnClickListener {
            val locked = landscapeController?.toggleLock() ?: return@setOnClickListener
            orientationLocked = locked
            requestedOrientation = if (locked) {
                ActivityInfo.SCREEN_ORIENTATION_LOCKED
            } else {
                ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
            }
            lockBtn.setImageResource(
                if (locked) R.drawable.live_sport_ic_lock_closed
                else R.drawable.live_sport_ic_lock_open
            )
            Toast.makeText(
                this,
                if (locked) R.string.live_sport_watch_locked_toast
                else R.string.live_sport_watch_unlocked_toast,
                Toast.LENGTH_SHORT,
            ).show()
        }
    }

    /**
     * Show / hide the landscape 1080P (quality) entry button. RTM is single-
     * stream so the picker has nothing to offer; FLV (any number of tiers,
     * including a single one — per product spec) keeps the entry visible.
     */
    private fun refreshLandscapeQualityVisibility(root: View? = null) {
        val target = (root ?: window.decorView)
            .findViewById<View?>(R.id.btn_landscape_quality) ?: return
        if (customStreamMode) {
            target.visibility = View.GONE
            return
        }
        target.visibility = if (protocolOption == PullProtocolOption.RTM) View.GONE else View.VISIBLE
        refreshLandscapeQualityLabel(root)
    }

    /**
     * Sync the landscape quality entry button's label with the current pick:
     * "Auto" while ABR is on, otherwise the pinned tier's name (falling back to
     * the channel's first declared tier when nothing is pinned yet).
     */
    private fun refreshLandscapeQualityLabel(root: View? = null) {
        val label = (root ?: window.decorView)
            .findViewById<TextView?>(R.id.btn_landscape_quality) ?: return
        label.text = if (abrOn) {
            getString(R.string.live_sport_watch_resolution_auto)
        } else {
            val res = pinnedResolution ?: currentChannel?.flvStreams?.firstOrNull()?.resolution
            res?.let { resolutionName(it) } ?: getString(R.string.live_sport_watch_resolution_auto)
        }
    }

    /**
     * Right-side slide settings panel. Hides the controls while it's up
     * (panel covers the video; tapping the panel is the user's intent) and
     * mirrors the portrait Save flow via [settingsCallback].
     */
    private fun openLandscapeSettings() {
        if (customStreamMode) {
            openCustomStreamSettingsPanel()
            return
        }
        val channel = currentChannel ?: return
        val controller = landscapeController ?: return
        val panel = LandscapePlayerSettingsPanel(
            hostActivity = this,
            state = PlayerSettingsBinder.State(
                protocol = protocolOption,
                rtmSupported = channel.rtmSupported,
                multiTierFlv = channel.hasMultipleTiers,
                abrOn = abrOn,
                srOn = srEnabled,
                sharpenOn = sharpenEnabled,
            ),
            onApply = { result -> settingsCallback.onApply(result) },
        )
        attachLandscapePanelLifecycle(panel, controller)
        panel.show()
    }

    private fun openLandscapeCameraPanel() {
        if (customStreamMode) return
        val controller = landscapeController ?: return
        val panel = LandscapeCameraPanel(
            activity = this,
            channels = channels,
            selectedId = currentChannel?.id,
            onPicked = { index, channel ->
                userPaused = false
                btnPlayPause.isSelected = true
                window.decorView
                    .findViewById<ImageButton?>(R.id.btn_landscape_play_pause)?.isSelected = true
                prepareChannel(channel)
                player?.play()
                cameraAdapter.submit(channels, selected = index)
                refreshLandscapeQualityVisibility()
            },
        )
        attachLandscapePanelLifecycle(panel, controller)
        panel.show()
    }

    private fun openLandscapeGiftPanel() {
        val controller = landscapeController ?: return
        val panel = LandscapeGiftPanel(this) { gift -> onGiftSent(gift) }
        attachLandscapePanelLifecycle(panel, controller)
        panel.show()
    }

    private fun openLandscapeQualityPanel() {
        if (customStreamMode) return
        val channel = currentChannel ?: return
        val controller = landscapeController ?: return
        // Tier order: keep the order declared in the channel JSON so the UI
        // matches the source-of-truth ordering (already highest→lowest there).
        val tiers = channel.flvStreams.map { it.resolution }.distinct()
        val panel = LandscapeQualityPanel(
            activity = this,
            tiers = tiers,
            abrOn = abrOn,
            pinnedResolution = pinnedResolution
                ?: channel.flvStreams.firstOrNull()?.resolution,
            onPicked = { autoSelected, resolution ->
                applyQualityPick(autoSelected, resolution)
            },
        )
        attachLandscapePanelLifecycle(panel, controller)
        panel.show()
    }

    /**
     * Apply a quality pick from the landscape panel.
     *  - autoSelected = ABR on, no pinned tier.
     *  - else fix on the chosen [resolution] with ABR off.
     */
    private fun applyQualityPick(autoSelected: Boolean, resolution: Resolution?) {
        if (autoSelected) {
            if (abrOn && pinnedResolution == null) return
            abrOn = true
            pinnedResolution = null
        } else {
            if (!abrOn && pinnedResolution == resolution) return
            abrOn = false
            pinnedResolution = resolution
        }
        refreshLandscapeQualityLabel()
        rebuildAndPlay()
    }

    /**
     * Common lifecycle wiring for landscape side panels: hide host controls
     * while the panel is up (panel covers the video) and re-arm the auto-hide
     * timer when it dismisses.
     */
    private fun attachLandscapePanelLifecycle(
        panel: com.byteplus.live.sport.fullscreen.LandscapeSidePanel,
        controller: LandscapeController,
    ) {
        panel.setOnShow { controller.hideControls() }
        panel.setOnDismiss { controller.showControls() }
    }

    // endregion

    // region player callbacks

    private val settingsCallback = object : PlayerSettingsPanel.Callback {
        /**
         * Save tapped. Diff the staged result against the current host state
         * and pick the cheapest path:
         *  - Protocol change OR ABR change → stream-data flag changes,
         *    requires a player rebuild ([rebuildAndPlay]).
         *  - SR / Sharpen only → runtime toggles, no rebuild needed.
         */
        override fun onApply(result: PlayerSettingsBinder.Result) {
            val protocolChanged = result.protocol != protocolOption
            val abrChanged = result.abrOn != abrOn
            val srChanged = result.srOn != srEnabled
            val sharpenChanged = result.sharpenOn != sharpenEnabled

            protocolOption = result.protocol
            abrOn = result.abrOn
            // Flipping ABR on clears any prior pin (Auto == ABR semantics).
            if (abrOn) pinnedResolution = null
            srEnabled = result.srOn
            sharpenEnabled = result.sharpenOn

            if (protocolChanged) {
                // RTM ↔ FLV transitions toggle the quality picker entry.
                refreshLandscapeQualityVisibility()
            } else if (abrChanged) {
                refreshLandscapeQualityLabel()
            }
            if (protocolChanged || abrChanged) {
                rebuildAndPlay()
                return
            }
            if (srChanged) player?.setSrEnabled(srEnabled)
            if (sharpenChanged) player?.setSharpenEnabled(sharpenEnabled)
        }
    }

    private val playerListener = object : SportLivePlayer.Listener {
        override fun onError(code: Int, msg: String) {
            val channel = currentChannel
            Log.e(
                TAG,
                "Playback error: code=$code msg=$msg" +
                    " | channel=${channel?.name}(${channel?.id})" +
                    " | protocol=$protocolOption abr=$abrOn pinned=$pinnedResolution" +
                    " | url=${currentPlayUrl()}",
            )
            Toast.makeText(
                this@LiveWatchActivity,
                getString(R.string.live_sport_watch_play_error, code, msg),
                Toast.LENGTH_LONG,
            ).show()
        }

        override fun onProtocolFallback() {
            // RTM failed and we fell back to FLV; tell the user once.
            Toast.makeText(
                this@LiveWatchActivity,
                R.string.live_sport_watch_rtm_fallback,
                Toast.LENGTH_SHORT,
            ).show()
        }

        override fun onSrFailed() {
            srEnabled = false
            Toast.makeText(this@LiveWatchActivity, R.string.live_sport_watch_sr_failed, Toast.LENGTH_SHORT).show()
        }

        override fun onSharpenFailed() {
            sharpenEnabled = false
            Toast.makeText(this@LiveWatchActivity, R.string.live_sport_watch_sharpen_failed, Toast.LENGTH_SHORT).show()
        }

        /**
         * The playing tier changed. When [byAbr] is true this is the ABR
         * algorithm auto-switching bitrate (NOT a user action) — surface it for
         * demo visibility but keep the UI on "Auto" and leave [pinnedResolution]
         * untouched, otherwise the panel would look like a manual pin. Manual
         * switches (byAbr=false) are already reflected by [pinnedResolution], so
         * we don't toast those.
         */
        override fun onResolutionSwitch(resolution: Resolution, byAbr: Boolean) {
            if (!byAbr) return
            Log.i(TAG, "ABR auto-switched tier to $resolution")
            Toast.makeText(
                this@LiveWatchActivity,
                getString(R.string.live_sport_watch_abr_switched, resolutionName(resolution)),
                Toast.LENGTH_SHORT,
            ).show()
        }

        override fun onVideoSizeChanged(width: Int, height: Int) {
            onCustomVideoSize(width, height)
        }

        override fun onStats(stats: SportPlayerStats) {
            Log.d(TAG, "stats delay=${stats.delayMs}ms bitrate=${stats.bitrateKbps}kbps codec=${stats.videoCodec}")
            if (customStreamMode && customVideoPortrait == null) {
                onCustomVideoSize(stats.width, stats.height)
            }
        }
    }

    /** Localized display name for a resolution tier. */
    private fun resolutionName(res: Resolution): String {
        val resId = when (res) {
            Resolution.ORIGIN -> R.string.live_sport_watch_resolution_origin
            Resolution.UHD -> R.string.live_sport_watch_resolution_uhd
            Resolution.HD -> R.string.live_sport_watch_resolution_hd
            Resolution.SD -> R.string.live_sport_watch_resolution_sd
            Resolution.LD -> R.string.live_sport_watch_resolution_ld
        }
        return getString(resId)
    }

    /**
     * The play URL currently in effect, for diagnostics logging. RTM uses the
     * single RTM URL; FLV uses the pinned tier's URL (or the first declared
     * tier when nothing is pinned / on ABR auto).
     */
    private fun currentPlayUrl(): String? {
        if (customStreamMode) return customStreamUrl?.url
        val channel = currentChannel ?: return null
        return if (protocolOption == PullProtocolOption.RTM) {
            channel.rtmUrl
        } else {
            val tier = pinnedResolution
            channel.flvStreams.firstOrNull { it.resolution == tier }?.url
                ?: channel.flvStreams.firstOrNull()?.url
        }
    }

    // endregion


    private fun bindCommentList() {
        regionChat = findViewById(R.id.region_chat)
        commentAdapter = LiveCommentAdapter()

        // stackFromEnd=true so a partially filled list still anchors to the
        // bottom — matches how live-stream chat reads in real apps.
        regionChat.layoutManager = LinearLayoutManager(this).apply {
            stackFromEnd = true
        }
        regionChat.adapter = commentAdapter
        regionChat.addItemDecoration(CommentSpacingDecoration(dpToPx(6f)))

        commentAdapter.submit(buildMockComments())
        regionChat.scrollToPosition(commentAdapter.lastIndex())
        if (customVideoPortrait == true) applyVerticalChatLayout()
    }

    private fun bindActionsBar() {
        commentInput = findViewById(R.id.comment_input)
        commentInput.setOnEditorActionListener { _, actionId, _ ->
            if (actionId != EditorInfo.IME_ACTION_SEND) return@setOnEditorActionListener false
            val text = commentInput.text?.toString()?.trim().orEmpty()
            if (text.isEmpty()) {
                // Don't consume the action when there's nothing to send;
                // the system can fall back to its default behaviour.
                return@setOnEditorActionListener false
            }
            sendComment(text)
            true
        }

        // Gift opens the fake gift panel (portrait BottomSheet).
        findViewById<ImageButton>(R.id.btn_gift).setOnClickListener { openGiftPanel() }
        // Settings opens the player settings panel (resolution / ABR / SR / sharpen).
        findViewById<ImageButton>(R.id.btn_settings).setOnClickListener { openSettingsPanel() }
    }

    private fun bindGiftNoticeTray() {
        giftNoticeTrayHost = findViewById(R.id.gift_notice_tray_host)
    }

    private fun openGiftPanel() {
        GiftPanel(this) { gift -> onGiftSent(gift) }.show()
    }

    /** Fake-send feedback shared by portrait + landscape gift panels. */
    private fun onGiftSent(gift: GiftBinder.Gift) {
        val notice = GiftNoticeData(
            avatarRes = R.drawable.live_sport_anchor_avatar,
            senderName = getString(R.string.live_sport_watch_self_name),
            giftName = getString(gift.nameRes),
            giftIconRes = gift.iconRes,
        )
        if (landscapeController?.isShowing == true && landscapeDanmaku != null) {
            showLandscapeGiftDanmaku(notice)
        } else {
            giftNoticeTrayHost.enqueue(notice)
        }
    }

    private fun showLandscapeGiftDanmaku(notice: GiftNoticeData) {
        val text = getString(
            R.string.live_sport_watch_gift_danmaku,
            notice.senderName,
            notice.giftName,
        )
        val icon = ContextCompat.getDrawable(this, notice.giftIconRes)
        if (icon != null) {
            landscapeDanmaku?.addGift(text, icon, GIFT_DANMAKU_COLOR)
        } else {
            landscapeDanmaku?.add(text, GIFT_DANMAKU_COLOR)
        }
    }

    /**
     * Open the full-width landscape composer seeded from the small inline
     * input. While it's up we hold the controls visible; on dismiss the small
     * input mirrors whatever text is left. Sends are appended to the shared
     * comment list (visible when back in portrait).
     */
    private fun openLandscapeComposer(inlineInput: EditText) {
        landscapeController?.keepControlsVisible(true)
        LandscapeCommentComposer(
            activity = this,
            initialText = inlineInput.text?.toString().orEmpty(),
            onSend = { text ->
                appendSelfComment(text)
                // Echo the user's own message as a danmaku, tinted so it stands
                // out from other sources.
                landscapeDanmaku?.add(text, SELF_DANMAKU_COLOR)
                inlineInput.setText("")
            },
            onTextChanged = { text ->
                inlineInput.setText(text)
                landscapeController?.keepControlsVisible(false)
            },
        ).show()
    }

    /** Append a comment authored by the local user to the shared chat list. */
    private fun appendSelfComment(text: String) {
        commentAdapter.append(
            LiveCommentItem(
                vipLevel = 1,
                userName = getString(R.string.live_sport_watch_self_name),
                content = text,
            )
        )
    }

    private fun sendComment(text: String) {
        val wasNearBottom = isChatNearBottom()
        commentAdapter.append(
            LiveCommentItem(
                vipLevel = 1,
                userName = getString(R.string.live_sport_watch_self_name),
                content = text,
            )
        )
        // Only auto-scroll when the user was already near the bottom — if
        // they are scrolled up reading history, leave their view alone.
        if (wasNearBottom) {
            regionChat.scrollToPosition(commentAdapter.lastIndex())
        }

        commentInput.setText("")
        // Auto-dismiss the IME after sending; tap the input again to compose
        // another message.
        hideKeyboard()
    }

    /**
     * @return true when the last visible item is the most recent comment, or
     *         the list is empty / shorter than the viewport. Used to decide
     *         whether new arrivals should snap the view to the bottom.
     */
    private fun isChatNearBottom(): Boolean {
        val lm = regionChat.layoutManager as? LinearLayoutManager ?: return true
        val lastVisible = lm.findLastVisibleItemPosition()
        return lastVisible == RecyclerView.NO_POSITION ||
            lastVisible >= commentAdapter.lastIndex()
    }

    private fun bindKeyboardHeight() {
        regionActions = findViewById(R.id.region_actions)

        // Pass the input bar itself as contentView (not the screen root): the
        // provider computes "distance to push the bar up so it sits on top of
        // the IME". Under EdgeToEdge the root extends below the navigation
        // bar, which would otherwise cause an extra offset.
        keyboardHeightProvider = KeyboardHeightProvider(this, regionActions)
            .setHeightListener { translateY ->
                Log.d(TAG, "onHeightChanged received translateY=$translateY")
                // Move both the input bar and the chat list up so more
                // messages stay visible; player and top region stay put to
                // avoid a jarring layout shift.
                regionActions.translationY = -translateY.toFloat()
                regionChat.translationY = -translateY.toFloat()
            }
            .init()
    }

    private fun hideKeyboard() {
        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(commentInput.windowToken, 0)
        commentInput.clearFocus()
    }

    private fun dpToPx(dp: Float): Int =
        (dp * resources.displayMetrics.density + 0.5f).toInt()

    /**
     * Mock data is loaded from string-arrays so the demo localises cleanly
     * and contains no hard-coded display text in source.
     * vipLevel cycles through 3 / 2 / 1 to exercise the badge rendering.
     */
    private fun buildMockComments(): List<LiveCommentItem> {
        val names = resources.getStringArray(R.array.live_sport_watch_mock_comment_names)
        val contents = resources.getStringArray(R.array.live_sport_watch_mock_comment_contents)
        val count = minOf(names.size, contents.size)
        val levels = listOf(3, 2, 1)
        return (0 until count).map { i ->
            LiveCommentItem(
                vipLevel = levels[i % levels.size],
                userName = names[i],
                content = contents[i],
            )
        }
    }

    companion object {
        private const val TAG = "LiveWatchActivity"

        /** Horizontal gap between camera items; matches the Figma 12px spacing. */
        private const val CAMERA_ITEM_GAP_DP = 12f
        private const val VERTICAL_CHAT_HEIGHT_DP = 168f

        /** Tint for danmaku authored by the local user (gold), to set them apart
         *  from other sources which render in the default white. */
        private const val SELF_DANMAKU_COLOR = 0xFFFFC53D.toInt()
        private const val GIFT_DANMAKU_COLOR = 0xFFFFC96B.toInt()

        /** Shared like-icon artwork: the five floating-thumb PNGs (full colour,
         *  never tinted). Used by both the touch-point burst and the corner
         *  floating stream. */
        private val LIKE_ICON_RES = listOf(
            R.drawable.live_sport_thumb_flow_1,
            R.drawable.live_sport_thumb_flow_2,
            R.drawable.live_sport_thumb_flow_3,
            R.drawable.live_sport_thumb_flow_4,
            R.drawable.live_sport_thumb_flow_5,
        )

        /** Fixed size of the touch-point burst icon (no random sizing). */
        private const val BURST_ICON_SIZE_DP = 64

        /** Fallback floating anchor offsets from the bottom-right corner when the
         *  anchor button isn't laid out / shown. */
        private const val FLOATING_FALLBACK_RIGHT_DP = 30f
        private const val FLOATING_FALLBACK_BOTTOM_DP = 96f

        const val EXTRA_CUSTOM_STREAM_MODE = "live_sport.extra.CUSTOM_STREAM_MODE"
        const val EXTRA_CUSTOM_STREAM_URL = "live_sport.extra.CUSTOM_STREAM_URL"
        const val EXTRA_CUSTOM_STREAM_FORMAT = "live_sport.extra.CUSTOM_STREAM_FORMAT"
        const val EXTRA_CUSTOM_STREAM_LOW_LATENCY = "live_sport.extra.CUSTOM_STREAM_LOW_LATENCY"
        const val EXTRA_CUSTOM_STREAM_SR = "live_sport.extra.CUSTOM_STREAM_SR"
        const val EXTRA_CUSTOM_STREAM_SHARPEN = "live_sport.extra.CUSTOM_STREAM_SHARPEN"
    }
}
