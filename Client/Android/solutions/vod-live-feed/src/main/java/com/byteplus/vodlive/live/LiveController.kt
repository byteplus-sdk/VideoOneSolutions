// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live

import android.content.Context
import android.content.Intent
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.byteplus.vodlive.live.player.LivePlayer
import com.byteplus.vodlive.live.player.PlayerScene
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.utils.playerLog
import java.lang.ref.WeakReference

internal class LiveController(
    private val context: Context,
    private val scene: PlayerScene = PlayerScene.DEFAULT
) : LifecycleEventObserver {
    val feedHolder: LiveFeedHolder?
        get() = lastPlayHolder as? LiveFeedHolder

    private var lastPreviewHolder: ILiveViewHolder? = null
    private var lastPlayHolder: ILiveViewHolder? = null

    private var preloadPlayer: LivePlayer? = null

    fun preload(holder: ILiveViewHolder?, item: LiveFeedItem) {
        if (!ENABLE_PRELOAD_LIVE) return
        val player = holder?.player ?: createLivePlayer(context, item.roomId).also {
            preloadPlayer = it
            holder?.bindPlayer(it)
        }
        player.startWithUrl(item, preload = true)
    }

    fun preview(holder: ILiveViewHolder, item: LiveFeedItem) {
        lastPreviewHolder?.stop(scene)
        lastPreviewHolder = holder

        val player = holder.player ?: createLivePlayer(context, item.roomId)
        holder.bindPlayer(player)

        player.startWithUrl(item, mute = true)
    }

    fun select(holder: ILiveViewHolder, item: LiveFeedItem) {
        // Stop Live Preview trigger by user drag
        if (lastPreviewHolder !== holder) {
            lastPreviewHolder?.stop(scene)
        }
        lastPreviewHolder = null

        lastPlayHolder?.let {
            it.stop(scene)
            it.unselect()

            if (it.player?.isShared == true) {
                it.unbindPlayer()
            }
        }
        lastPlayHolder = holder

        val player = holder.player ?: createLivePlayer(context, item.roomId)
        holder.bindPlayer(player)
        player.startWithUrl(item)
    }

    fun stop() {
        lastPreviewHolder?.stop(scene)
        lastPreviewHolder = null

        lastPlayHolder?.stop(scene)
        lastPlayHolder = null
    }

    private fun createLivePlayer(context: Context, roomId: String): LivePlayer {
        LiveController[roomId]?.let {
            playerLog(TAG, "reuse player: $roomId, scene=${it.scene}")
            it.scene = this.scene
            return it
        }

        preCreatedPlayer?.let {
            preCreatedPlayer = null
            if (it.roomId == roomId) {
                playerLog(TAG, "reuse preCreate player: $roomId")
                return it
            } else {
                playerLog(TAG, "discard preCreate player[$roomId]: not match $roomId")
            }
        }

        preloadPlayer?.let {
            if (it.roomId == roomId) {
                playerLog(TAG, "reuse preload player: $roomId")
                preloadPlayer = null
                return it
            }
        }

        playerLog(TAG, "create player: roomId=$roomId")
        return LivePlayer(context, scene = this.scene).also {
            players.add(it)
        }
    }

    private val players = ArrayList<LivePlayer>()

    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        when (event) {
            Lifecycle.Event.ON_START -> {
                lastPlayHolder?.start(scene)
            }

            Lifecycle.Event.ON_STOP -> {
                lastPlayHolder?.stop(scene)
            }

            Lifecycle.Event.ON_DESTROY -> {
                playerLog(TAG, "ON_DESTROY")
                players.forEach {
                    it.release()
                }
                players.clear()
            }

            else -> {

            }
        }
    }

    private var finishing = false

    fun onFinish() {
        finishing = true
        sharedPlayer?.start(mute = true)
    }

    companion object {
        const val TAG = "LiveController"

        private const val ENABLE_PRELOAD_LIVE = true

        private var playerRef: WeakReference<LivePlayer> = WeakReference(null)

        var sharedPlayer: LivePlayer?
            get() = playerRef.get()
            set(value) {
                playerRef = WeakReference(value)
            }

        operator fun get(roomId: String): LivePlayer? {
            return playerRef.get()?.takeIf { it.roomId == roomId }
        }

        private var preCreatedPlayer: LivePlayer? = null

        private fun preCreateLivePlayer(context: Context, item: LiveFeedItem) {
            preCreatedPlayer = LivePlayer(context, scene = PlayerScene.FEED).apply {
                startWithUrl(item, mute = true)
            }
        }

        fun openLiveRoom(context: Context, item: LiveFeedItem) {
            preCreateLivePlayer(context, item)

            context.startActivity(Intent(context, LiveFeedActivity::class.java).apply {
                putExtra(EXTRA_LIVE_ROOM, item)
            })
        }
    }
}