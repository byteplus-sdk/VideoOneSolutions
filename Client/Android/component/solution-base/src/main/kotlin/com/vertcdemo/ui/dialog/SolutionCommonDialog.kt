// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.ui.dialog

import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.res.ResourcesCompat
import androidx.fragment.app.DialogFragment
import com.vertcdemo.base.R
import com.vertcdemo.base.databinding.DialogSolutionCommonBinding

class SolutionCommonDialog : DialogFragment() {
    override fun getTheme(): Int = R.style.SolutionCommonDialogTheme

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? = inflater.inflate(R.layout.dialog_solution_common, container, false)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val binding = DialogSolutionCommonBinding.bind(view)
        val args = requireArguments()
        isCancelable = args.getBoolean(EXTRA_CANCELABLE, true)
        val requestKey = args.getString(EXTRA_REQUEST_KEY)
        val title = args.getInt(EXTRA_TITLE)
        if (title == ResourcesCompat.ID_NULL) {
            binding.title.visibility = View.GONE
        } else {
            binding.title.setText(title)
        }
        val message = args.getInt(EXTRA_MESSAGE, ResourcesCompat.ID_NULL)
        if (message == ResourcesCompat.ID_NULL) {
            val messageStr = args.getString(EXTRA_MESSAGE_S, null)
            if (messageStr == null) {
                binding.message.visibility = View.GONE
            } else {
                binding.message.text = messageStr
            }
        } else {
            binding.message.setText(message)
        }
        val positive = args.getInt(EXTRA_BUTTON_POSITIVE)
        if (positive == ResourcesCompat.ID_NULL) {
            binding.separatorV.visibility = View.GONE
            binding.button1.visibility = View.GONE
        } else {
            binding.button1.setText(positive)
            binding.button1.setOnClickListener { // Positive
                dismiss()
                requestKey?.let { key ->
                    val result = Bundle().apply {
                        putInt(EXTRA_RESULT, Dialog.BUTTON_POSITIVE)
                        putBundle(EXTRA_SOURCE_ARGS, args)
                    }
                    parentFragmentManager.setFragmentResult(key, result)
                }
            }
        }
        val negative = args.getInt(EXTRA_BUTTON_NEGATIVE)
        if (negative == ResourcesCompat.ID_NULL) {
            binding.separatorV.visibility = View.GONE
            binding.button2.visibility = View.GONE
        } else {
            binding.button2.setText(negative)
            binding.button2.setOnClickListener { // Negative
                dismiss()
                requestKey?.let { key ->
                    val result = Bundle().apply {
                        putInt(EXTRA_RESULT, Dialog.BUTTON_NEGATIVE)
                        putBundle(EXTRA_SOURCE_ARGS, args)
                    }
                    parentFragmentManager.setFragmentResult(key, result)
                }
            }
        }
        if (positive == ResourcesCompat.ID_NULL && negative == ResourcesCompat.ID_NULL) {
            binding.separatorH.visibility = View.GONE
        }
    }

    override fun onCancel(dialog: DialogInterface) {
        val requestKey = arguments?.getString(EXTRA_REQUEST_KEY) ?: return
        val result = Bundle().apply {
            putInt(EXTRA_RESULT, Dialog.BUTTON_NEGATIVE)
            putBundle(EXTRA_SOURCE_ARGS, arguments)
        }
        parentFragmentManager.setFragmentResult(requestKey, result)
    }

    companion object {
        const val EXTRA_REQUEST_KEY = "extra_request_key"
        const val EXTRA_RESULT = "extra_button"
        const val EXTRA_SOURCE_ARGS = "extra_source_args"
        const val EXTRA_CANCELABLE = "extra_cancelable"
        const val EXTRA_TITLE = "extra_title"
        const val EXTRA_MESSAGE = "extra_message"
        const val EXTRA_MESSAGE_S = "extra_message_s"
        const val EXTRA_BUTTON_POSITIVE = "extra_button_positive"
        const val EXTRA_BUTTON_NEGATIVE = "extra_button_negative"

        @JvmStatic
        fun dialogArgs(requestKey: String, message: Int, positive: Int, negative: Int) =
            Bundle().apply {
                putString(EXTRA_REQUEST_KEY, requestKey)
                putInt(EXTRA_MESSAGE, message)
                putInt(EXTRA_BUTTON_POSITIVE, positive)
                putInt(EXTRA_BUTTON_NEGATIVE, negative)
            }

        @JvmStatic
        fun dialogArgs(requestKey: String, message: String, positive: Int) =
            Bundle().apply {
                putString(EXTRA_REQUEST_KEY, requestKey)
                putString(EXTRA_MESSAGE_S, message)
                putInt(EXTRA_BUTTON_POSITIVE, positive)
            }
    }
}
