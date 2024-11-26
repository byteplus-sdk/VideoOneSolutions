package com.byteplus.vodlive.recommend

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.view.GestureDetector
import android.view.GestureDetector.SimpleOnGestureListener
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.graphics.Insets
import androidx.core.view.updateLayoutParams
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.Adapter
import com.bumptech.glide.Glide
import com.byteplus.playerkit.player.playback.DisplayModeHelper
import com.byteplus.playerkit.player.playback.DisplayView
import com.byteplus.playerkit.player.playback.VideoLayerHost
import com.byteplus.playerkit.player.playback.VideoView
import com.byteplus.vod.scenekit.data.model.VideoItem
import com.byteplus.vod.scenekit.ui.base.VideoViewExtras
import com.byteplus.vod.scenekit.ui.video.layer.LoadingLayer
import com.byteplus.vod.scenekit.ui.video.layer.LockLayer
import com.byteplus.vod.scenekit.ui.video.layer.LogLayer
import com.byteplus.vod.scenekit.ui.video.layer.PauseLayer
import com.byteplus.vod.scenekit.ui.video.layer.PlayErrorLayer
import com.byteplus.vod.scenekit.ui.video.layer.PlayerConfigLayer
import com.byteplus.vod.scenekit.ui.video.layer.TitleBarLayer
import com.byteplus.vod.scenekit.ui.video.layer.dialog.MoreDialogLayer
import com.byteplus.vod.scenekit.ui.video.layer.dialog.QualitySelectDialogLayer
import com.byteplus.vod.scenekit.ui.video.layer.dialog.SpeedSelectDialogLayer
import com.byteplus.vod.scenekit.ui.video.layer.dialog.VolumeBrightnessDialogLayer
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.DoubleTapHeartHelper
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoFullScreenLayer
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoGestureLayer
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoPlayCompleteLayer
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoPlayPauseLayer
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoProgressBarLayer
import com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer.ShortVideoTimeProgressBarLayer
import com.byteplus.vodlive.R
import com.byteplus.vodlive.databinding.RecommendItemLiveBinding
import com.byteplus.vodlive.databinding.RecommendItemVodBinding
import com.byteplus.vodlive.layer.VideoDetailsLayer
import com.byteplus.vodlive.live.EXTRA_LIVE_ROOM
import com.byteplus.vodlive.live.ILiveViewHolder
import com.byteplus.vodlive.live.LiveController
import com.byteplus.vodlive.live.LiveFeedActivity
import com.byteplus.vodlive.live.player.LivePlayer
import com.byteplus.vodlive.live.player.PlayerScene
import com.byteplus.vodlive.model.FeedItem
import com.byteplus.vodlive.model.VodFeedItem
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.utils.GlideBlur.blur
import com.byteplus.vodlive.utils.playerLog
import com.vertcdemo.base.ReportDialog
import com.vertcdemo.core.utils.DebounceClickListener

