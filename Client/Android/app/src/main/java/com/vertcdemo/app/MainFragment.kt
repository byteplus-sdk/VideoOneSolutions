// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.graphics.Typeface
import android.os.Bundle
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.bumptech.glide.Glide
import com.vertcdemo.app.databinding.FragmentMainBinding
import com.vertcdemo.login.UserViewModel
import com.videoone.app.protocol.SceneEntry
import com.videoone.avatars.Avatars

class MainFragment : VersionFragment(R.layout.fragment_main) {
    private val mViewModel by viewModels<MainViewModel>()
    private val userViewModel by activityViewModels<UserViewModel>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        userViewModel.logged.observe(viewLifecycleOwner) {
            if (!it) {
                findNavController()
                    .navigate(R.id.login)
            }
        }

        super.onViewCreated(view, savedInstanceState)

        val binding = FragmentMainBinding.bind(view)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets: WindowInsetsCompat ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            mViewModel.guidelineTop.value = insets.top
            binding.guidelineTop.setGuidelineBegin(insets.top)
            binding.guidelineBottom.setGuidelineEnd(insets.bottom)
            windowInsets
        }

        binding.avatar.setOnClickListener {
            it.findNavController().navigate(R.id.profile)
        }

        binding.viewPager.adapter = TabAdapter(this)
        binding.viewPager.isUserInputEnabled = false

        binding.tabScenes.setOnClickListener { mViewModel.currentTab.setValue(0) }
        binding.tabFunction.setOnClickListener { mViewModel.currentTab.setValue(1) }

        mViewModel.currentTab.observe(viewLifecycleOwner) { position: Int ->
            WindowCompat.getInsetsController(
                requireActivity().window, requireView()
            ).isAppearanceLightStatusBars = (position == 1 || position == 2)

            binding.viewPager.setCurrentItem(position, false)

            val bold = Typeface.defaultFromStyle(Typeface.BOLD)
            val normal = Typeface.defaultFromStyle(Typeface.NORMAL)
            binding.tabScenes.isSelected = position == 0
            binding.iconScenes.typeface = if (position == 0) bold else normal

            binding.tabFunction.isSelected = position == 1
            binding.iconScenes.typeface = if (position == 1) bold else normal
        }

        userViewModel.user.observe(viewLifecycleOwner) { user ->
            val userId = user.userId
            if (userId.isEmpty()) {
                binding.avatar.visibility = View.GONE
            } else {
                binding.avatar.visibility = View.VISIBLE
                Glide.with(binding.avatar)
                    .load(Avatars.byUserId(userId))
                    .into(binding.avatar)
            }
        }

        val sceneCount = SceneEntry.entries.size
        val functionCount = FunctionEntry.entries.size
        if (sceneCount == 0 || functionCount == 0) {
            binding.groupTabs.visibility = View.GONE

            if (sceneCount == 0 && functionCount != 0) {
                mViewModel.currentTab.value = 1
            }
        }
    }

    class TabAdapter(fragment: Fragment) : FragmentStateAdapter(fragment) {
        override fun getItemCount(): Int = 2

        override fun createFragment(position: Int): Fragment = when (position) {
            0 -> SceneEntryFragment()
            1 -> FunctionEntryFragment()
            else -> throw IllegalArgumentException("Unknown position: $position")
        }
    }
}
