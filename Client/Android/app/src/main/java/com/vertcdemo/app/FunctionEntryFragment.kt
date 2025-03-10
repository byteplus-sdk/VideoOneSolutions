// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.google.android.material.tabs.TabLayoutMediator
import com.vertcdemo.app.databinding.FragmentFunctionEntryBinding
import com.videoone.app.protocol.IFunctionTabEntry

private const val TAG = "FunctionEntryFragment"

private val entryNames = listOf(
    "com.videoone.app.protocol.FunctionMediaLive",
    "com.videoone.app.protocol.PlaybackFunction",
    "com.videoone.app.protocol.RTCApiExampleFunction"
)

object FunctionEntry {
    val entries: List<IFunctionTabEntry> by lazy {
        entryNames.mapNotNull { entryClass ->
            try {
                val clazz = Class.forName(entryClass)
                clazz.getConstructor().newInstance() as IFunctionTabEntry
            } catch (e: ReflectiveOperationException) {
                Log.w(TAG, "Entry not found: $entryClass")
                null
            }
        }
    }
}

class FunctionEntryFragment : Fragment(R.layout.fragment_function_entry) {

    private var mBinding: FragmentFunctionEntryBinding? = null

    private lateinit var mMainViewModel: MainViewModel
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mMainViewModel = ViewModelProvider(requireParentFragment())[MainViewModel::class.java]
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val binding = FragmentFunctionEntryBinding.bind(view).also { mBinding = it }
        mMainViewModel.guidelineTop.observe(viewLifecycleOwner) { top ->
            binding.guidelineTop.setGuidelineBegin(top)
        }

        val context = requireContext()
        binding.viewPager.adapter = TabAdapter(this, FunctionEntry.entries)
        TabLayoutMediator(binding.tabs, binding.viewPager) { tab, position ->
            val tabLayout: View = LayoutInflater.from(context)
                .inflate(R.layout.layout_function_tablayout_item, binding.tabs, false);
            val tabView: TextView = tabLayout.findViewById(R.id.tab_text)
            tabView.text = getString(FunctionEntry.entries[position].title)
            tab.customView = tabView
        }.attach()
    }

    class TabAdapter(fragment: Fragment, entries: List<IFunctionTabEntry>) :
        FragmentStateAdapter(fragment) {
        private val entryList = entries
        override fun getItemCount(): Int = entryList.size

        override fun createFragment(position: Int): Fragment {
            return entryList[position].fragment()
        }
    }
}