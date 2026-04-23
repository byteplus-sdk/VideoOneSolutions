package com.byteplus.aichat.settings

import android.os.Bundle
import android.view.View
import androidx.core.os.bundleOf
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.navigation.findNavController
import androidx.navigation.navGraphViewModels
import com.byteplus.aichat.R
import com.byteplus.aichat.databinding.FragmentAiSettingsBinding
import com.byteplus.aichat.utils.lightStatusBar

class AiSettingsFragment : Fragment(R.layout.fragment_ai_settings) {

    private val viewModel by navGraphViewModels<SettingsViewModel>(R.id.ai_chat_graph)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        lightStatusBar()

        val binding = FragmentAiSettingsBinding.bind(view)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsects ->
            val insets = windowInsects.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            WindowInsetsCompat.CONSUMED
        }

        binding.back.setOnClickListener {
            it.findNavController().popBackStack()
        }

        binding.modeRealtime.setOnClickListener {
            viewModel.setIntegrationMode(IntegrationMode.REALTIME)
        }

        binding.modeFlexible.setOnClickListener {
            viewModel.setIntegrationMode(IntegrationMode.FLEXIBLE)
        }

        binding.welcomeSpeech.label.setText(R.string.ai_setting_label_character_setting_welcome_speech)
        binding.welcomeSpeech.root.setOnClickListener {
            it.findNavController().navigate(
                R.id.action_edit_text, bundleOf(
                    EXTRA_EDIT_TYPE to EditType.WELCOME_SPEECH,
                )
            )
        }
        viewModel.welcomeSpeech.observe(viewLifecycleOwner) {
            binding.welcomeSpeech.value.text = it.value
        }
        binding.prompt.label.setText(R.string.ai_setting_label_character_setting_prompt)
        binding.prompt.root.setOnClickListener {
            it.findNavController().navigate(
                R.id.action_edit_text, bundleOf(
                    EXTRA_EDIT_TYPE to EditType.PROMPT,
                )
            )
        }
        viewModel.prompt.observe(viewLifecycleOwner) {
            binding.prompt.value.text = it.value
        }

        // region open ai
        fun openAi(mode: IntegrationMode) {
            if (mode == IntegrationMode.REALTIME) {
                binding.modeRealtime.isSelected = true
                binding.voiceTypeRealtime.root.visibility = View.VISIBLE
            } else {
                binding.modeRealtime.isSelected = false
                binding.voiceTypeRealtime.root.visibility = View.GONE
            }
        }

        binding.voiceTypeRealtime.label.setText(R.string.ai_setting_label_core_voice_type)
        binding.voiceTypeRealtime.root.setOnClickListener {
            it.findNavController().navigate(
                R.id.action_voice_type, bundleOf(
                    EXTRA_INTEGRATION_MODE to IntegrationMode.REALTIME
                )
            )
        }
        viewModel.voiceTypeRealtime.observe(viewLifecycleOwner) {
            binding.voiceTypeRealtime.value.text = it.value.name
        }
        // endregion

        // region flexible combination
        fun flexibleCombination(mode: IntegrationMode) {
            if (mode == IntegrationMode.FLEXIBLE) {
                binding.modeFlexible.isSelected = true
                binding.voiceTypeFlexible.root.visibility = View.VISIBLE
                binding.llmModel.root.visibility = View.VISIBLE
                binding.asrModel.root.visibility = View.VISIBLE
            } else {
                binding.modeFlexible.isSelected = false
                binding.voiceTypeFlexible.root.visibility = View.GONE
                binding.llmModel.root.visibility = View.GONE
                binding.asrModel.root.visibility = View.GONE
            }
        }

        binding.voiceTypeFlexible.label.setText(R.string.ai_setting_label_core_voice_type)
        binding.voiceTypeFlexible.root.setOnClickListener {
            it.findNavController().navigate(
                R.id.action_voice_type, bundleOf(
                    EXTRA_INTEGRATION_MODE to IntegrationMode.FLEXIBLE
                )
            )
        }
        viewModel.voiceTypeFlexible.observe(viewLifecycleOwner) {
            binding.voiceTypeFlexible.value.text = it.value.name
        }

        binding.llmModel.label.setText(R.string.ai_setting_label_core_llm)
        binding.llmModel.root.setOnClickListener {
            it.findNavController().navigate(R.id.action_llm)
        }
        viewModel.llmModel.observe(viewLifecycleOwner) {
            binding.llmModel.value.text = it.value
        }

        binding.asrModel.label.setText(R.string.ai_setting_label_core_asr)
        binding.asrModel.root.setOnClickListener {
            it.findNavController().navigate(R.id.action_asr)
        }
        viewModel.asrModel.observe(viewLifecycleOwner) {
            binding.asrModel.value.text = it.value
        }
        // endregion

        viewModel.integrationMode.observe(viewLifecycleOwner) { mode ->
            openAi(mode)
            flexibleCombination(mode)
        }
    }
}