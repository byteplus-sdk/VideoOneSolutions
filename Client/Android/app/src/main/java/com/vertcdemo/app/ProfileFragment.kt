// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatDialog
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import com.bumptech.glide.Glide
import com.vertcdemo.app.databinding.FragmentProfileBinding
import com.vertcdemo.app.databinding.LayoutCommonKeyValueBinding
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent
import com.vertcdemo.core.eventbus.RefreshUserNameEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import com.vertcdemo.login.ILoginImpl
import com.videoone.avatars.Avatars.byUserId
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class ProfileFragment : Fragment(R.layout.fragment_profile) {

    private var mBinding: FragmentProfileBinding? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        WindowCompat.getInsetsController(
            requireActivity().window, requireView()
        ).isAppearanceLightStatusBars = true

        val binding = FragmentProfileBinding.bind(view).also { mBinding = it }

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets: WindowInsetsCompat ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            windowInsets
        }

        binding.back.setOnClickListener {
            it.findNavController().popBackStack()
        }

        settings.forEach { info ->
            val itemBinding =
                LayoutCommonKeyValueBinding.inflate(layoutInflater, binding.settingContainer, false)
                    .apply {
                        more.visibility = if (info.listener != null) View.VISIBLE else View.GONE
                        key.setText(info.key)
                        value.text = info.value
                        root.setOnClickListener(info.listener)
                    }

            binding.settingContainer.addView(itemBinding.root)
        }

        binding.profileExitLogin.setOnClickListener { showLogoutConfirm() }

        updateUserInfo(binding)
        SolutionEventBus.register(this)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        SolutionEventBus.unregister(this)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onRefreshUserNameEvent(event: RefreshUserNameEvent) {
        mBinding?.let { updateUserInfo(it) }
    }

    private fun updateUserInfo(binding: FragmentProfileBinding) {
        Glide.with(binding.profileUserAvatar)
            .load(byUserId(SolutionDataManager.ins().userId))
            .into(binding.profileUserAvatar)

        binding.profileUserName.text = SolutionDataManager.ins().userName
    }

    private val settings by lazy {
        listOf(
            SettingInfo(R.string.language, getString(R.string.language_value)),
            SettingInfo(R.string.privacy_policy) { openBrowser(BuildConfig.PRIVACY_POLICY_URL) },
            SettingInfo(R.string.terms_of_service) { openBrowser(BuildConfig.TERMS_OF_SERVICE_URL) },
            SettingInfo(R.string.notices) { it.findNavController().navigate(R.id.notices) },
            SettingInfo(R.string.cancel_account) { showDeleteAccountConfirm() },
            SettingInfo(R.string.app_version, "v${BuildConfig.VERSION_NAME}"),
            SettingInfo(R.string.github) { openBrowser(BuildConfig.GITHUB_REPO) },
        )
    }

    private fun showLogoutConfirm() {
        val dialog = AppCompatDialog(requireContext(), R.style.AppDialog)
        dialog.setContentView(R.layout.dialog_account_security)

        dialog.findViewById<TextView>(R.id.title)?.setText(R.string.log_out)
        dialog.findViewById<TextView>(R.id.content)?.setText(R.string.log_out_alert_message)
        dialog.findViewById<TextView>(R.id.cancel)?.setOnClickListener { dialog.cancel() }
        dialog.findViewById<TextView>(R.id.confirm)?.setOnClickListener {
            dialog.dismiss()
            findNavController().popBackStack()
            SolutionDataManager.ins().logout()
            SolutionEventBus.post(AppTokenExpiredEvent())
        }

        dialog.show()
    }

    private fun showDeleteAccountConfirm() {
        val dialog = AppCompatDialog(requireContext(), R.style.AppDialog)
        dialog.setContentView(R.layout.dialog_account_security)

        dialog.findViewById<TextView>(R.id.title)?.setText(R.string.cancel_account)
        dialog.findViewById<TextView>(R.id.content)?.setText(R.string.cancel_account_alert_message)
        dialog.findViewById<TextView>(R.id.cancel)?.setOnClickListener { dialog.cancel() }
        dialog.findViewById<TextView>(R.id.confirm)?.setOnClickListener {
            dialog.dismiss()
            findNavController().popBackStack()
            ILoginImpl().closeAccount()
        }

        dialog.show()
    }

    private fun openBrowser(url: String) = startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))

    private class SettingInfo(
        val key: Int,
        val value: String? = null,
        val listener: View.OnClickListener? = null
    )
}
