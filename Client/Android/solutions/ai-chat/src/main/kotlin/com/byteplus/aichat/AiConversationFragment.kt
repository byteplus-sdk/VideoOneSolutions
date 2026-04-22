package com.byteplus.aichat

import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updateLayoutParams
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.viewmodel.MutableCreationExtras
import androidx.navigation.fragment.findNavController
import androidx.navigation.navGraphViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.byteplus.aichat.databinding.FragmentAiConversationBinding
import com.byteplus.aichat.settings.AiStopConfirmDialog
import com.byteplus.aichat.settings.SettingsViewModel
import com.byteplus.aichat.utils.lightStatusBar
import com.vertcdemo.core.http.bean.RTCAppInfo
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class AiConversationFragment : Fragment(R.layout.fragment_ai_conversation) {

    private val settingsViewModel by navGraphViewModels<SettingsViewModel>(R.id.ai_chat_graph)

    private val viewModel by navGraphViewModels<AiChatViewModel>(
        R.id.ai_chat_graph,
        extrasProducer = {
            val intent = requireActivity().intent
            val rtcAppInfo = intent.getParcelableExtra<RTCAppInfo>(RTCAppInfo.KEY_APP_INFO)!!
            MutableCreationExtras().apply {
                set(KEY_CONTEXT, requireActivity().application)
                set(KEY_FRAGMENT, this@AiConversationFragment)
                set(KEY_RTC_APP_INFO, rtcAppInfo)
                set(KEY_SETTINGS_VIEW_MODEL, settingsViewModel)
            }
        },
        factoryProducer = {
            ViewModelProvider.Factory.from(AiChatViewModelInitializer)
        })

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        lightStatusBar()

        val binding = FragmentAiConversationBinding.bind(view)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsects ->
            val insets = windowInsects.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            binding.guidelineBottom.setGuidelineEnd(insets.bottom)
            WindowInsetsCompat.CONSUMED
        }

        val callback = object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                hangup()
            }
        }
        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner, callback)

        binding.back.setOnClickListener {
            hangup()
        }

        binding.settings.setOnClickListener {
            val dialog = AiStopConfirmDialog(requireContext()) {
                goToSettings()
            }
            dialog.show()
        }

        binding.mic.setOnClickListener {
            it.isSelected = !it.isSelected
            viewModel.mute(it.isSelected)
        }

        binding.hangup.setOnClickListener {
            hangup()
        }

        viewModel.startTime.observe(viewLifecycleOwner) { startTime ->
            val duration = SystemClock.uptimeMillis() - startTime
            var remaining = TRIAL_TIME_SECONDS - duration / 1000
            if (remaining >= 0 && startTime > 0) {
                binding.timeRemaining.visibility = View.VISIBLE
                mCountDownJob = null
                mCountDownJob = lifecycleScope.launch {
                    while (remaining >= 0) {
                        val seconds = remaining % 60
                        val minutes = remaining / 60
                        binding.timeRemaining.text =
                            getString(R.string.ai_time_remaining, minutes, seconds)

                        remaining--
                        delay(1000L)
                    }
                    hangup()
                    binding.timeRemaining.visibility = View.GONE
                }
            } else {
                binding.timeRemaining.visibility = View.GONE
            }
        }

        viewModel.state.observe(viewLifecycleOwner) { state ->
            when (state) {
                AiState.CONFIGURED -> {
                    binding.groupAiReady.visibility = View.GONE
                    binding.aiTips.visibility = View.VISIBLE
                    binding.aiTips.setText(R.string.ai_tips_preparing)

                    binding.aiAvatar.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                        topMargin = resources.getDimensionPixelSize(R.dimen.avatar_top_normal)
                    }

                    viewModel.prepare()
                }

                AiState.PREPARED -> {
                    binding.groupAiReady.visibility = View.VISIBLE
                    binding.aiTips.visibility = View.GONE

                    binding.aiAvatar.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                        topMargin = resources.getDimensionPixelSize(R.dimen.avatar_top_tips)
                    }

                    binding.aiReadyQuestions.apply {
                        if (layoutManager == null) {
                            layoutManager = LinearLayoutManager(requireContext())
                            addItemDecoration(QuestionItemDecoration(requireContext()))
                        }
                        if (adapter == null) {
                            adapter = QuestionAdapter(
                                requireContext(), settingsViewModel.questions
                            )
                        }
                    }
                }

                AiState.MUTED -> {
                    binding.groupAiReady.visibility = View.VISIBLE
                    binding.aiTips.visibility = View.VISIBLE
                    binding.aiTips.setText(R.string.ai_tips_muted)

                    binding.aiAvatar.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                        topMargin = resources.getDimensionPixelSize(R.dimen.avatar_top_tips)
                    }

                    binding.aiReadyQuestions.apply {
                        if (layoutManager == null) {
                            layoutManager = LinearLayoutManager(requireContext())
                            addItemDecoration(QuestionItemDecoration(requireContext()))
                        }
                        if (adapter == null) {
                            adapter = QuestionAdapter(
                                requireContext(), settingsViewModel.questions
                            )
                        }
                    }
                }

                AiState.LISTENING -> {
                    binding.groupAiReady.visibility = View.GONE
                    binding.aiTips.visibility = View.VISIBLE
                    binding.aiTips.setText(R.string.ai_tips_listening)

                    binding.aiAvatar.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                        topMargin =
                            requireContext().resources.getDimensionPixelSize(R.dimen.avatar_top_normal)
                    }
                }

                AiState.THINKING -> {
                    binding.groupAiReady.visibility = View.GONE
                    binding.aiTips.visibility = View.VISIBLE
                    binding.aiTips.setText(R.string.ai_tips_thinking)

                    binding.aiAvatar.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                        topMargin = resources.getDimensionPixelSize(R.dimen.avatar_top_normal)
                    }
                }

                AiState.SPEAKING -> {
                    binding.groupAiReady.visibility = View.GONE
                    binding.aiTips.visibility = View.VISIBLE
                    binding.aiTips.setText(R.string.ai_tips_speaking)

                    binding.aiAvatar.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                        topMargin = resources.getDimensionPixelSize(R.dimen.avatar_top_normal)
                    }
                }

                else -> {

                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        val startTime: Long? = viewModel.startTime.value
        if (startTime != null && startTime > 0) {
            val duration = SystemClock.uptimeMillis() - startTime
            val remaining = TRIAL_TIME_SECONDS - duration / 1000
            if (remaining <= 0) {
                hangup()
            }
        }
    }

    private fun goToSettings() {
        hangup()
        findNavController().navigate(R.id.action_settings)
    }

    private fun hangup() {
        mCountDownJob = null
        viewModel.hangup()
    }

    private var mCountDownJob: Job? = null
        set(value) {
            field?.cancel()
            field = value
        }
}

