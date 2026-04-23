package com.byteplus.aichat.settings

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View.OnClickListener
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.byteplus.aichat.R
import com.vertcdemo.core.utils.ViewUtils

class AiStopConfirmDialog(context: Context, goClickListener: OnClickListener) : Dialog(context) {
    init {
        window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        val mainLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(ViewUtils.dp2px(20f), ViewUtils.dp2px(20f), ViewUtils.dp2px(20f), ViewUtils.dp2px(20f))
            layoutParams = ViewGroup.LayoutParams(
                ViewUtils.dp2px(280f),
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            background = ContextCompat.getDrawable(context, R.drawable.bg_ai_dialog_stop_confirm)
        }

        val infoTextView = TextView(context).apply {
            setText(R.string.ai_dialog_confirm_tips)
            setTextColor(ContextCompat.getColor(context, R.color.ai_stop_confirm_text))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            gravity = Gravity.START
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        mainLayout.addView(infoTextView)

        val buttonLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            layoutParams.topMargin = ViewUtils.dp2px(20f)
            this.layoutParams = layoutParams
        }

        val goButton = Button(context).apply {
            setText(R.string.ai_dialog_confirm_go)
            setTextColor(ContextCompat.getColor(context, R.color.ai_stop_confirm_go))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            layoutParams = LinearLayout.LayoutParams(
                ViewUtils.dp2px(240f),
                ViewUtils.dp2px(44f)
            )
            background = ContextCompat.getDrawable(context, R.drawable.bg_ai_dialog_button_confirm_go)
            elevation = 0f
            setOnClickListener {
                goClickListener.onClick(it)
                dismiss()
            }
        }

        buttonLayout.addView(goButton)

        val cancelButton = Button(context).apply {
            setText(R.string.ai_dialog_confirm_cancel)
            setTextColor(ContextCompat.getColor(context, R.color.ai_stop_confirm_cancel))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            val layoutParams = LinearLayout.LayoutParams(
                ViewUtils.dp2px(240f),
                ViewUtils.dp2px(44f)
            )
            layoutParams.topMargin = ViewUtils.dp2px(20f)
            this.layoutParams = layoutParams
            background = ContextCompat.getDrawable(context, R.drawable.bg_ai_dialog_button_cancel)
            elevation = 0f
            setOnClickListener {
                dismiss()
            }
        }
        buttonLayout.addView(cancelButton)

        mainLayout.addView(buttonLayout)

        setContentView(mainLayout)
    }
}