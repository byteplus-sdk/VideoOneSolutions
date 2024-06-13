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
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.findNavController
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.bumptech.glide.Glide
import com.vertcdemo.app.databinding.FragmentMainBinding
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent
import com.vertcdemo.core.eventbus.RefreshUserNameEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import com.videoone.avatars.Avatars
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class MainFragment : VersionFragment(R.layout.fragment_main) {
    private lateinit var mViewModel: MainViewModel
    private var mBinding: FragmentMainBinding? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mViewModel = ViewModelProvider(this)[MainViewModel::class.java]
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val binding = FragmentMainBinding.bind(view).also { mBinding = it }

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets: WindowInsetsCompat ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            mViewModel.guidelineTop.value = insets.top
            binding.guidelineTop.setGuidelineBegin(insets.top)
            windowInsets
        }

        binding.avatar.setOnClickListener {
            it.findNavController().navigate(R.id.profile)
        }

        binding.viewPager.adapter = TabAdapter(this)
        binding.viewPager.isUserInputEnabled = false

        binding.tabScenes.setOnClickListener { mViewModel.currentTab.setValue(0) }
        binding.tabFunction.setOnClickListener { mViewModel.currentTab.setValue(1) }
        binding.tabForDevelopers.setOnClickListener { mViewModel.currentTab.setValue(2) }

        mViewModel.currentTab.observe(viewLifecycleOwner) { position: Int ->
            WindowCompat.getInsetsController(
                requireActivity().window, requireView()
            ).isAppearanceLightStatusBars = (position == 1 || position == 2)

            binding.viewPager.setCurrentItem(position, false)

            val bold = Typeface.defaultFromStyle(Typeface.BOLD)
            val normal = Typeface.defaultFromStyle(Typeface.NORMAL)
            binding.tabScenes.isSelected = position == 0
            binding.tabScenes.typeface = if (position == 0) bold else normal

            binding.tabFunction.isSelected = position == 1
            binding.tabFunction.typeface = if (position == 1) bold else normal

            binding.tabForDevelopers.isSelected = position == 2
            binding.tabForDevelopers.typeface = if (position == 2) bold else normal
        }

        updateUserInfo(binding)

        SolutionEventBus.register(this)
    }

    private fun updateUserInfo(binding: FragmentMainBinding) {
        if (SolutionDataManager.userId.isNullOrEmpty()) {
            binding.avatar.visibility = View.GONE
        } else {
            binding.avatar.visibility = View.VISIBLE
            Glide.with(binding.avatar)
                .load(Avatars.byUserId(SolutionDataManager.userId))
                .into(binding.avatar)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        SolutionEventBus.unregister(this)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onTokenExpiredEvent(event: AppTokenExpiredEvent?) {

    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onRefreshUserNameEvent(event: RefreshUserNameEvent) {
        mBinding?.let { updateUserInfo(it) }
    }

    class TabAdapter(fragment: Fragment) : FragmentStateAdapter(fragment) {
        override fun getItemCount(): Int = 3

        override fun createFragment(position: Int): Fragment = when (position) {
            0 -> SceneEntryFragment()
            1 -> FunctionEntryFragment()
            2 -> ForDevelopersFragment()
            else -> throw IllegalArgumentException("Unknown position: $position")
        }
    }
}
