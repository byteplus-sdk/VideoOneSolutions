// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.fullscreen

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.byteplus.live.sport.R
import com.byteplus.live.sport.player.Resolution

/**
 * Landscape quality side-panel.
 *
 * Items:
 *  - First row is "Auto" → maps to ABR on, no pinned tier.
 *  - Following rows are the channel's available FLV tiers (already ordered
 *    from highest to lowest by [tiers]). Picking a tier turns ABR off and pins
 *    that resolution.
 *
 * Selection state:
 *  - "Auto" is selected when [abrOn] is true.
 *  - A specific tier is selected when [abrOn] is false and [pinnedResolution]
 *    matches that tier (or the channel's first tier when no explicit pin yet).
 *
 * The entry button visibility (RTM stream → hide entry) is owned by the host
 * — this panel only renders / commits the user's pick.
 */
class LandscapeQualityPanel(
    activity: Activity,
    private val tiers: List<Resolution>,
    private val abrOn: Boolean,
    private val pinnedResolution: Resolution?,
    private val onPicked: (autoSelected: Boolean, resolution: Resolution?) -> Unit,
) : LandscapeSidePanel(
    activity = activity,
    widthPx = (activity.resources.displayMetrics.density * PANEL_WIDTH_DP).toInt(),
) {

    override fun onCreateContent(inflater: LayoutInflater): View =
        inflater.inflate(R.layout.live_sport_panel_landscape_quality, null, false)

    override fun onBind(content: View) {
        val list = content.findViewById<RecyclerView>(R.id.landscape_quality_list)
        list.layoutManager = LinearLayoutManager(content.context)
        list.adapter = QualityAdapter(
            tiers = tiers,
            abrOn = abrOn,
            pinnedResolution = pinnedResolution,
            onPicked = { autoSelected, resolution ->
                onPicked(autoSelected, resolution)
                dismiss()
            },
        )
    }

    private class QualityAdapter(
        private val tiers: List<Resolution>,
        abrOn: Boolean,
        pinnedResolution: Resolution?,
        private val onPicked: (autoSelected: Boolean, resolution: Resolution?) -> Unit,
    ) : RecyclerView.Adapter<QualityAdapter.VH>() {

        // Item index 0 = "Auto"; subsequent indices map onto [tiers].
        private var selectedIndex: Int = if (abrOn || pinnedResolution == null) {
            0
        } else {
            val idx = tiers.indexOf(pinnedResolution)
            if (idx >= 0) idx + 1 else 0
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.live_sport_item_landscape_quality, parent, false)
            return VH(view as TextView)
        }

        override fun getItemCount(): Int = tiers.size + 1

        override fun onBindViewHolder(holder: VH, position: Int) {
            val labelRes = if (position == 0) {
                R.string.live_sport_watch_resolution_auto
            } else {
                resolutionLabel(tiers[position - 1])
            }
            holder.label.setText(labelRes)
            val selected = position == selectedIndex
            holder.label.setBackgroundResource(
                if (selected) R.drawable.live_sport_landscape_quality_item_selected
                else 0
            )
            holder.label.setTextColor(if (selected) 0xFFFFFFFF.toInt() else 0xE6FFFFFF.toInt())
            holder.itemView.setOnClickListener {
                val pos = holder.bindingAdapterPosition
                if (pos == RecyclerView.NO_POSITION || pos == selectedIndex) return@setOnClickListener
                val prev = selectedIndex
                selectedIndex = pos
                notifyItemChanged(prev)
                notifyItemChanged(pos)
                if (pos == 0) onPicked(true, null) else onPicked(false, tiers[pos - 1])
            }
        }

        private fun resolutionLabel(resolution: Resolution): Int = when (resolution) {
            Resolution.ORIGIN -> R.string.live_sport_watch_resolution_origin
            Resolution.UHD -> R.string.live_sport_watch_resolution_uhd
            Resolution.HD -> R.string.live_sport_watch_resolution_hd
            Resolution.SD -> R.string.live_sport_watch_resolution_sd
            Resolution.LD -> R.string.live_sport_watch_resolution_ld
        }

        class VH(val label: TextView) : RecyclerView.ViewHolder(label)
    }

    private companion object {
        const val PANEL_WIDTH_DP = 240f
    }
}
