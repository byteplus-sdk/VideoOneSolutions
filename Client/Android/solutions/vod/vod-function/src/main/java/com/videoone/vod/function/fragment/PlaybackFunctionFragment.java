// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.vod.function.fragment;

import static com.videoone.vod.function.VodFunctionActivity.EXTRA_FUNCTION;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.byteplus.vodfunction.R;
import com.videoone.vod.function.Function;
import com.videoone.vod.function.VodFunctionDispatchActivity;

import java.util.Arrays;
import java.util.List;

public class PlaybackFunctionFragment extends Fragment {

    private final List<FunctionItem> mEntries = Arrays.asList(
            new FunctionItem(
                    R.drawable.vevod_function_video_playback,
                    R.string.vevod_function_playback_title,
                    Function.VIDEO_PLAYBACK
            ),
            new FunctionItem(
                    R.drawable.vevod_function_prevent_recording,
                    R.string.vevod_function_prevent_recording_title,
                    Function.PREVENT_RECORDING
            ),
            new FunctionItem(
                    R.drawable.vevod_function_smart_subtitles,
                    R.string.vevod_function_smart_subtitle_title,
                    Function.SMART_SUBTITLES
            ),
            new FunctionItem(
                    R.drawable.vevod_function_playlist,
                    R.string.vevod_function_playlist_title,
                    Function.PLAYLIST
            )
    );

    private PlaybackFunctionViewModel mViewModel;

    public PlaybackFunctionFragment() {
        super(R.layout.vevod_fragment_playback_function);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(PlaybackFunctionViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Context context = requireContext();
        ViewGroup listview = view.findViewById(R.id.list);

        LayoutInflater inflater = LayoutInflater.from(context);

        for (FunctionItem item : mEntries) {
            View categoryLayout = inflater.inflate(R.layout.vevod_layout_playback_function_category, listview, false);
            ViewGroup categoryItems = categoryLayout.findViewById(R.id.items);
            listview.addView(categoryLayout);

            View itemView = inflater.inflate(R.layout.vevod_layout_playback_function_item,
                    categoryItems, false);
            TextView itemText = itemView.findViewById(R.id.title);
            itemText.setText(item.title);
            ImageView itemImg = itemView.findViewById(R.id.icon);
            itemImg.setImageResource(item.icon);

            itemView.setOnClickListener(v -> {
                Intent intent = new Intent(context, VodFunctionDispatchActivity.class);
                intent.putExtra(EXTRA_FUNCTION, item.function);
                context.startActivity(intent);
            });

            categoryItems.addView(itemView);
        }

        mViewModel.licenseResult.observe(getViewLifecycleOwner(), licenseResult -> {
            if (licenseResult.isEmpty()) {
                mViewModel.checkLicense();
            } else if (!licenseResult.isOk()) {
                final TextView licenseTips = view.findViewById(R.id.license_tips);
                licenseTips.setText(licenseResult.message);
                licenseTips.setVisibility(View.VISIBLE);
                licenseTips.setOnClickListener(v -> {/*consume the click event*/});
            }
        });
    }

    private static class FunctionItem {
        public final int icon;
        public final int title;
        @NonNull
        public final Function function;

        public FunctionItem(@DrawableRes int icon,
                            @StringRes int title,
                            @NonNull Function function) {
            this.icon = icon;
            this.title = title;
            this.function = function;
        }
    }
}