internal class RecommendAdapter :
    Adapter<RecommendViewHolder>() {

    companion object {
        private const val TAG = "RecommendAdapter"

        private const val VIEW_TYPE_INVALID = -1
        private const val VIEW_TYPE_VOD = 1
        private const val VIEW_TYPE_LIVE = 2
    }

    var insets = Insets.NONE

    private var items: List<FeedItem> = emptyList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecommendViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return when (viewType) {
            VIEW_TYPE_VOD -> {
                VodViewHolder(RecommendItemVodBinding.inflate(inflater, parent, false))
            }

            VIEW_TYPE_LIVE -> {
                playerLog(TAG, "create LiveViewHolder")
                LiveViewHolder(
                    RecommendItemLiveBinding.inflate(
                        inflater,
                        parent,
                        false
                    )
                )
            }

            else -> {
                throw IllegalArgumentException("Unknown viewType: $viewType")
            }
        }
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: RecommendViewHolder, position: Int) {
        val item = items[position]
        when (holder) {
            is VodViewHolder -> holder.onBind(item as VodFeedItem, insets)
            is LiveViewHolder -> holder.onBind(item as LiveFeedItem)
        }
    }

    override fun getItemViewType(position: Int): Int = when (items[position]) {
        is VodFeedItem -> VIEW_TYPE_VOD
        is LiveFeedItem -> VIEW_TYPE_LIVE
        else -> VIEW_TYPE_INVALID
    }

    fun getItem(next: Int): FeedItem = items[next]

    fun setItems(items: List<FeedItem>) {
        val oldItems = this.items
        this.items = items

        DiffUtil.calculateDiff(object : DiffUtil.Callback() {
            override fun getOldListSize(): Int = oldItems.size

            override fun getNewListSize(): Int = items.size

            override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
                val old = oldItems[oldItemPosition]
                val new = items[newItemPosition]
                if (old is LiveFeedItem && new is LiveFeedItem) {
                    return old.roomId == new.roomId
                }

                return old === new
            }

            override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
                val old = oldItems[oldItemPosition]
                val new = items[newItemPosition]
                return when {
                    old is VodFeedItem && new is VodFeedItem -> {
                        old.userStatus == new.userStatus
                                && old.videoItem.vid == new.videoItem.vid
                                && old.videoItem.userName == new.videoItem.userName
                                && old.videoItem.subtitle == new.videoItem.subtitle
                                && old.videoItem.cover == new.videoItem.cover
                                && old.videoItem.userId == new.videoItem.userId
                                && old.videoItem.commentCount == new.videoItem.commentCount
                                && old.videoItem.likeCount == new.videoItem.likeCount
                                && old.videoItem.isILikeIt == new.videoItem.isILikeIt
                                && old.videoItem.width == new.videoItem.width
                                && old.videoItem.height == new.videoItem.height
                    }

                    old is LiveFeedItem && new is LiveFeedItem -> {
                        old.roomId == new.roomId
                                && old.hostName == new.hostName
                                && old.roomDesc == new.roomDesc
                                && old.coverUrl == new.coverUrl
                    }

                    else -> {
                        false
                    }
                }
            }

            override fun getChangePayload(oldItemPosition: Int, newItemPosition: Int): Any? {
                return super.getChangePayload(oldItemPosition, newItemPosition)
            }
        }).dispatchUpdatesTo(this)
    }
}

internal open class RecommendViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

@SuppressLint("ClickableViewAccessibility")
internal class VodViewHolder(
    private val binding: RecommendItemVodBinding,
    private val onExitFullScreen: Runnable? = null
) :
    RecommendViewHolder(binding.root) {
    val videoView: VideoView
        get() = binding.videoView

    private val layerHost: VideoLayerHost
    private val detailsLayer: VideoDetailsLayer
    private val fullScreenLayer: ShortVideoFullScreenLayer

    private val progressBarLayer: ShortVideoProgressBarLayer

    init {
        val context = itemView.context
        detailsLayer = VideoDetailsLayer()
        fullScreenLayer = ShortVideoFullScreenLayer()

        layerHost = VideoLayerHost(context, RecommendVideoStrategy)
        layerHost.addLayer(fullScreenLayer)
        layerHost.addLayer(detailsLayer)

        layerHost.addLayer(ShortVideoGestureLayer())

        layerHost.addLayer(TitleBarLayer(PlayScene.SCENE_FULLSCREEN))
        layerHost.addLayer(ShortVideoTimeProgressBarLayer())

        layerHost.addLayer(VolumeBrightnessDialogLayer())
        layerHost.addLayer(ShortVideoPlayPauseLayer())
        layerHost.addLayer(LockLayer())

        layerHost.addLayer(LoadingLayer())
        layerHost.addLayer(PauseLayer())

        progressBarLayer = ShortVideoProgressBarLayer()
        layerHost.addLayer(progressBarLayer)
        layerHost.addLayer(PlayErrorLayer())
        layerHost.addLayer(PlayerConfigLayer())
        layerHost.addLayer(ShortVideoPlayCompleteLayer())
        if (RecommendVideoStrategy.enableLogLayer()) {
            layerHost.addLayer(LogLayer())
        }

        layerHost.addLayer(MoreDialogLayer.createWithoutLoopMode())
        layerHost.addLayer(QualitySelectDialogLayer())
        layerHost.addLayer(SpeedSelectDialogLayer())

        layerHost.attachToVideoView(videoView)
        videoView.setBackgroundColor(ContextCompat.getColor(context, android.R.color.black))

        //videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT); // fit mode
        videoView.displayMode = DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL // immersive mode
        videoView.selectDisplayView(DisplayView.DISPLAY_VIEW_TYPE_TEXTURE_VIEW)
        videoView.playScene = PlayScene.SCENE_SHORT

        val detector = GestureDetector(context, object : SimpleOnGestureListener() {
            override fun onDown(e: MotionEvent) = true

            override fun onSingleTapConfirmed(e: MotionEvent): Boolean {
                videoView.performClick()
                return true
            }

            override fun onDoubleTap(e: MotionEvent): Boolean {
                DoubleTapHeartHelper.show(
                    itemView as ViewGroup,
                    e.x.toInt(),
                    e.y.toInt()
                )

                detailsLayer.onDoubleTap()
                return true
            }

            override fun onLongPress(e: MotionEvent) =
                ReportDialog.show(context)
        })

        videoView.setOnTouchListener { _, event -> detector.onTouchEvent(event) }
    }

    fun onBind(item: VodFeedItem, insets: Insets = Insets.NONE) {
        val videoItem = item.videoItem
        val fsLayer = fullScreenLayer
        if ((videoItem.width != 0 && videoItem.height != 0) && videoItem.width > videoItem.height) {  // Support Landscape mode
            videoView.displayMode = DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL_X

            detailsLayer.updateDisplayAnchor(videoItem.width, videoItem.height)
            fsLayer.setAfterExitFullScreenListener(onExitFullScreen)
        } else { // Support Portrait mode
            videoView.displayMode = DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL

            detailsLayer.updateDisplayFullScreen()
            fsLayer.setAfterExitFullScreenListener(null)
        }

        detailsLayer.bind(item, insets)
        progressBarLayer.onApplyInsets(insets)

        var mediaSource = videoView.dataSource
        if (mediaSource == null) {
            mediaSource = VideoItem.toMediaSource(videoItem)
            videoView.bindDataSource(mediaSource)
            VideoViewExtras.updateExtra(videoView, videoItem)
        } else {
            if (!videoItem.vid.equals(mediaSource.mediaId)) {
                videoView.stopPlayback()
                mediaSource = VideoItem.toMediaSource(videoItem)
                videoView.bindDataSource(mediaSource)
                VideoViewExtras.updateExtra(videoView, videoItem)
            } else {
                // do nothing
            }
        }
    }
}

