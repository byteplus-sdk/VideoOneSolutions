// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.panel

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.byteplus.live.sport.R
import com.google.android.material.bottomsheet.BottomSheetDialog

/**
 * Fake gift panel (portrait BottomSheet). The grid + selection + Send wiring
 * lives in [GiftBinder] so the landscape side-panel can reuse it.
 *
 * "Fake" = picking a gift only toggles selection; Send reports the chosen gift
 * via [onSend] and the host shows a toast. No real gifting backend.
 */
class GiftPanel(
    private val context: Context,
    private val onSend: (GiftBinder.Gift) -> Unit,
) {
    fun show() {
        val view = LayoutInflater.from(context).inflate(R.layout.live_sport_panel_gift, null)
        view.setBackgroundResource(R.drawable.live_sport_gift_panel_bg)
        val dialog = BottomSheetDialog(context)
        dialog.setContentView(view)
        GiftBinder.bind(
            content = view,
            spanCount = 4,
            onSend = {
                onSend(it)
                dialog.dismiss()
            },
        )
        dialog.show()
    }
}

/**
 * Shared binding logic for the gift grid. Renders a fixed fake catalogue,
 * tracks the selected cell, and enables the Send button once something is
 * picked.
 */
object GiftBinder {

    /** A fake gift entry. */
    data class Gift(val iconRes: Int, val nameRes: Int, val price: Int)

    private val CATALOGUE = listOf(
        Gift(R.drawable.live_sport_ic_gift_rose, R.string.live_sport_watch_gift_rose, 1),
        Gift(R.drawable.live_sport_ic_gift_heart, R.string.live_sport_watch_gift_heart, 5),
        Gift(R.drawable.live_sport_ic_gift_star, R.string.live_sport_watch_gift_star, 10),
        Gift(R.drawable.live_sport_ic_gift_thumbsup, R.string.live_sport_watch_gift_thumbsup, 20),
        Gift(R.drawable.live_sport_ic_gift_rocket, R.string.live_sport_watch_gift_rocket, 66),
        Gift(R.drawable.live_sport_ic_gift_crown, R.string.live_sport_watch_gift_crown, 188),
    )

    fun bind(content: View, spanCount: Int, onSend: (Gift) -> Unit) {
        val grid = content.findViewById<RecyclerView>(R.id.gift_grid)
        val sendBtn = content.findViewById<TextView>(R.id.btn_gift_send)

        val adapter = GiftAdapter(CATALOGUE) { selected ->
            sendBtn.isEnabled = selected != null
            sendBtn.alpha = if (selected != null) 1f else 0.4f
        }
        grid.layoutManager = GridLayoutManager(content.context, spanCount)
        grid.adapter = adapter

        sendBtn.alpha = 0.4f
        sendBtn.setOnClickListener {
            adapter.selectedGift()?.let { onSend(it) }
        }
    }

    private class GiftAdapter(
        private val gifts: List<Gift>,
        private val onSelectionChanged: (Gift?) -> Unit,
    ) : RecyclerView.Adapter<GiftAdapter.VH>() {

        private var selectedIndex = RecyclerView.NO_POSITION

        fun selectedGift(): Gift? = gifts.getOrNull(selectedIndex)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.live_sport_item_gift, parent, false)
            return VH(view)
        }

        override fun getItemCount(): Int = gifts.size

        override fun onBindViewHolder(holder: VH, position: Int) {
            val gift = gifts[position]
            val context = holder.itemView.context
            holder.icon.setImageResource(gift.iconRes)
            holder.name.setText(gift.nameRes)
            holder.price.text = context.getString(R.string.live_sport_watch_gift_sent_price, gift.price)
            holder.itemView.isSelected = position == selectedIndex
            holder.itemView.setOnClickListener {
                val pos = holder.bindingAdapterPosition
                if (pos == RecyclerView.NO_POSITION) return@setOnClickListener
                val prev = selectedIndex
                selectedIndex = pos
                if (prev != RecyclerView.NO_POSITION) notifyItemChanged(prev)
                notifyItemChanged(pos)
                onSelectionChanged(gifts[pos])
            }
        }

        class VH(view: View) : RecyclerView.ViewHolder(view) {
            val icon: ImageView = view.findViewById(R.id.gift_icon)
            val name: TextView = view.findViewById(R.id.gift_name)
            val price: TextView = view.findViewById(R.id.gift_price)
        }
    }
}
