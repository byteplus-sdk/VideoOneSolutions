// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui.page

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.vertcdemo.effect.R
import com.vertcdemo.effect.bean.EffectItem

fun interface OnSelectedListener<T : EffectItem> {
    fun onSelected(item: T)
}

class EffectItemAdapter<T : EffectItem>(
    private val mItem: List<T>,
    private val mListener: OnSelectedListener<T>
) : RecyclerView.Adapter<EffectItemAdapter.ViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return ViewHolder(inflater.inflate(R.layout.item_effect_item, parent, false))
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = mItem[position]
        holder.icon.setImageResource(item.icon)
        holder.title.setText(item.title)
        holder.iconBorder.visibility =
            if (item.isClose) View.INVISIBLE else View.VISIBLE

        updateStatus(holder, item)

        holder.itemView.setOnClickListener {
            val info = mItem[holder.bindingAdapterPosition]
            if (info.isSelected) {
                return@setOnClickListener
            }

            info.isSelected = true
            notifyItemChanged(
                holder.bindingAdapterPosition,
                PAYLOAD_STATUS
            )
            mListener.onSelected(info)
            if (info.isClose) {
                // Close Item clicked, clear all selected status
                for (i in mItem.indices) {
                    val old = mItem[i]
                    if (old !== info) {
                        old.isSelected = false
                    }
                }
                notifyItemRangeChanged(0, mItem.size, PAYLOAD_STATUS)
            } else {
                // Normal Item clicked
                for (i in mItem.indices) {
                    // clear old selected item
                    val old = mItem[i]
                    if (old !== info && old.isSelected) {
                        old.isSelected = false
                        notifyItemChanged(i, PAYLOAD_STATUS)
                        break
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int, payloads: List<Any>) {
        if (payloads.contains(PAYLOAD_STATUS)) {
            val item = mItem[position]
            updateStatus(holder, item)
        } else {
            onBindViewHolder(holder, position)
        }
    }

    private fun updateStatus(holder: ViewHolder, item: T) {
        holder.itemView.isSelected = item.isSelected
    }

    override fun getItemCount(): Int = mItem.size

    class ViewHolder internal constructor(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val icon: ImageView = itemView.findViewById(R.id.icon)
        val title: TextView = itemView.findViewById(R.id.title)
        val iconBorder: View = itemView.findViewById(R.id.icon_border)
    }

    companion object {
        private const val PAYLOAD_STATUS = "status"
    }
}