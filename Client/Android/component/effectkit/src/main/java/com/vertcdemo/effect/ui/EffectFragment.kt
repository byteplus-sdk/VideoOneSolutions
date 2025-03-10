// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.slider.Slider
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayout.OnTabSelectedListener
import com.google.android.material.tabs.TabLayoutMediator
import com.vertcdemo.effect.R
import com.vertcdemo.effect.bean.EffectType
import com.vertcdemo.effect.core.IEffect.EffectResult
import com.vertcdemo.effect.databinding.FragmentEffectBinding
import com.vertcdemo.effect.databinding.LayoutTipsBinding
import com.vertcdemo.effect.ui.page.BeautyFragment
import com.vertcdemo.effect.ui.page.FilterFragment
import com.vertcdemo.effect.ui.page.StickerFragment
import java.util.Locale

abstract class EffectFragment : BottomSheetDialogFragment(R.layout.fragment_effect),
    EffectViewModelProvider {
    override fun getTheme(): Int = R.style.EffectBottomSheetDialogTheme

    val uIViewModel: EffectViewModel by lazy { getEffectViewModel() }

    private var mSlider: Slider? = null
    private var mProgress: ValueProgress = ValueProgress.NONE

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val binding = FragmentEffectBinding.bind(view)
        mSlider = binding.slider.apply {
            setLabelFormatter {
                String.format(Locale.ENGLISH, "%1$.0f", it * 100)
            }

            addOnChangeListener { _, value, fromUser ->
                if (fromUser && mProgress.type != EffectType.none) {
                    uIViewModel.updateItemValue(mProgress.type, value)
                }
            }
        }

        binding.viewPager.adapter = object : FragmentStateAdapter(childFragmentManager, lifecycle) {
            override fun createFragment(position: Int): Fragment {
                return when (position) {
                    0 -> BeautyFragment()
                    1 -> FilterFragment()
                    2 -> StickerFragment()
                    else -> throw IllegalArgumentException("Unhandled position: $position")
                }
            }

            override fun getItemCount(): Int {
                return 3
            }
        }

        TabLayoutMediator(
            binding.tab, binding.viewPager
        ) { tab: TabLayout.Tab, position: Int ->
            when (position) {
                0 -> tab.setText(R.string.tab_face_beautification)
                1 -> tab.setText(R.string.tab_filter)
                2 -> tab.setText(R.string.tab_sticker)
                else -> throw IllegalArgumentException("Unhandled position: $position")
            }
        }.attach()

        binding.tab.addOnTabSelectedListener(object : OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab) {
                uIViewModel.tabIndex = tab.position
            }

            override fun onTabUnselected(tab: TabLayout.Tab) {
            }

            override fun onTabReselected(tab: TabLayout.Tab) {
            }
        })

        binding.viewPager.setCurrentItem(uIViewModel.tabIndex, false)

        binding.tips.root.setOnClickListener {
            // just consume click event
        }

        uIViewModel.state.observe(viewLifecycleOwner) { state ->
            when (state) {
                EffectState.NONE -> uIViewModel.uncompressResources()
                EffectState.LOADING -> {
                    binding.tips.showLoading()
                }

                is EffectState.LOADED -> {
                    if (state.result.success) {
                        binding.tips.hide()
                    } else {
                        binding.tips.showTips(state.result)
                    }
                }

                else -> binding.tips.hide()
            }
        }
    }

    override fun onStart() {
        super.onStart()
        val behavior = BottomSheetBehavior.from(requireView().parent as View)
        behavior.state = BottomSheetBehavior.STATE_EXPANDED
    }

    fun updateProgressBar(progress: ValueProgress) {
        mSlider?.visibility = if (progress === ValueProgress.NONE || progress.isNone) {
            View.INVISIBLE
        } else {
            mSlider?.value = progress.value
            View.VISIBLE
        }
        mProgress = progress
    }

    private fun LayoutTipsBinding.showLoading() {
        text.visibility = View.GONE
        progress.visibility = View.VISIBLE

        root.visibility = View.VISIBLE
    }

    private fun LayoutTipsBinding.hide() {
        root.visibility = View.GONE
    }

    private fun LayoutTipsBinding.showTips(result: EffectResult) {
        text.visibility = View.VISIBLE
        text.text = result.message
        progress.visibility = View.GONE

        root.visibility = View.VISIBLE
    }
}
