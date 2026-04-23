package com.byteplus.aichat

import android.graphics.LinearGradient
import android.graphics.Shader
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts.RequestPermission
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.MutableCreationExtras
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.navigation.navGraphViewModels
import com.byteplus.aichat.databinding.FragmentAiDialerBinding
import com.byteplus.aichat.settings.SettingsViewModel
import com.byteplus.aichat.utils.lightStatusBar
import com.vertcdemo.core.http.bean.RTCAppInfo
import com.vertcdemo.ui.CenteredToast
import kotlin.getValue

class AiDialerFragment : Fragment(R.layout.fragment_ai_dialer) {

    private val settingsViewModel by navGraphViewModels<SettingsViewModel>(R.id.ai_chat_graph)

    private val viewModel by navGraphViewModels<AiChatViewModel>(
        R.id.ai_chat_graph,
        extrasProducer = {
            val intent = requireActivity().intent
            val rtcAppInfo = intent.getParcelableExtra<RTCAppInfo>(RTCAppInfo.KEY_APP_INFO)!!
            MutableCreationExtras().apply {
                set(KEY_CONTEXT, requireActivity().application)
                set(KEY_FRAGMENT, this@AiDialerFragment)
                set(KEY_RTC_APP_INFO, rtcAppInfo)
                set(KEY_SETTINGS_VIEW_MODEL, settingsViewModel)
            }
        },
        factoryProducer = {
            ViewModelProvider.Factory.from(AiChatViewModelInitializer)
        }
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        lightStatusBar()

        val binding = FragmentAiDialerBinding.bind(view)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsects ->
            val insets = windowInsects.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            binding.guidelineBottom.setGuidelineEnd(insets.bottom)
            WindowInsetsCompat.CONSUMED
        }

        binding.back.setOnClickListener {
            if (!it.findNavController().popBackStack()) {
                requireActivity().finish()
            }
        }

        binding.tips.post {
            // linear-gradient(78deg, #3B91FF -3.23%, #0D5EFF 51.11%, #C069FF 98.65%)
            binding.tips.apply {
                val context = requireContext()
                setTextColor(ContextCompat.getColor(context, R.color.ai_color_tips_start))
                val colors = intArrayOf(
                    ContextCompat.getColor(context, R.color.ai_color_tips_start),
                    ContextCompat.getColor(context, R.color.ai_color_tips_center),
                    ContextCompat.getColor(context, R.color.ai_color_tips_end),
                )
                paint.shader = LinearGradient(
                    0F,
                    height.toFloat(),
                    width.toFloat(),
                    0F,
                    colors,
                    null,
                    Shader.TileMode.CLAMP
                )
            }
        }

        binding.settings.setOnClickListener {
            it.findNavController().navigate(R.id.action_settings)
        }

        binding.callNow.setOnClickListener {
            if (ContextCompat.checkSelfPermission(
                    requireContext(),
                    android.Manifest.permission.RECORD_AUDIO
                ) == android.content.pm.PackageManager.PERMISSION_GRANTED
            ) {
                it.findNavController().navigate(R.id.action_conversation)
            } else {
                permissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
            }
        }

        viewModel.state.observe(viewLifecycleOwner) { state ->
            when (state) {
                AiState.NONE -> {
                    binding.loading.root.visibility = View.VISIBLE
                    viewModel.config()
                }

                AiState.CONFIGURED -> {
                    binding.loading.root.visibility = View.GONE
                }

                else -> {

                }
            }
        }
    }

    private val permissionLauncher = registerForActivityResult(RequestPermission()) {
        if (it) {
            findNavController().navigate(R.id.action_conversation)
        } else {
            CenteredToast.show(R.string.toast_ai_need_permission)
        }
    }
}