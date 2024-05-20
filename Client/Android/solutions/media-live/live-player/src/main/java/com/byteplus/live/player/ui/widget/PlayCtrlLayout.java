// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.widget;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;

import androidx.annotation.NonNull;

import com.byteplus.live.player.LivePlayerListener;
import com.byteplus.live.player.R;
import com.byteplus.live.settings.PreferenceUtil;

public class PlayCtrlLayout {

    @NonNull
    private View[] resolutions = new View[0];

    private final View root;

    public PlayCtrlLayout(Context context, LivePlayerListener listener) {
        root = createView(context, listener);
    }

    public View getRoot() {
        return root;
    }


    public void setResolution(String value) {
        for (View view : resolutions) {
            String tag = (String) view.getTag(R.id.tag_resolution);
            view.setSelected(tag.equals(value));
        }
    }

    private View createView(@NonNull Context context, @NonNull LivePlayerListener listener) {
        PreferenceUtil prefs = PreferenceUtil.getInstance();
        View root = LayoutInflater.from(context).inflate(R.layout.live_player_basic_control, null);

        root.findViewById(R.id.play).setOnClickListener(v -> {
            listener.onStartPlay();
        });

        root.findViewById(R.id.stop).setOnClickListener(v -> {
            listener.onStopPlay();
        });

        root.findViewById(R.id.pause_resume).setOnClickListener(v -> {
            if (listener.isPlaying()) {
                listener.onPausePlay();
            } else {
                listener.onResumePlay();
            }
        });

        CheckBox backgroundPlay = root.findViewById(R.id.background_playback);
        backgroundPlay.setChecked(prefs.getPullEnableBackgroundPlay(false));
        backgroundPlay.setOnCheckedChangeListener((buttonView, isChecked) -> {
            prefs.setPullEnableBackgroundPlay(isChecked);
        });

        View groupChangeResolution = root.findViewById(R.id.group_change_resolution);

        if (prefs.getPullAbr(false)) {
            groupChangeResolution.setVisibility(View.VISIBLE);

            View resolutionOrigin = root.findViewById(R.id.resolution_origin);
            View resolutionUhd = root.findViewById(R.id.resolution_uhd);
            View resolutionHd = root.findViewById(R.id.resolution_hd);
            View resolutionLd = root.findViewById(R.id.resolution_ld);
            View resolutionSd = root.findViewById(R.id.resolution_sd);

            resolutions = new View[]{resolutionOrigin, resolutionUhd, resolutionHd, resolutionLd, resolutionSd};

            View.OnClickListener onClickListener = view -> {
                if (view.isSelected()) {
                    return;
                }

                for (View item : resolutions) {
                    item.setSelected(item == view);
                }

                String resolution = (String) view.getTag(R.id.tag_resolution);
                prefs.setPullAbrCurrent(resolution);
                listener.onSwitchResolution(resolution);
            };

            resolutionOrigin.setTag(R.id.tag_resolution, PreferenceUtil.PULL_ABR_ORIGIN);
            resolutionOrigin.setOnClickListener(onClickListener);
            resolutionUhd.setTag(R.id.tag_resolution, PreferenceUtil.PULL_ABR_UHD);
            resolutionUhd.setOnClickListener(onClickListener);
            resolutionHd.setTag(R.id.tag_resolution, PreferenceUtil.PULL_ABR_HD);
            resolutionHd.setOnClickListener(onClickListener);
            resolutionLd.setTag(R.id.tag_resolution, PreferenceUtil.PULL_ABR_LD);
            resolutionLd.setOnClickListener(onClickListener);
            resolutionSd.setTag(R.id.tag_resolution, PreferenceUtil.PULL_ABR_SD);
            resolutionSd.setOnClickListener(onClickListener);

            if (!TextUtils.isEmpty(prefs.getPullAbrOrigin(""))) {
                resolutionOrigin.setVisibility(View.VISIBLE);
            }
            if (!TextUtils.isEmpty(prefs.getPullAbrUhd(""))) {
                resolutionUhd.setVisibility(View.VISIBLE);
            }
            if (!TextUtils.isEmpty(prefs.getPullAbrHd(""))) {
                resolutionHd.setVisibility(View.VISIBLE);
            }
            if (!TextUtils.isEmpty(prefs.getPullAbrLd(""))) {
                resolutionLd.setVisibility(View.VISIBLE);
            }
            if (!TextUtils.isEmpty(prefs.getPullAbrSd(""))) {
                resolutionSd.setVisibility(View.VISIBLE);
            }

            String current = prefs.getPullAbrCurrent(PreferenceUtil.PULL_ABR_ORIGIN);
            setResolution(current);
        } else {
            groupChangeResolution.setVisibility(View.GONE);
        }

        return root;
    }
}
