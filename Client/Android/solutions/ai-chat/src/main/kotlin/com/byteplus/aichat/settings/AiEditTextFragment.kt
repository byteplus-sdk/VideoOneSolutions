package com.byteplus.aichat.settings

import android.os.Bundle
import android.text.InputFilter
import android.text.TextUtils
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.Fragment
import androidx.navigation.findNavController
import androidx.navigation.navGraphViewModels
import com.byteplus.aichat.R
import com.byteplus.aichat.databinding.FragmentAiSettingEditTextBinding
import com.vertcdemo.ui.CenteredToast

const val MAX_INPUT_LENGTH = 512

const val EXTRA_EDIT_TYPE = "edit_type"

enum class EditType {
    WELCOME_SPEECH,
    PROMPT
}

class AiEditTextFragment : Fragment(R.layout.fragment_ai_setting_edit_text) {

    private val viewModel by navGraphViewModels<SettingsViewModel>(R.id.ai_chat_graph)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val arguments = requireArguments()
        val editType: EditType = arguments.getSerializable(EXTRA_EDIT_TYPE) as EditType

        val binding = FragmentAiSettingEditTextBinding.bind(view)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsects ->
            val insets = windowInsects.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            WindowInsetsCompat.CONSUMED
        }

        binding.back.setOnClickListener {
            it.findNavController().popBackStack()
        }

        binding.save.setOnClickListener {
            if (editType == EditType.PROMPT && TextUtils.isEmpty(binding.input.text)) {
                CenteredToast.show(R.string.toast_ai_input_is_empty)
                return@setOnClickListener
            }

            when (editType) {
                EditType.WELCOME_SPEECH -> {
                    viewModel.setWelcomeSpeech("${binding.input.text}")
                }

                EditType.PROMPT -> {
                    viewModel.setPrompt("${binding.input.text}")
                }
            }

            it.findNavController().popBackStack()
        }

        binding.input.filters += InputFilter.LengthFilter(MAX_INPUT_LENGTH)
        binding.input.addTextChangedListener(afterTextChanged = {
            binding.countTips.text = getString(
                R.string.ai_count_limit_tips,
                it?.length ?: 0,
                MAX_INPUT_LENGTH
            )
        })

        when (editType) {
            EditType.WELCOME_SPEECH -> {
                binding.title.setText(R.string.ai_setting_label_character_setting_welcome_speech)

                binding.input.setText(viewModel.welcomeSpeech.value?.value ?: "")
            }

            EditType.PROMPT -> {
                binding.title.setText(R.string.ai_setting_label_character_setting_prompt)

                binding.input.setText(viewModel.prompt.value?.value ?: "")
            }
        }
    }
}