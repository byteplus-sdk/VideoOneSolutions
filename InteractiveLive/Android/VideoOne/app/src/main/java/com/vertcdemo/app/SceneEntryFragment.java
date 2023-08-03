// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.vertcdemo.app.R;

import java.util.List;

public class SceneEntryFragment extends Fragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_scene_entry, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.setPackage(BuildConfig.APPLICATION_ID);
        intent.addCategory(Actions.CATEGORY_SCENE);

        Context context = requireContext();
        PackageManager packageManager = context.getPackageManager();
        List<ResolveInfo> scenes = packageManager.queryIntentActivities(intent, PackageManager.GET_META_DATA);
        LinearLayout cards = view.findViewById(R.id.cards);
        LayoutInflater inflater = LayoutInflater.from(context);

        for (ResolveInfo scene : scenes) {
            View card = inflater.inflate(R.layout.item_scene_entry, cards, false);
            ImageView icon = card.findViewById(R.id.icon);
            AnimationDrawable drawable = (AnimationDrawable) ContextCompat.getDrawable(context, R.drawable.menu_live);
            assert drawable != null;
            icon.setImageDrawable(drawable);
            drawable.start();

            TextView label = card.findViewById(R.id.title);
            label.setText(scene.loadLabel(packageManager));

            card.setOnClickListener(createSceneHandler(scene));
            cards.addView(card);
        }
    }

    private View.OnClickListener createSceneHandler(@NonNull ResolveInfo scene) {
        return v -> {
            final Context context = requireContext();
            final Intent intent = new Intent();
            intent.setClassName(context.getPackageName(), scene.activityInfo.name);
            startActivity(intent);
        };
    }
}