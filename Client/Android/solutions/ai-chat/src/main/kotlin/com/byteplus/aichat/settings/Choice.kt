package com.byteplus.aichat.settings

import android.content.Context
import android.graphics.Rect
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions
import com.bumptech.glide.request.RequestOptions
import com.byteplus.aichat.R
import com.byteplus.aichat.databinding.ItemAiSettingChoiceBinding
import com.vertcdemo.core.utils.ViewUtils

class ChoiceAdapter(context: Context, private var items: List<IChoice>, private val chosenClickListener: IChosenClickListener?) :
    RecyclerView.Adapter<ChoiceViewHolder>() {
    private val layoutInflater = LayoutInflater.from(context)

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): ChoiceViewHolder {
        val binding = ItemAiSettingChoiceBinding.inflate(layoutInflater, parent, false)
        return ChoiceViewHolder(binding)
    }

    override fun onBindViewHolder(
        holder: ChoiceViewHolder, position: Int
    ) {
        val binding = holder.binding
        val item = items[position]
        binding.text.text = item.text

        val radius = ViewUtils.dp2px(6f)
        val requestOptions = RequestOptions().transform(RoundedCorners(radius))

        Glide.with(binding.icon).load(item.icon).apply(requestOptions).transition(
            DrawableTransitionOptions.withCrossFade()).into(binding.icon)

        updateStatus(binding, item.chosen)
        updatePlayingStatus(binding, item.playing)

        binding.chosen.setOnClickListener {
            val clicked = items[holder.bindingAdapterPosition]
            if (clicked.chosen) return@setOnClickListener
            clicked.chosen = true

            notifyItemChanged(position, PAYLOAD_CHOOSE)

            for (i in items.indices) {
                val old = items[i]
                if (old !== clicked && old.chosen) {
                    old.chosen = false
                    notifyItemChanged(i, PAYLOAD_CHOOSE)
                }
            }
            chosenClickListener?.onChosen(clicked)
        }

        if (chosenClickListener != null) {
            binding.root.setOnClickListener {
                val clicked = items[holder.bindingAdapterPosition]
                if (clicked.playing) return@setOnClickListener
                clicked.playing = true

                notifyItemChanged(position, PAYLOAD_PLAYING)

                for (i in items.indices) {
                    val old = items[i]
                    if (old !== clicked && old.playing) {
                        old.playing = false
                        notifyItemChanged(i, PAYLOAD_PLAYING)
                    }
                }
                chosenClickListener.onPlaying(position, clicked)
            }
        }
    }

    private fun updateStatus(binding: ItemAiSettingChoiceBinding, chosen: Boolean) {
        binding.chosen.isSelected = chosen
        if (chosen) {
            binding.chosenIcon.visibility = View.VISIBLE
            binding.chosenText.setText(R.string.ai_setting_chosen)
        } else {
            binding.chosenIcon.visibility = View.GONE
            binding.chosenText.setText(R.string.ai_setting_choose)
        }
    }

    private fun updatePlayingStatus(binding: ItemAiSettingChoiceBinding, playing: Boolean) {
        if (playing) {
            binding.iconPause.visibility = View.VISIBLE
        } else {
            binding.iconPause.visibility = View.GONE
        }
    }

    override fun onBindViewHolder(holder: ChoiceViewHolder, position: Int, payloads: List<Any?>) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position)
        } else if (payloads.contains(PAYLOAD_CHOOSE)) {
            val item = items[position]
            updateStatus(holder.binding, item.chosen)
        } else if (payloads.contains(PAYLOAD_PLAYING)) {
            val item = items[position]
            updatePlayingStatus(holder.binding, item.playing)
        }
    }

    override fun getItemCount() = items.size

    fun setItems(items: List<IChoice>) {
        this.items = items
        notifyDataSetChanged()
    }
}

const val PAYLOAD_CHOOSE = "choose"
const val PAYLOAD_PLAYING = "playing"

class ChoiceViewHolder(val binding: ItemAiSettingChoiceBinding) :
    RecyclerView.ViewHolder(binding.root)

class ChoiceItemDecoration(context: Context) : RecyclerView.ItemDecoration() {
    private val space = context.resources.getDimensionPixelSize(R.dimen.item_choice_spacing)
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

interface IChoice {
    val text: String
    val icon: String
    var chosen: Boolean
    val audition : String
    var playing : Boolean
}

interface IChosenClickListener {
    fun onChosen(choice: IChoice)
    fun onPlaying(position: Int, choice: IChoice)
}