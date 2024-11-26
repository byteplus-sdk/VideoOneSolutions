package com.byteplus.vodlive.layer

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ValueAnimator
import android.content.Context
import android.text.TextUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.Surface
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.graphics.Insets
import androidx.core.view.updateLayoutParams
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.CenterCrop
import com.byteplus.playerkit.player.PlayerEvent
import com.byteplus.playerkit.player.playback.PlaybackController
import com.byteplus.playerkit.player.playback.PlaybackEvent
import com.byteplus.playerkit.player.playback.VideoView
import com.byteplus.playerkit.utils.L
import com.byteplus.playerkit.utils.event.Dispatcher
import com.byteplus.playerkit.utils.event.Event
import com.byteplus.vod.scenekit.R
import com.byteplus.vod.scenekit.data.model.VideoItem
import com.byteplus.vod.scenekit.ui.base.OuterActions
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras
import com.byteplus.vod.scenekit.ui.config.IImageCoverConfig
import com.byteplus.vod.scenekit.ui.video.layer.FullScreenLayer
import com.byteplus.vod.scenekit.ui.video.layer.base.BaseLayer
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.ShortVideoStrategy
import com.byteplus.vod.scenekit.utils.FormatHelper
import com.byteplus.vodlive.databinding.MixShortVideoDetailsLayerBinding
import com.byteplus.vodlive.live.LiveController
import com.byteplus.vodlive.model.VodFeedItem
import com.videoone.avatars.Avatars.byUserId

class VideoDetailsLayer : BaseLayer() {

    companion object {
        const val ANIMATION_DURATION_TIME: Long = 800L
        const val ANIMATION_DURATION_TIME_CIRCLE: Long = 640L
    }

    init {
        isIgnoreLock = true
    }

    private lateinit var binding: MixShortVideoDetailsLayerBinding
    private var animatorSet: AnimatorSet? = null

    override fun tag(): String = "short_video_details"

