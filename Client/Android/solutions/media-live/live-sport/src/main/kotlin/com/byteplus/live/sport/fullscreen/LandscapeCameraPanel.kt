// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.app.Activity
import android.graphics.Typeface
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.byteplus.live.sport.R
import com.byteplus.live.sport.data.SportChannel

/**
 * Landscape multi-camera side-panel (Figma node 10796:42031). Right-anchored
 * dark card listing the available channels as thumbnail + name cards. Tapping
 * a channel commits the switch via [onPicked] and dismisses the panel.
 */
class LandscapeCameraPanel(
    activity: Activity,
    private val channels: List<SportChannel>,
    private val selectedId: String?,
    private val onPicked: (index: Int, channel: SportChannel) -> Unit,
) : LandscapeSidePanel(
    activity = activity,
    widthPx = (activity.resources.displayMetrics.density * PANEL_WIDTH_DP).toInt(),
) {

    override fun onCreateContent(inflater: LayoutInflater): View =
        inflater.inflate(R.layout.live_sport_panel_landscape_camera, null, false)

    override fun onBind(content: View) {
        val list = content.findViewById<RecyclerView>(R.id.landscape_camera_list)
        list.layoutManager = LinearLayoutManager(content.context)
        list.adapter = CameraAdapter(channels, selectedId) { index, channel ->
            onPicked(index, channel)
            dismiss()
        }
    }

    private class CameraAdapter(
        private val channels: List<SportChannel>,
        selectedId: String?,
        private val onPicked: (Int, SportChannel) -> Unit,
    ) : RecyclerView.Adapter<CameraAdapter.VH>() {

        private var selectedIndex: Int = channels
            .indexOfFirst { it.id == selectedId }
            .coerceAtLeast(0)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.live_sport_item_landscape_camera, parent, false)
            return VH(view)
        }

        override fun getItemCount(): Int = channels.size

        override fun onBindViewHolder(holder: VH, position: Int) {
            val channel = channels[position]
            holder.name.text = channel.name
            val selected = position == selectedIndex
            holder.overlay.visibility = if (selected) View.VISIBLE else View.GONE
            // Selected channel name is semibold (Figma node 10796:42067).
            holder.name.setTypeface(null, if (selected) Typeface.BOLD else Typeface.NORMAL)
            holder.itemView.setOnClickListener {
                val pos = holder.bindingAdapterPosition
                if (pos == RecyclerView.NO_POSITION || pos == selectedIndex) return@setOnClickListener
                val prev = selectedIndex
                selectedIndex = pos
                notifyItemChanged(prev)
                notifyItemChanged(pos)
                onPicked(pos, channels[pos])
            }
        }

        class VH(view: View) : RecyclerView.ViewHolder(view) {
            val overlay: View = view.findViewById(R.id.landscape_camera_selected_overlay)
            val name: TextView = view.findViewById(R.id.landscape_camera_name)
        }
    }

    private companion object {
        const val PANEL_WIDTH_DP = 247f
    }
}
