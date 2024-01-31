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

class MainFragment : Fragment(R.layout.fragment_main) {
    private lateinit var mViewModel: MainViewModel
    private var mBinding: FragmentMainBinding? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mViewModel = ViewModelProvider(this)[MainViewModel::class.java]
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val binding = FragmentMainBinding.bind(view).also { mBinding = it }

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets: WindowInsetsCompat ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            windowInsets
        }

        binding.avatar.setOnClickListener {
            it.findNavController().navigate(R.id.profile)
        }

        binding.tabContent.adapter = TabAdapter(this)
        binding.tabContent.isUserInputEnabled = false
        binding.tabScenes.setOnClickListener { mViewModel.currentTab.setValue(0) }
        binding.tabFunction.setOnClickListener { mViewModel.currentTab.setValue(1) }
        mViewModel.currentTab.observe(getViewLifecycleOwner()) { position: Int ->
            binding.tabContent.setCurrentItem(position, false)
            binding.tabScenes.setSelected(position == 0)
            binding.tabFunction.setSelected(position == 1)
            WindowCompat.getInsetsController(
                requireActivity().window, requireView()
            ).isAppearanceLightStatusBars = position == 1

            if (position == 0) {
                binding.tabScenes.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD))
                binding.tabFunction.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL))
            } else {
                binding.tabFunction.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD))
                binding.tabScenes.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL))
            }
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
                .circleCrop().into(binding.avatar)
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

    private class TabAdapter(fragment: Fragment) : FragmentStateAdapter(fragment) {
        override fun createFragment(position: Int) = when (position) {
            0 -> SceneEntryFragment()
            1 -> FunctionEntryFragment()
            else -> throw IndexOutOfBoundsException("Index out of range: $position")
        }

        override fun getItemCount(): Int = 2
    }
}
