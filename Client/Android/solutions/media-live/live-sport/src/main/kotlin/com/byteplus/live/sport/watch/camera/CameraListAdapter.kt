// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.camera

import android.graphics.Typeface
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.byteplus.live.sport.R
import com.byteplus.live.sport.data.SportChannel

/**
 * Horizontal multi-camera switcher.
 *
 * Fill behaviour (per product requirement): with the default 4 channels the
 * items should exactly fill the list width with no scrolling. We achieve this by
 * computing a per-item width from the measured list width and the inter-item gap
 * — see [setFillWidth], called once the RecyclerView has been laid out. When
 * there are more channels than [FILL_COUNT], items keep their fill-derived width
 * and the list simply scrolls.
 *
 * Tapping an item switches the stream immediately ("tap to switch"); selection
 * state is driven by [selectedIndex].
 */
class CameraListAdapter(
    private val onCameraSelected: (position: Int, channel: SportChannel) -> Unit,
) : RecyclerView.Adapter<CameraListAdapter.CameraViewHolder>() {

    private val channels = mutableListOf<SportChannel>()
    private var selectedIndex = 0

    /** Per-item width in px; <=0 means "not measured yet, use layout default". */
    private var itemWidthPx: Int = 0

    fun submit(list: List<SportChannel>, selected: Int = 0) {
        channels.clear()
        channels.addAll(list)
        selectedIndex = selected.coerceIn(0, (list.size - 1).coerceAtLeast(0))
        notifyDataSetChanged()
    }

    /**
     * Assign the item width so [FILL_COUNT] items fill [listWidthPx] exactly.
     *
     * @param listWidthPx the RecyclerView's content width (excluding padding).
     * @param gapPx horizontal gap between items.
     */
    fun setFillWidth(listWidthPx: Int, gapPx: Int) {
        if (listWidthPx <= 0) return
        val totalGap = gapPx * (FILL_COUNT - 1)
        val width = (listWidthPx - totalGap) / FILL_COUNT
        if (width > 0 && width != itemWidthPx) {
            itemWidthPx = width
            notifyDataSetChanged()
        }
    }

    fun selectedChannel(): SportChannel? = channels.getOrNull(selectedIndex)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CameraViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.live_sport_item_camera, parent, false)
        return CameraViewHolder(view)
    }

    override fun onBindViewHolder(holder: CameraViewHolder, position: Int) {
        holder.bind(channels[position], position == selectedIndex, itemWidthPx)
        holder.itemView.setOnClickListener {
            val pos = holder.bindingAdapterPosition
            if (pos == RecyclerView.NO_POSITION || pos == selectedIndex) return@setOnClickListener
            val prev = selectedIndex
            selectedIndex = pos
            notifyItemChanged(prev)
            notifyItemChanged(pos)
            onCameraSelected(pos, channels[pos])
        }
    }

    override fun getItemCount(): Int = channels.size

    class CameraViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val selectedOverlay: View = itemView.findViewById(R.id.camera_selected_overlay)
        private val livingIcon: View = itemView.findViewById(R.id.camera_living_icon)
        private val name: TextView = itemView.findViewById(R.id.camera_name)

        fun bind(channel: SportChannel, selected: Boolean, widthPx: Int) {
            name.text = channel.name
            // Selected: scrim + border overlay, center living icon, bold + opaque
            // name. Unselected: plain cover, regular + 80%-opacity name (Figma).
            selectedOverlay.visibility = if (selected) View.VISIBLE else View.GONE
            livingIcon.visibility = if (selected) View.VISIBLE else View.GONE
            name.setTypeface(null, if (selected) Typeface.BOLD else Typeface.NORMAL)
            name.alpha = if (selected) 1f else 0.8f
            // Cover art is the shared placeholder for now; real per-channel
            // thumbnails land when design assets are provided.
            if (widthPx > 0) {
                itemView.layoutParams = itemView.layoutParams.apply { width = widthPx }
            }
        }
    }

    companion object {
        /** Number of items that should fill the list width with no scrolling. */
        const val FILL_COUNT = 4
    }
}
