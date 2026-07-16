// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer.dialog

import android.content.res.Resources
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.content.ContextCompat.getString
import androidx.core.view.updateLayoutParams
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.byteplus.playerkit.player.playback.VideoLayerHost
import com.byteplus.vod.scenekit.R
import com.byteplus.vod.scenekit.databinding.VevodCastingDeviceItemBinding
import com.byteplus.vod.scenekit.databinding.VevodCastingDeviceLayoutBinding
import com.byteplus.vod.scenekit.ui.video.layer.Layers
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene
import com.byteplus.vodcast.api.CastDevice
import com.byteplus.vodcast.api.CastSdk
import com.byteplus.vodcast.api.ICastController
import com.byteplus.vodcast.api.IDiscovery
import kotlin.math.max

typealias CastingDeviceSelectedListener = (CastDevice?) -> Unit

/**
 * 设备发现 / 选择 弹窗（M2 重构版）。
 * - 内部直接通过 [CastSdk] 获取 [IDiscovery] / [ICastController]，不再持有任何旧 Adapter。
 * - 非全屏也允许显示（B10）。
 */
class CastingDeviceSearchDialogLayer : DialogLayer() {

    companion object {
        const val TAG = "CAST_DEMO"
    }

    private var binding: VevodCastingDeviceLayoutBinding? = null

    private var viewCreated = false

    private var deviceSelectListener: CastingDeviceSelectedListener? = null

    private val discovery: IDiscovery?
        get() = CastSdk.discoveryOrNull()

    private val controller: ICastController?
        get() = CastSdk.controllerOrNull()

    private val mDeviceAdapter by lazy {
        DeviceAdapter(
            isDeviceSelected = { device ->
                // 用 controller 当前快照里的 device.id 判断选中
                runCatching {
                    controller?.currentRemoteState()?.device?.id == device.id
                }.getOrDefault(false)
            },
            onItemClick = { _, deviceInfo ->
                Log.d(TAG, "onDeviceClick: select device to casting,device = $deviceInfo")
                runCatching { controller?.connect(deviceInfo) }
                deviceSelectListener?.invoke(deviceInfo)
            }
        )
    }

    private val mDeviceStateCallback by lazy {
        object : IDiscovery.Listener {
            override fun onDevicesChanged(devices: List<CastDevice>) {
                Log.d(TAG, "onDeviceChanged: deviceList = $devices")
                updateCastingDeviceUI()
            }
        }
    }


    private fun updateCastingDeviceUI() {
        val discovery = this.discovery ?: run {
            // Casting unavailable (e.g. no Google Play Services). Nothing to show.
            animateDismiss()
            return
        }
        val inScanning = discovery.isScanning
        val deviceList = discovery.currentDevices()

        binding?.ivRefresh?.setOnClickListener {
            discovery.refresh()
        }

        if (inScanning) {
            if (deviceList.isEmpty()) {
                binding?.tvCastingDeviceTitle?.text =
                    context()?.let { getString(it, R.string.vevod_casting_searching_devices) }
                binding?.llCastingDeviceList?.visibility = View.GONE
                binding?.ivCastingTipsImg?.visibility = View.VISIBLE
            } else {
                binding?.llCastingDeviceList?.visibility = View.VISIBLE
                binding?.ivCastingTipsImg?.visibility = View.GONE
                binding?.tvCastingDeviceTitle?.text =
                    context()?.let { getString(it, R.string.vevod_casting_select_device) }
                if (binding?.recyclerView?.adapter == null) {
                    // 配置 RecyclerView
                    binding?.recyclerView?.apply {
                        layoutManager = LinearLayoutManager(context)
                        adapter = mDeviceAdapter
                        addItemDecoration( // 添加分割线
                            DividerItemDecoration(context, LinearLayoutManager.VERTICAL)
                        )
                        mDeviceAdapter.submitList(deviceList.toMutableList())
                    }
                } else {
                    // 更新设备列表
                    mDeviceAdapter.submitList(deviceList.toMutableList())
                }
            }

        } else {
            // 还没启动扫描，主动 start。回调注册统一放在 onBindLayerHost / createDialogView，
            // 这里不再重复 addListener，避免监听器残留在单例 discovery 中导致页面泄漏。
            discovery.start()
        }
    }

    override fun onBindLayerHost(layerHost: VideoLayerHost) {
        super.onBindLayerHost(layerHost)
        val discovery = this.discovery ?: return
        discovery.addListener(mDeviceStateCallback)
        discovery.start()
    }


    override fun onUnbindLayerHost(layerHost: VideoLayerHost) {
        super.onUnbindLayerHost(layerHost)
        releaseDiscovery()
    }

