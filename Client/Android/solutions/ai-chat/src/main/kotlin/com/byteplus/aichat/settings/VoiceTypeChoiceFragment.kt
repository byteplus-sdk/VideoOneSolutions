package com.byteplus.aichat.settings

import android.media.MediaPlayer
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.fragment.app.Fragment
import androidx.navigation.findNavController
import androidx.navigation.navGraphViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.byteplus.aichat.R
import com.byteplus.aichat.bean.EmptyVoice
import com.byteplus.aichat.bean.Voice
import com.byteplus.aichat.databinding.FragmentAiSettingRecyclerBinding

const val EXTRA_INTEGRATION_MODE = "extra_integration_mode"
const val TAG = "VoiceTypeChoice"

class VoiceTypeChoiceFragment : Fragment(R.layout.fragment_ai_setting_recycler) {

    private val viewModel by navGraphViewModels<SettingsViewModel>(R.id.ai_chat_graph)

    private var mediaPlayer : MediaPlayer? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val arguments = requireArguments()
        val mode: IntegrationMode =
            arguments.getSerializable(EXTRA_INTEGRATION_MODE) as IntegrationMode

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

        binding.title.setText(R.string.ai_setting_label_core_voice_type)

        val voiceConfig = when (mode) {
            IntegrationMode.REALTIME -> viewModel.voiceTypeRealtime
            IntegrationMode.FLEXIBLE -> viewModel.voiceTypeFlexible
        }
        val current = voiceConfig.value?.value ?: EmptyVoice

        val providers = when(mode) {
            IntegrationMode.REALTIME -> viewModel.realtimeVoiceProviders
            IntegrationMode.FLEXIBLE -> viewModel.flexibleVoiceProviders
        }

        val items = providers.flatMap { provider ->
            provider.voices.map { voiceType ->
                val voice = Voice(provider, voiceType)
                VoiceTypeChoice(voice, voice == current)
            }
        }

        if (providers.size == 2) {
            binding.providerButtonContainer.visibility = View.VISIBLE
            for ((index, provider) in providers.withIndex()) {
                val chosen = current.provider.name == provider.name
                if (index == 0) {
                    binding.provider1.text = provider.name
                    binding.provider1.isSelected = chosen
                } else {
                    binding.provider2.text = provider.name
                    binding.provider2.isSelected = chosen
                }
            }
            binding.provider1.setOnClickListener {
                if (!binding.provider1.isSelected) {
                    binding.provider1.isSelected = true
                    binding.provider2.isSelected = false
                    val itemList: MutableList<IChoice> = mutableListOf()
                    for (item in items) {
                        if (item.voice.providerName == binding.provider1.text) {
                            itemList.add(item)
                        } else {
                            item.playing = false
                        }
                    }
                    releasePlayer()
                    val adapter  = binding.recycler.adapter as ChoiceAdapter
                    adapter.setItems(itemList)
                }
            }
            binding.provider2.setOnClickListener {
                if (!binding.provider2.isSelected) {
                    binding.provider1.isSelected = false
                    binding.provider2.isSelected = true
                    val itemList: MutableList<IChoice> = mutableListOf()
                    for (item in items) {
                        if (item.voice.providerName == binding.provider2.text) {
                            itemList.add(item)
                        } else {
                            item.playing = false
                        }
                    }
                    releasePlayer()
                    val adapter  = binding.recycler.adapter as ChoiceAdapter
                    adapter.setItems(itemList)
                }
            }
        } else {
            binding.providerButtonContainer.visibility = View.GONE
        }

        binding.save.setOnClickListener { v ->
            items.filter{ it.chosen }.let { choices ->
                choices.map { choice ->
                    if (providers.size == 2) {
                        val chosenProvider = if (binding.provider1.isSelected) binding.provider1.text else binding.provider2.text
                        if (choice.voice.providerName != chosenProvider) {
                            choice.chosen = false
                        } else {
                            if (choice.voice != current) {
                                voiceConfig.value = Option(choice.voice, Source.USER)
                            }
                        }
                    } else {
                        if (choice.voice != current) {
                            voiceConfig.value = Option(choice.voice, Source.USER)
                        }
                    }
                }
            }

            v.findNavController().popBackStack()
        }

        val chosenListener = object : IChosenClickListener {
            override fun onChosen(choice: IChoice) {
                for (i in items.indices) {
                    val old = items[i]
                    if (old !== choice && old.chosen) {
                        old.chosen = false
                    }
                }
            }

            override fun onPlaying(position : Int, choice: IChoice) {
                for (i in items.indices) {
                    val old = items[i]
                    if (old !== choice && old.playing) {
                        old.playing = false
                    }
                }

                try {
                    releasePlayer()
                    mediaPlayer = MediaPlayer()
                    mediaPlayer?.setDataSource(choice.audition)
                    mediaPlayer?.prepareAsync()
                    mediaPlayer?.setOnCompletionListener {
                        choice.playing = false
                        binding.recycler.adapter?.notifyItemChanged(position, PAYLOAD_PLAYING)
                    }
                    mediaPlayer?.setOnPreparedListener {
                        mediaPlayer?.start()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Play voice type error : ".plus(e.message))
                }
            }
        }

        binding.recycler.apply {
            layoutManager = LinearLayoutManager(requireContext())
            addItemDecoration(ChoiceItemDecoration(requireContext()))
            if (providers.size == 2) {
                val itemList: MutableList<IChoice> = mutableListOf()
                for (item in items) {
                    if (item.voice.providerName == current.providerName) {
                        itemList.add(item)
                    }
                }
                adapter = ChoiceAdapter(requireContext(), itemList, chosenListener)
            } else {
                adapter = ChoiceAdapter(requireContext(), items, chosenListener)
            }
        }
    }

    private fun releasePlayer() {
        try {
            if (mediaPlayer?.isPlaying == true) {
                mediaPlayer?.stop()
            }
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            Log.i(TAG, "MediaPlayer release error : ".plus(e.message))
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        releasePlayer()
    }

    class VoiceTypeChoice(
        val voice: Voice,
        override var chosen: Boolean = false,
        override var playing: Boolean = false
    ) : IChoice {
        override val text: String = voice.name
        override val icon: String = voice.icon
        override val audition: String = voice.audition
    }
}