// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.live

import com.byteplus.vodlive.live.player.LivePlayer
import com.byteplus.vodlive.live.player.PlayerScene
import com.byteplus.vodlive.utils.playerLog

interface ILiveViewHolder {
    companion object {
        const val TAG = "LiveViewHolder"
    }

    val player: LivePlayer?

    val playerScene: PlayerScene
        get() = player?.scene ?: PlayerScene.DEFAULT

    fun bindPlayer(player: LivePlayer)

    fun unbindPlayer()

    fun start(scene: PlayerScene) {
        playerLog(TAG, "startLive: scene=$scene, playerScene=${playerScene}")
        player?.start()
    }

    fun unselect() {

    }

    fun stop(scene: PlayerScene) {
        playerLog(TAG, "stopLive: scene=$scene, playerScene=${playerScene}")
        if (scene != playerScene) {
            playerLog(TAG, "stopLive: skip by scene not match")
            return
        }
        player?.stop()
    }
}