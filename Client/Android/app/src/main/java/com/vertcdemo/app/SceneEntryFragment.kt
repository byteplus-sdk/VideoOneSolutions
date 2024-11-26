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
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.vertcdemo.app.databinding.ItemSceneEntryBinding
import com.videoone.app.protocol.SceneEntry

class SceneEntryFragment : Fragment(R.layout.fragment_scene_entry) {

    private lateinit var mMainViewModel: MainViewModel
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mMainViewModel = ViewModelProvider(requireParentFragment())[MainViewModel::class.java]
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val guidelineTop = view.findViewById<Guideline>(R.id.guideline_top)
        mMainViewModel.guidelineTop.observe(viewLifecycleOwner) { top ->
            guidelineTop.setGuidelineBegin(top)
        }

        val context = requireContext()

        view.findViewById<RecyclerView>(R.id.recycler)
            .apply {
                layoutManager = LinearLayoutManager(context)
                addItemDecoration(SpaceItemDecoration(resources.getDimensionPixelSize(R.dimen.item_function_spacing)))
                adapter = SceneItemAdapter(context, SceneEntry.entries)
            }
    }

    class SceneItemHolder(private val binding: ItemSceneEntryBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(entry: SceneEntry) {
            val context = itemView.context
            binding.title.setText(entry.title)
            binding.description.setText(entry.description)
            binding.background.setImageResource(entry.background)
            if (entry.showGear) {
                binding.gear.visibility = View.VISIBLE
                binding.gear.setOnClickListener { entry.startSettings(context) }
            } else {
                binding.gear.visibility = View.GONE
            }
            binding.root.setOnClickListener { entry.startup(context) }
        }
    }

    class SceneItemAdapter(context: Context, private val entries: List<SceneEntry>) :
        RecyclerView.Adapter<SceneItemHolder>() {
        private val layoutInflater = LayoutInflater.from(context)
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
            SceneItemHolder(ItemSceneEntryBinding.inflate(layoutInflater, parent, false))


        override fun getItemCount(): Int = entries.size

        override fun onBindViewHolder(holder: SceneItemHolder, position: Int) =
            holder.bind(entries[position])
    }

    class SpaceItemDecoration(private val padding: Int) : RecyclerView.ItemDecoration() {
        override fun getItemOffsets(
            outRect: Rect,
            view: View,
            parent: RecyclerView,
            state: RecyclerView.State
        ) {
            val position = parent.getChildLayoutPosition(view)
            outRect.top = if (position == 0) 0 else padding
        }
    }
}