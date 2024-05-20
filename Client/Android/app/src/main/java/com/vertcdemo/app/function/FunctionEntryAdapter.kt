// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app.function

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.vertcdemo.app.databinding.ItemFunctionEntryBinding
import com.videoone.app.protocol.IFunctionEntry

class FunctionEntryAdapter(context: Context, private val entries: List<IFunctionEntry>) :
    RecyclerView.Adapter<FunctionEntryHolder>() {
    private val layoutInflater = LayoutInflater.from(context)
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        FunctionEntryHolder(ItemFunctionEntryBinding.inflate(layoutInflater, parent, false))


    override fun getItemCount(): Int = entries.size

    override fun onBindViewHolder(holder: FunctionEntryHolder, position: Int) =
        holder.bind(entries[position])
}

class FunctionEntryHolder(private val binding: ItemFunctionEntryBinding) :
    RecyclerView.ViewHolder(binding.root) {
    fun bind(entry: IFunctionEntry) {
        val context = itemView.context
        binding.title.setText(entry.title)
        binding.description.setText(entry.description)
        binding.icon.setImageResource(entry.icon)
        val card = binding.getRoot()
        card.setOnClickListener { entry.startup(context) }
    }
}

