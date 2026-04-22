// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui.page

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.vertcdemo.effect.R
import com.vertcdemo.effect.bean.BeautyItem
import com.vertcdemo.effect.ui.EffectFragment
import com.vertcdemo.effect.ui.EffectViewModel
import com.vertcdemo.effect.ui.progress


class BeautyFragment : Fragment(R.layout.fragment_beauty) {

    private lateinit var mParent: EffectFragment

    private lateinit var mViewModel: EffectViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mParent = requireParentFragment() as EffectFragment
        mViewModel = mParent.uIViewModel
    }

    override fun onResume() {
        super.onResume()
        mParent.updateProgressBar(mViewModel.selectedBeauty.progress())
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val recyclerView = view.findViewById<RecyclerView>(R.id.recycler).apply {
            layoutManager = GridLayoutManager(requireContext(), 5)
        }
        recyclerView.adapter = BeautyAdapter(mViewModel.beautyItems) { item: BeautyItem ->
            mViewModel.selectedBeauty = item
            mParent.updateProgressBar(item.progress())
        }
    }

    internal class BeautyAdapter(
        private val mItem: List<BeautyItem>,
        private val mOnSelectedListener: OnSelectedListener<BeautyItem>
    ) : RecyclerView.Adapter<VH>() {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val inflater = LayoutInflater.from(parent.context)
            return VH(inflater.inflate(R.layout.item_effect_item_beauty, parent, false))
        }

        override fun onBindViewHolder(holder: VH, position: Int) {
            val item = mItem[position]
            holder.icon.setImageResource(item.icon)
            holder.title.setText(item.title)

            updateStatus(holder, item)

            holder.itemView.setOnClickListener {
                val info = mItem[holder.bindingAdapterPosition]
                info.isChecked = true
                info.isSelected = true

                notifyItemChanged(holder.bindingAdapterPosition, PAYLOAD_STATUS)

                mOnSelectedListener.onSelected(info)

                if (info.isClose) {
                    // Close Item clicked, clear all selected status
                    for (i in mItem.indices) {
                        val old = mItem[i]
                        if (old !== info) {
                            old.isSelected = false
                            old.isChecked = false
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

        private fun updateStatus(holder: VH, item: BeautyItem) {
            holder.itemView.isSelected = item.isSelected
            holder.indicator.visibility =
                if (!item.isClose && item.isChecked) View.VISIBLE else View.INVISIBLE
        }

        override fun onBindViewHolder(holder: VH, position: Int, payloads: List<Any>) {
            if (payloads.contains(PAYLOAD_STATUS)) {
                val item = mItem[position]
                updateStatus(holder, item)
            } else {
                onBindViewHolder(holder, position)
            }
        }

        override fun getItemCount(): Int = mItem.size
    }

    internal class VH(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val icon: ImageView =
            itemView.findViewById(R.id.icon)
        val title: TextView = itemView.findViewById(R.id.title)
        val indicator: View = itemView.findViewById(R.id.indicator)
    }

    companion object {
        private const val PAYLOAD_STATUS = "status"
    }
}
