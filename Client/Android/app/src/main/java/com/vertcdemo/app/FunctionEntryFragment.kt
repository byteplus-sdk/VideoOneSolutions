// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.content.Context
import android.graphics.Rect
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.Guideline
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ItemDecoration
import com.vertcdemo.app.databinding.ItemFunctionEntryBinding
import com.videoone.app.protocol.FunctionEntry

class FunctionEntryFragment : Fragment(R.layout.fragment_function_entry) {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val guidelineTop = view.findViewById<Guideline>(R.id.guideline_top)
        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets: WindowInsetsCompat ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            guidelineTop.setGuidelineBegin(insets.top)
            windowInsets
        }

        val context = requireContext()
        val recyclerView: RecyclerView = view.findViewById(R.id.recycler)
        recyclerView.layoutManager = LinearLayoutManager(context)
        recyclerView.addItemDecoration(
            MyItemDecoration(
                resources.getDimensionPixelSize(R.dimen.item_function_top),
                resources.getDimensionPixelSize(R.dimen.item_function_spacing)
            )
        )
        recyclerView.adapter = SceneItemAdapter(context, FunctionEntry.entries)
    }

    class SceneItemHolder(private val binding: ItemFunctionEntryBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(entry: FunctionEntry) {
            val context = itemView.context
            binding.title.setText(entry.title)
            binding.description.setText(entry.description)
            binding.icon.setImageResource(entry.icon)
            val card = binding.getRoot()
            card.setOnClickListener { entry.startup(context) }
        }
    }

    class SceneItemAdapter(context: Context, private val entries: List<FunctionEntry>) :
        RecyclerView.Adapter<SceneItemHolder>() {
        private val layoutInflater = LayoutInflater.from(context)
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
            SceneItemHolder(ItemFunctionEntryBinding.inflate(layoutInflater, parent, false))


        override fun getItemCount(): Int = entries.size

        override fun onBindViewHolder(holder: SceneItemHolder, position: Int) =
            holder.bind(entries[position])
    }

    class MyItemDecoration(private val top: Int, private val spacing: Int) : ItemDecoration() {
        override fun getItemOffsets(
            outRect: Rect,
            view: View,
            parent: RecyclerView,
            state: RecyclerView.State
        ) {
            val position = parent.getChildAdapterPosition(view)
            if (position == RecyclerView.NO_POSITION) return;
            outRect.top = if (position == 0) {
                top
            } else {
                0
            }
            outRect.bottom = spacing
        }
    }
}