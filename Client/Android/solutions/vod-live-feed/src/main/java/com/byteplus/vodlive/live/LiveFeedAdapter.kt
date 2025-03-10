// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.graphics.Insets
import androidx.core.view.updateLayoutParams
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.byteplus.vodlive.annotation.MessageType
import com.byteplus.vodlive.databinding.LiveFeedItemBinding
import com.byteplus.vodlive.live.event.CloseAction
import com.byteplus.vodlive.live.event.CommentAction
import com.byteplus.vodlive.live.event.GiftAction
import com.byteplus.vodlive.live.event.LikeAction
import com.byteplus.vodlive.live.event.MessageReceivedEvent
import com.byteplus.vodlive.live.player.LivePlayer
import com.byteplus.vodlive.live.room.RoomEventBus
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.utils.GlideBlur.blur
import com.vertcdemo.core.chat.ChatAdapter
import com.vertcdemo.core.chat.gift.GiftAnimateHelper
import com.vertcdemo.core.utils.DebounceClickListener
import com.videoone.avatars.Avatars

internal class LiveFeedAdapter(private val controller: LiveController) :
    RecyclerView.Adapter<LiveFeedHolder>() {

    private var items: List<LiveFeedItem> = emptyList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LiveFeedHolder {
        return LiveFeedHolder(
            LiveFeedItemBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
        )
    }

    override fun onBindViewHolder(holder: LiveFeedHolder, position: Int) {
        val item = items[position]
        holder.onBind(item)
    }

    override fun getItemCount(): Int = items.size

    fun setItems(items: List<LiveFeedItem>) {
        val oldItems = this.items
        this.items = items

        DiffUtil.calculateDiff(object : DiffUtil.Callback() {
            override fun getOldListSize(): Int = oldItems.size

            override fun getNewListSize(): Int = items.size

            override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
                return oldItems[oldItemPosition] === items[newItemPosition]
            }

            override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
                val old = oldItems[oldItemPosition]
                val new = items[newItemPosition]
                return old.roomId == new.roomId
                        && old.hostName == new.hostName
                        && old.roomDesc == new.roomDesc
                        && old.coverUrl == new.coverUrl
            }
        })
            .dispatchUpdatesTo(this)
    }

    fun getItem(position: Int): LiveFeedItem = items[position]

    override fun onViewDetachedFromWindow(holder: LiveFeedHolder) {
        val player = holder.unbindPlayer() ?: return
        controller.recycle(player)
    }
}

class LiveFeedHolder(
    private val binding: LiveFeedItemBinding
) : RecyclerView.ViewHolder(binding.root), ILiveViewHolder {
    private val context: Context
        get() = binding.root.context

    override var player: LivePlayer? = null
        private set

    override fun bindPlayer(player: LivePlayer) {
        player.attach(binding.videoContainer)
        this.player = player
    }

    override fun unbindPlayer(): LivePlayer? {
        val player = this.player ?: return null
        this.player = null
        player.detach()
        return player
    }

    val roomId: String
        get() = item.roomId

    private val chatAdapter: ChatAdapter = ChatAdapter.bind(binding.messagePanel)

    private val giftAnimateHelper = GiftAnimateHelper(context, binding.giftSlot1, binding.giftSlot2)

    private lateinit var item: LiveFeedItem

    fun onBind(item: LiveFeedItem) {
        this.item = item

        bindCoverOrSnapshot(item)

        binding.hostAvatar.let {
            it.userAvatar.setImageResource(Avatars.byUserId(item.hostUserId));
            it.userName.text = item.hostName
        }

        binding.close.setOnClickListener(DebounceClickListener {
            RoomEventBus.post(CloseAction)
        })

        binding.comment.setOnClickListener(DebounceClickListener {
            RoomEventBus.post(CommentAction(item))
        })

        binding.liveGift.setOnClickListener(DebounceClickListener {
            RoomEventBus.post(GiftAction(item))
        })

        binding.liveLike.setOnClickListener(DebounceClickListener(100) {
            RoomEventBus.post(LikeAction(item))
        })
    }

    private fun bindCoverOrSnapshot(item: LiveFeedItem) {
        val player = LiveController[item.roomId]
        if (player != null && player.isShared) {
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
        binding.snapshotView.visibility = View.GONE
        binding.cover.visibility = View.VISIBLE
        Glide.with(binding.cover)
            .load(item.coverUrl)
            .blur()
            .into(binding.cover)
    }

    fun onMessageEvent(event: MessageReceivedEvent) {
        when (event.type) {
            MessageType.MSG -> onNormalMessage(event)
            MessageType.GIFT -> onGiftMessage(event)
            MessageType.LIKE -> onLikeMessage()
        }
    }

    fun updateAudienceCount(count: Int) {
        binding.audienceNum.text = "$count"
    }

    private fun onNormalMessage(event: MessageReceivedEvent) {
        chatAdapter.onNormalMessage(context, event.userName, event.content, false)
        binding.messagePanel.post {
            binding.messagePanel.smoothScrollToPosition(chatAdapter.itemCount)
        }
    }

    private fun onGiftMessage(event: MessageReceivedEvent) {
        giftAnimateHelper.post(event)
    }

    private fun onLikeMessage() {
        binding.likeArea.startAnimation();
    }

    fun showRoomUI(insets: Insets, audienceCount: Int) {
        binding.guidelineTop.setGuidelineBegin(insets.top)
        binding.guidelineBottom.setGuidelineEnd(insets.bottom)
        binding.audienceNum.text = "$audienceCount"
        binding.roomGroup.visibility = ViewGroup.VISIBLE
    }

    override fun unselect() {
        binding.roomGroup.visibility = ViewGroup.GONE
        chatAdapter.clear()
        giftAnimateHelper.clear()
        binding.likeArea.clear()
    }
}