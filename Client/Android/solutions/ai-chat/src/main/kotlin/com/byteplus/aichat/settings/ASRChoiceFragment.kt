package com.byteplus.aichat.settings

import android.os.Bundle
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.fragment.app.Fragment
import androidx.navigation.findNavController
import androidx.navigation.navGraphViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.byteplus.aichat.R
import com.byteplus.aichat.bean.ASR
import com.byteplus.aichat.databinding.FragmentAiSettingRecyclerBinding
import kotlin.getValue

class ASRChoiceFragment : Fragment(R.layout.fragment_ai_setting_recycler) {

    private val viewModel by navGraphViewModels<SettingsViewModel>(R.id.ai_chat_graph)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val binding = FragmentAiSettingRecyclerBinding.bind(view)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsects ->
            val insets = windowInsects.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            binding.recycler.updatePadding(bottom = insets.bottom)
            WindowInsetsCompat.CONSUMED
        }

        binding.back.setOnClickListener {
            it.findNavController().popBackStack()
        }

        binding.title.setText(R.string.ai_setting_label_core_asr)

        val current = viewModel.asrModel.value?.value
        val items = viewModel.asrs.map { ASRChoice(it, it.name == current) }

        binding.save.setOnClickListener {
            items.first { it.chosen }.let {
                if (it.text != current) {
                    viewModel.asrModel.postValue(Option(it.text, Source.USER))
                }
            }
            it.findNavController().popBackStack()
        }

        binding.recycler.apply {
            layoutManager = LinearLayoutManager(requireContext())
            addItemDecoration(ChoiceItemDecoration(requireContext()))
            adapter = ChoiceAdapter(requireContext(), items, null)
        }
    }

    class ASRChoice(asr: ASR, override var chosen: Boolean) : IChoice {
        override val text: String = asr.name
        override val icon: String = asr.icon
        override val audition: String = ""
        override var playing: Boolean = false
    }
}