    override fun createView(parent: ViewGroup): View {
        binding = MixShortVideoDetailsLayerBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        binding.fullScreen.setOnClickListener {
            FullScreenLayer.toggle(videoView(), true)
        }
        binding.like.addAnimatorListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                animatorListenerAdapter?.onAnimationEnd(animation)
            }
        })
        binding.like.addLottieOnCompositionLoadedListener {
            binding.like.frame = 0
        }

        animatorSet = AnimatorSet().apply {
            playTogether(
                ValueAnimator.ofFloat(1F, 0.92F, 1F)
                    .apply {
                        repeatCount = ValueAnimator.INFINITE
                        duration = ANIMATION_DURATION_TIME

                        addUpdateListener {
                            val progress = it.getAnimatedValue() as Float
                            binding.avatarLive.scaleX = progress
                            binding.avatarLive.scaleY = progress
                        }
                    },

                ValueAnimator.ofInt(0, ANIMATION_DURATION_TIME.toInt()).apply {
                    repeatCount = ValueAnimator.INFINITE
                    duration = ANIMATION_DURATION_TIME

                    addUpdateListener {
                        val progress = it.getAnimatedValue() as Int
                        if (progress in 0..640) {
                            val circleFraction =
                                progress.toFloat() / ANIMATION_DURATION_TIME_CIRCLE.toFloat()
                            binding.avatarLiveBorder.setFraction(circleFraction)
                        }
                    }
                }
            )
        }

        return binding.root
    }

    private var animatorListenerAdapter: AnimatorListenerAdapter? = null

    /**
     * @see ShortVideoProgressBarLayer
     */
    fun bind(item: VodFeedItem, insets: Insets = Insets.NONE) {
        show()
        val videoItem = item.videoItem
        val context = context()!!
        binding.title.text = context.getString(R.string.vevod_short_video_at, videoItem.userName)

        // Patch for TextView height issue when setMaxLines(int) called
        val subtitle = videoItem.title
        binding.subtitle.maxLines = if (TextUtils.isEmpty(subtitle)) 0 else 2
        binding.subtitle.text = subtitle

        // PM: Only show progress bar when duration > 1 Min
        // Leave padding for ProgressBar
        val showBottom = videoItem.duration > 60000
        binding.bottom.visibility = if (showBottom) View.VISIBLE else View.GONE

        if (item.isLive) {
            binding.groupAvatarLive.visibility = View.VISIBLE
            binding.avatarNormal.visibility = View.GONE

            Glide.with(binding.avatarLiveAvatar)
                .load(byUserId(videoItem.userId))
                .into(binding.avatarLiveAvatar)

            binding.avatarLive.setOnClickListener {
                LiveController.openLiveRoom(context, item.roomInfo!!)
            }
        } else {
            animatorSet?.cancel()
            binding.groupAvatarLive.visibility = View.GONE
            binding.avatarNormal.visibility = View.VISIBLE

            Glide.with(binding.avatarNormal)
                .load(byUserId(videoItem.userId))
                .into(binding.avatarNormal)
        }

        updateLikeView(context, videoItem)

        binding.comment.text = FormatHelper.formatCount(context, videoItem.commentCount)

        binding.comment.setOnClickListener {
            activity()?.let {
                OuterActions.showCommentDialog(it, videoItem.vid)
            }
        }

        binding.guidelineBottom.setGuidelineEnd(insets.bottom)

        loadCover(videoItem)
    }

    private fun updateLikeView(context: Context, item: VideoItem) {
        animatorListenerAdapter = object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                if (binding.likeContainer.isEnabled) {
                    // Not user triggered event
                    return
                }
                item.likeCount += if (item.isILikeIt) 1 else -1

                binding.like.setAnimation(if (item.isILikeIt) "like_cancel.json" else "like_icondata.json")
                binding.likeNum.text = FormatHelper.formatCount(context, item.likeCount)
                binding.likeContainer.isEnabled = true
            }
        }
        binding.likeNum.text = FormatHelper.formatCount(context, item.likeCount)
        binding.like.setAnimation(if (item.isILikeIt) "like_cancel.json" else "like_icondata.json")
        binding.likeContainer.isEnabled = true
        binding.likeContainer.setOnClickListener {
            binding.likeContainer.isEnabled = false
            item.isILikeIt = !item.isILikeIt
            binding.like.playAnimation()
        }
    }

    fun updateDisplayAnchor(width: Int, height: Int) {
        binding.displayAnchor.updateLayoutParams<ConstraintLayout.LayoutParams> {
            dimensionRatio = "$width:$height"
        }
        binding.fullScreen.visibility = View.VISIBLE
    }

    fun updateDisplayFullScreen() {
        binding.displayAnchor.updateLayoutParams<ConstraintLayout.LayoutParams> {
            dimensionRatio = null
        }

        binding.fullScreen.visibility = View.GONE
    }

    fun onDoubleTap() {
        val item = VideoViewExtras.getVideoItem(videoView())
        if (item == null || item.isILikeIt) {
            return
        }

        binding.likeContainer.performClick()
    }

    override fun onVideoViewPlaySceneChanged(fromScene: Int, toScene: Int) {
        // Short Details Page only shows when in portrait
        if (PlayScene.isFullScreenMode(toScene)) {
            dismiss()
            stopLiveAvatarAnimation()
        } else {
            show()
            showLiveAvatarAnimation()
            VideoViewExtras.getVideoItem(videoView())?.let { item ->
                binding.likeNum.text = FormatHelper.formatCount(context(), item.likeCount)
                binding.like.setAnimation(if (item.isILikeIt) "like_cancel.json" else "like_icondata.json")
                binding.likeContainer.isEnabled = true
            }
        }
    }

    override fun onBindPlaybackController(controller: PlaybackController) {
        controller.addPlaybackListener(mPlaybackListener)
    }

    override fun onUnbindPlaybackController(controller: PlaybackController) {
        controller.removePlaybackListener(mPlaybackListener)
    }

    private val mPlaybackListener = Dispatcher.EventListener { event: Event ->
        when (event.code()) {
            PlaybackEvent.Action.START_PLAYBACK -> {
                val player = player()
                if (player != null && player.isInPlaybackState) {
                    return@EventListener
                }
                showCover()
            }

            PlayerEvent.Action.SET_SURFACE -> {
                val player = player()
                if (player != null && player.isInPlaybackState) {
                    dismissCover()
                } else {
                    showCover()
                }
            }

            PlayerEvent.Action.START -> {
                val player = player()
                if (player != null && player.isPaused) {
                    dismissCover()
                }
            }

            PlaybackEvent.Action.STOP_PLAYBACK, PlayerEvent.Action.STOP, PlayerEvent.Action.RELEASE -> {
                showCover()
            }

            PlayerEvent.Info.VIDEO_RENDERING_START -> {
                dismissCover()
            }
        }
    }

    private fun showCover() {
        binding.displayAnchor.visibility = View.VISIBLE
    }

    private fun dismissCover() {
        binding.displayAnchor.visibility = View.INVISIBLE
    }

    private fun loadCover(item: VideoItem) {
        val config = getConfig<IImageCoverConfig>()
        if (config != null && config.enableCover()) {
            val coverUrl = item.cover
            binding.displayAnchor.post {
                // Should use post to wait ImageView re-layout
                Glide.with(binding.displayAnchor)
                    .load(coverUrl)
                    .transform(CenterCrop())
                    .into(
                        binding.displayAnchor
                    )
            }
        } else {
            binding.displayAnchor.setImageDrawable(null)
        }
    }

    override fun onVideoViewAttachedToWindow(videoView: VideoView) {
        showLiveAvatarAnimation()
    }

    override fun onVideoViewDetachedFromWindow(videoView: VideoView) {
        stopLiveAvatarAnimation()
    }

    private fun showLiveAvatarAnimation() {
        if (binding.groupAvatarLive.visibility == View.VISIBLE) {
            // host is Live, show animation
            if (animatorSet?.isRunning == false) {
                animatorSet?.start()
            }
        }
    }

    private fun stopLiveAvatarAnimation() {
        if (binding.groupAvatarLive.visibility == View.VISIBLE) {
            if (animatorSet?.isRunning == true) {
                animatorSet?.cancel()
            }
        }
    }

    override fun onSurfaceAvailable(surface: Surface, width: Int, height: Int) {
        val videoView = videoView() ?: return

        if (player() != null) {
            return
        }

        val rendered = ShortVideoStrategy.renderFrame(videoView)
        if (rendered) {
            L.d(this, "onSurfaceAvailable", videoView, surface, "preRender success")
            dismissCover()
        } else {
            L.d(this, "onSurfaceAvailable", videoView, surface, "preRender failed")
            showCover()
        }
    }
}