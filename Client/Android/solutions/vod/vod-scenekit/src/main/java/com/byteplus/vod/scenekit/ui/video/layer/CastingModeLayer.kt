// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.byteplus.vod.scenekit.databinding.VevodCastingModeLayerLayoutBinding
import com.byteplus.vod.scenekit.ui.video.layer.base.AnimateLayer
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene

class CastingModeLayer(
    val onClickSwitchDevice: () -> Unit,
    val onClickEndSession: () -> Unit
) : AnimateLayer() {

    private var binding: VevodCastingModeLayerLayoutBinding? = null
    override fun tag(): String = "CastingModeLayer"

    override fun createView(parent: ViewGroup): View? {
        binding = VevodCastingModeLayerLayoutBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        ).apply {
            tvSwitchDevice.setOnClickListener {
                onClickSwitchDevice()
            }
            tvEndSession.setOnClickListener {
                onClickEndSession()
                animateDismiss()
            }
        }
        return binding?.root
    }


    private fun isFullScreen(): Boolean {
        return PlayScene.isFullScreenMode(playScene())
    }


    fun setCastingDeviceName(name: String?) {
        binding?.tvCastingDeviceName?.text = name
    }

    override fun animateShow(autoDismiss: Boolean) {
        if (!isFullScreen()) return
        super.animateShow(autoDismiss)
        operateControllerLayer(true)
    }

    override fun show() {
        if (!isFullScreen()) return
        super.show()
    }

    override fun animateDismiss() {
        super.animateDismiss()
        operateControllerLayer(false)
    }


    private fun operateControllerLayer(show: Boolean) {
        val layerHost = layerHost() ?: return
        val gestureLayer: GestureLayer? =
            layerHost.findLayer(GestureLayer::class.java)
        if (show) {
            gestureLayer?.showController()
            layerHost.findLayer(PlayPauseLayer::class.java)?.dismiss()
        } else {
            gestureLayer?.dismissController()
            // Restore the local play/pause button when leaving casting mode,
            // otherwise it stays hidden and the user must tap twice to resume.
            layerHost.findLayer(PlayPauseLayer::class.java)?.show()
        }
    }

}