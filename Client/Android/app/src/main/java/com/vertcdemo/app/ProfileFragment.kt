// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatDialog
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.MutableLiveData
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.navigation.navGraphViewModels
import com.bumptech.glide.Glide
import com.vertcdemo.app.databinding.FragmentProfileBinding
import com.vertcdemo.app.databinding.LayoutCommonKeyValueBinding
import com.vertcdemo.login.UserViewModel
import com.videoone.avatars.Avatars.byUserId

private const val TAG = "ProfileFragment"

class ProfileFragment : Fragment(R.layout.fragment_profile) {

    private val userViewModel by activityViewModels<UserViewModel>()

    private val versionModel: VersionViewModel
            by navGraphViewModels(R.id.nav_app_main)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        WindowCompat.getInsetsController(
            requireActivity().window, requireView()
        ).isAppearanceLightStatusBars = true

        val binding = FragmentProfileBinding.bind(view)

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
                        key.setText(info.key)
                        value.text = info.value
                        root.setOnClickListener(info.listener)
                        more.visibility =
                            if (info.showMore && info.listener != null) View.VISIBLE else View.GONE
                    }

            info.hasNew?.observe(viewLifecycleOwner) { hasNew ->
                itemBinding.dot.visibility = if (hasNew) View.VISIBLE else View.GONE
            }
            binding.settingContainer.addView(itemBinding.root)
        }

        binding.profileExitLogin.setOnClickListener { showLogoutConfirm() }

        userViewModel.user.observe(viewLifecycleOwner) { user ->
            Glide.with(binding.profileUserAvatar)
                .load(byUserId(user.userId))
                .into(binding.profileUserAvatar)

            binding.profileUserName.text = user.userName
        }
    }

    private val settings by lazy {
        listOf(
            SettingInfo(R.string.language, getString(R.string.language_value)),
            SettingInfo(R.string.privacy_policy) { openBrowser(BuildConfig.PRIVACY_POLICY_URL) },
            SettingInfo(R.string.terms_of_service) { openBrowser(BuildConfig.TERMS_OF_SERVICE_URL) },
            SettingInfo(R.string.notices) { it.findNavController().navigate(R.id.notices) },
            SettingInfo(R.string.cancel_account) { showDeleteAccountConfirm() },
            SettingInfo(
                R.string.app_version,
                "v${BuildConfig.VERSION_NAME}",
                hasNew = versionModel.hasNew,
                showMore = false
            ) {
                val url = versionModel.newVersionUrl
                if (!url.isNullOrEmpty()) {
                    openBrowser(url)
                }
            },
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
            userViewModel.logout()
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
            userViewModel.closeAccount()
        }

        dialog.show()
    }

    private fun openBrowser(url: String) {
        try {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        } catch (e: ActivityNotFoundException) {
            Log.d(TAG, "openBrowser: failed: $url")
        }
    }
}

private class SettingInfo(
    val key: Int,
    val value: String? = null,
    val hasNew: MutableLiveData<Boolean>? = null,
    val showMore: Boolean = true,
    val listener: View.OnClickListener? = null
)
