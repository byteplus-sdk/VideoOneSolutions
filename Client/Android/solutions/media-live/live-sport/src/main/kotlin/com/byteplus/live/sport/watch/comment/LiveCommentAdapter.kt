// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.watch.comment

import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.byteplus.live.sport.R
import com.byteplus.live.sport.widget.CommentTextBuilder

/**
 * RecyclerView adapter for the live-comment list. Each row is a single
 * TextView that renders a [SpannableStringBuilder] produced by
 * [CommentTextBuilder].
 *
 * Backed by a plain [MutableList] — no DiffUtil, since live chat is
 * append-only and never updates rows in-place.
 */
class LiveCommentAdapter : RecyclerView.Adapter<LiveCommentAdapter.VH>() {

    private val items = mutableListOf<LiveCommentItem>()

    fun submit(list: List<LiveCommentItem>) {
        items.clear()
        items.addAll(list)
        notifyDataSetChanged()
    }

    fun append(item: LiveCommentItem) {
        items.add(item)
        notifyItemInserted(items.size - 1)
    }

    fun lastIndex(): Int = items.size - 1

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.live_sport_item_comment, parent, false) as TextView
        return VH(view)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = items[position]
        val context = holder.itemView.context
        // Per Figma 10877:122560 the user name uses #20D5EC (cyan) for every
        // role; body text is white. The earlier "highlight" branch is gone.
        holder.textView.text = CommentTextBuilder.build(
            context = context,
            vipLevel = item.vipLevel,
            userName = item.userName,
            userNameColor = NAME_COLOR,
            content = item.content,
            contentColor = CONTENT_COLOR,
        )
    }

    override fun getItemCount(): Int = items.size

    class VH(val textView: TextView) : RecyclerView.ViewHolder(textView)

    companion object {
        // Figma fill_2S3F24 (node 10877:122513)
        private val NAME_COLOR = 0xFF8CE7FF.toInt()
        private val CONTENT_COLOR = 0xFFFFFFFF.toInt()
    }
}
