// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui.page

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.vertcdemo.effect.R
import com.vertcdemo.effect.bean.StickerItem
import com.vertcdemo.effect.ui.EffectFragment
import com.vertcdemo.effect.ui.EffectViewModel
import com.vertcdemo.effect.ui.ValueProgress

class StickerFragment : Fragment(R.layout.fragment_sticker) {
    private lateinit var mParent: EffectFragment

    private lateinit var mViewModel: EffectViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mParent = requireParentFragment() as EffectFragment
        mViewModel = mParent.uIViewModel
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val recyclerView = view.findViewById<RecyclerView>(R.id.recycler).apply {
            layoutManager = GridLayoutManager(requireContext(), 5)
        }

        recyclerView.adapter = EffectItemAdapter(mViewModel.stickerItems) { item: StickerItem ->
            mViewModel.selectedSticker = item
        }
    }

    override fun onResume() {
        super.onResume()
        mParent.updateProgressBar(ValueProgress.NONE)
    }
}