    /**
     * 释放对单例 discovery 的监听与对外部对象的引用。
     *
     * discovery 是进程级单例：若不在页面销毁时移除监听器，单例会经
     * listeners -> mDeviceStateCallback -> this -> deviceSelectListener(Fragment) / mLayerView(Activity)
     * 长期持有整个页面，造成 Activity/Fragment 泄漏。
     *
     * 注意：宿主销毁时 [onUnbindLayerHost] 不保证被调用（layer 未显式从 host 移除时不会触发），
     * 因此宿主（Fragment）必须在 onDestroyView 主动调用本方法兜底。本方法幂等。
     */
    fun releaseDiscovery() {
        CastSdk.discoveryOrNull()?.let {
            it.removeListener(mDeviceStateCallback)
            it.stop()
        }
        // 主动断开对外部（Fragment lambda）的引用，进一步阻断泄漏链。
        deviceSelectListener = null
        binding = null
    }

    override fun show() {
        // 非全屏也允许显示
        super.show()
    }

    override fun animateShow(autoDismiss: Boolean) {
        // 非全屏也允许显示
        super.animateShow(autoDismiss)
    }


    override fun createDialogView(parent: ViewGroup): View {
        // 进入弹窗时立即触发一次扫描，提升用户感知
        runCatching { discovery?.start() }
        binding = VevodCastingDeviceLayoutBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )

        val videoView = videoView()
        var defaultWidth = 360.dpToPx()
        if (videoView != null && videoView.width > 0 && videoView.height > 0) {
            val maxDimension = max(videoView.width, videoView.height)
            defaultWidth = (maxDimension * 0.44).toInt()
        }

        binding?.root?.setOnClickListener {
            animateDismiss()
        }


        val dialogWrapper: View? = binding?.llCastingDialogWrapper
        dialogWrapper?.setOnClickListener {
            // consume click
        }
        dialogWrapper?.adjustWithConstraints(defaultWidth, endMarginDp = 44, verticalMarginDp = 8)
        viewCreated = true
        updateCastingDeviceUI()
        return binding!!.root
    }


    private fun View.adjustWithConstraints(
        width: Int,
        endMarginDp: Int,
        verticalMarginDp: Int
    ) {
        post {
            updateLayoutParams<FrameLayout.LayoutParams> {
                this.width = width
                topMargin = verticalMarginDp.dpToPx()
                bottomMargin = verticalMarginDp.dpToPx()
                marginEnd = endMarginDp.dpToPx()
                gravity = Gravity.END or Gravity.CENTER_VERTICAL
            }
        }
    }

    // dp 转 px 扩展函数
    private fun Int.dpToPx(): Int =
        (this * Resources.getSystem().displayMetrics.density).toInt()

    override fun backPressedPriority() = Layers.BackPriority.CASTING_DIALOG_BACK_PRIORITY


    override fun tag() =
        "castingDeviceSearchDialog"

    override fun onVideoViewPlaySceneChanged(fromScene: Int, toScene: Int) {
        // Casting is fullscreen-only; dismiss the device dialog when leaving fullscreen
        // so it does not linger (mis-sized) on the half-screen portrait layout.
        if (!PlayScene.isFullScreenMode(toScene)) {
            animateDismiss()
        }
    }

    fun setOnCastingDeviceSelectedListener(selectedListener: CastingDeviceSelectedListener) {
        this.deviceSelectListener = selectedListener
    }
}

class DeviceDiffCallback : DiffUtil.ItemCallback<CastDevice>() {
    // 判断是否为同一设备（依据唯一 id）
    override fun areItemsTheSame(oldItem: CastDevice, newItem: CastDevice): Boolean {
        return oldItem.id == newItem.id
    }

    // 判断内容是否相同（整体比较）
    override fun areContentsTheSame(oldItem: CastDevice, newItem: CastDevice): Boolean {
        return oldItem == newItem
    }
}


class DeviceAdapter(
    private val isDeviceSelected: (CastDevice) -> Boolean,
    private val onItemClick: (Int, CastDevice) -> Unit // 点击事件回调
) : ListAdapter<CastDevice, DeviceAdapter.DeviceViewHolder>(DeviceDiffCallback()) {
    // ViewHolder 类（使用 ViewBinding）
    inner class DeviceViewHolder(
        private val binding: VevodCastingDeviceItemBinding // ViewBinding 生成的绑定类
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(device: CastDevice) {
            binding.apply {
                Glide.with(ivCastingDeviceIc)
                    .load(device.iconUri)
                    .error(R.drawable.vevod_casting_device_ic)
                    .into(ivCastingDeviceIc)

                tvCastingDeviceName.text = device.name
                root.setOnClickListener { onItemClick(absoluteAdapterPosition, device) } // 设置点击事件
                ivSelectDot.visibility =
                    if (isDeviceSelected(device)) View.VISIBLE else View.GONE
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DeviceViewHolder {
        val binding = VevodCastingDeviceItemBinding.inflate( // 通过 ViewBinding 加载布局
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return DeviceViewHolder(binding)
    }

    override fun onBindViewHolder(holder: DeviceViewHolder, position: Int) {
        holder.bind(getItem(position)) // 绑定数据
    }
}