internal class LiveViewHolder(
    private val binding: RecommendItemLiveBinding
) :
    RecommendViewHolder(binding.root), ILiveViewHolder {
    private val context: Context = binding.root.context

    override var player: LivePlayer? = null
        private set

    override fun bindPlayer(player: LivePlayer) {
        player.attach(binding.videoContainer)
        this.player = player
    }

    override fun unbindPlayer() {
        player?.detach()
        this.player = null
    }

    private lateinit var item: LiveFeedItem

    override fun start(scene: PlayerScene) {
        if (playerScene != scene) {
            playerLog(TAG, "Player shared, take over it")
            val player = this.player!!
            bindSnapshot(player)
            player.updateScene(scene = scene, isShared = false)
            bindPlayer(player)
            LiveController.sharedPlayer = null
        }
        super.start(scene)
    }

    private fun bindSnapshot(player: LivePlayer) {
        if (player.isShared) {
            val bitmap = player.createSnapshot()
            if (bitmap != null) {
                binding.snapshotView.updateLayoutParams<ConstraintLayout.LayoutParams> {
                    dimensionRatio = "${bitmap.width}:${bitmap.height}"
                }
                binding.snapshotView.setImageBitmap(bitmap)

                binding.snapshotView.visibility = View.VISIBLE
                binding.cover.visibility = View.GONE
                return
            }
        }
    }

    fun onBind(item: LiveFeedItem) {
        this.item = item
        binding.snapshotView.visibility = View.GONE
        binding.cover.visibility = View.VISIBLE
        Glide.with(binding.cover)
            .load(item.coverUrl)
            .blur()
            .into(binding.cover)

        binding.title.text = context.getString(R.string.vlive_video_at, item.hostName)
        binding.subtitle.text = item.roomDesc

        binding.join.setOnClickListener(DebounceClickListener {
            LiveController.sharedPlayer = this.player?.also {
                it.updateScene(scene = PlayerScene.FEED, isShared = true)
                // it.snapshot()
            } ?: return@DebounceClickListener

            context.startActivity(Intent(context, LiveFeedActivity::class.java).apply {
                item.disableCover = true
                putExtra(EXTRA_LIVE_ROOM, item)
            })
        })
    }

    companion object {
        private const val TAG = "LiveViewHolder"
    }
}
