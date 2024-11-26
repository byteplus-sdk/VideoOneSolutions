package com.byteplus.vodlive.live.player

import android.graphics.SurfaceTexture
import android.view.TextureView
import com.byteplus.vodlive.utils.playerLog

class LivePlayerTextureListener(private val player: LivePlayer) :
    TextureView.SurfaceTextureListener {

    companion object {
        private const val TAG = "LivePlayerTextureListener"
    }

    private val identity = player.identity

    private var isFirstFrame: Boolean = true

    override fun onSurfaceTextureAvailable(
        surface: SurfaceTexture,
        width: Int,
        height: Int
    ) {
        playerLog(
            TAG,
            "[${player.identity}] onSurfaceTextureAvailable: "
        )
        player.setSurfaceTexture(surface)
        isFirstFrame = true
    }

    override fun onSurfaceTextureSizeChanged(
        surface: SurfaceTexture,
        width: Int,
        height: Int
    ) {
        playerLog(TAG, "[$identity] onSurfaceTextureSizeChanged: ")
    }

    override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
        playerLog(TAG, "[$identity] onSurfaceTextureDestroyed: ")
        player.setSurfaceTexture(null)
        return true
    }

    override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {
        if (isFirstFrame) {
            isFirstFrame = false
            playerLog(TAG, "[$identity] onFirstSurfaceTextureUpdated")
            player.onFirstSurfaceTextureUpdated()
        }
    }
}