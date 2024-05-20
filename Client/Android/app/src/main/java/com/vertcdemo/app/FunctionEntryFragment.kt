// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.constraintlayout.widget.Guideline
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.vertcdemo.app.function.FunctionEntryAdapter
import com.vertcdemo.app.function.FunctionItemDecoration
import com.videoone.app.protocol.IFunctionEntry

private const val TAG = "FunctionEntryFragment"

/**
 * @see com.videoone.app.protocol.FunctionVideoPlayback
 * @see com.videoone.app.protocol.FunctionPlaylist
 * @see com.videoone.app.protocol.FunctionSmartSubtitles
 * @see com.videoone.app.protocol.FunctionPreventRecording
 */
private val entryNames = listOf(
    "com.videoone.app.protocol.FunctionVideoPlayback",
    "com.videoone.app.protocol.FunctionPlaylist",
    "com.videoone.app.protocol.FunctionSmartSubtitles",
    "com.videoone.app.protocol.FunctionPreventRecording",
)

class FunctionEntryFragment : Fragment(R.layout.fragment_function_entry) {
    private val entries: List<IFunctionEntry> by lazy {
        entryNames.mapNotNull { entryClass ->
            try {
                val clazz = Class.forName(entryClass)
                clazz.newInstance() as IFunctionEntry
            } catch (e: ReflectiveOperationException) {
                Log.w(TAG, "Entry not found: $entryClass")
                null
            }
        }
    }

    private lateinit var mMainViewModel: MainViewModel
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mMainViewModel = ViewModelProvider(requireParentFragment())[MainViewModel::class.java]
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val guidelineTop = view.findViewById<Guideline>(R.id.guideline_top)
        mMainViewModel.guidelineTop.observe(viewLifecycleOwner) { top ->
            guidelineTop.setGuidelineBegin(top)
        }

        val context = requireContext()
        val recyclerView: RecyclerView = view.findViewById(R.id.recycler)
        recyclerView.layoutManager = LinearLayoutManager(context)
        recyclerView.addItemDecoration(
            FunctionItemDecoration(
                resources.getDimensionPixelSize(R.dimen.item_function_top),
                resources.getDimensionPixelSize(R.dimen.item_function_spacing)
            )
        )
        recyclerView.adapter = FunctionEntryAdapter(context, entries)
    }
}