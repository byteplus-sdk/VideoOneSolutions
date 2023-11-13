// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.content.Context;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.content.res.ResourcesCompat;
import androidx.fragment.app.Fragment;

import com.vertcdemo.app.databinding.ItemSceneEntryBinding;
import com.vertcdemo.core.utils.AppUtil;
import com.videoone.app.protocol.SceneEntry;

public class SceneEntryFragment extends Fragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_scene_entry, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Context context = requireContext();
        ViewGroup cards = view.findViewById(R.id.cards);
        LayoutInflater inflater = LayoutInflater.from(context);

        SceneEntry.forEach(entry -> {
            int title = entry.title();
            int iconRes = entry.icon();
            if (title == ResourcesCompat.ID_NULL || iconRes == ResourcesCompat.ID_NULL) {
                return;
            }

            final ItemSceneEntryBinding binding = ItemSceneEntryBinding.inflate(inflater, cards, false);
            binding.newLabel.setVisibility(entry.isNew() ? View.VISIBLE : View.GONE);
            binding.title.setText(title);

            Drawable icon = ContextCompat.getDrawable(context, entry.icon());
            binding.icon.setImageDrawable(icon);
            if (icon instanceof AnimationDrawable) {
                ((AnimationDrawable) icon).start();
            }

            int description = entry.description();
            if (description != ResourcesCompat.ID_NULL) {
                binding.description.setText(description);
            }

            int action = entry.action();
            if (action != ResourcesCompat.ID_NULL) {
                binding.action.setText(action);
            }

            View card = binding.getRoot();
            card.setOnClickListener(v -> entry.startup(requireActivity()));
            cards.addView(card);
        });
    }
}