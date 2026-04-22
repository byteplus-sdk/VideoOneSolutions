// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.app

import android.os.Bundle
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.navigation.findNavController
import com.vertcdemo.app.databinding.FragmentNoticesBinding

class NoticesFragment : Fragment(R.layout.fragment_notices) {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        WindowCompat.getInsetsController(
            requireActivity().window, requireView()
        ).isAppearanceLightStatusBars = true

        val binding = FragmentNoticesBinding.bind(view)
        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets: WindowInsetsCompat ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            windowInsets
        }

        binding.back.setOnClickListener { it.findNavController().popBackStack() }

        binding.webView.loadUrl("file:///android_asset/notices.txt")
    }
}