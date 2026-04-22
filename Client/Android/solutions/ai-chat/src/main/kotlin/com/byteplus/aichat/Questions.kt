package com.byteplus.aichat

import android.content.Context
import android.graphics.Rect
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class QuestionAdapter(context: Context, private var questions: List<String>) :
    RecyclerView.Adapter<QuestionViewHolder>() {
    private val inflater = LayoutInflater.from(context)

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ) = QuestionViewHolder(inflater.inflate(R.layout.item_question, parent, false))

    override fun onBindViewHolder(
        holder: QuestionViewHolder,
        position: Int
    ) {
        holder.text.text = questions[position]
    }

    override fun getItemCount() = questions.size
}

class QuestionViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
    val text = itemView as TextView
}

class QuestionItemDecoration(context: Context) : RecyclerView.ItemDecoration() {
    private val space = context.resources.getDimensionPixelSize(R.dimen.item_question_spacing)
    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State
    ) {
        val position = parent.getChildLayoutPosition(view)
        if (position == 0) return
        outRect.top = space
    }
}