// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.widget;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.SeekBar;

import androidx.annotation.NonNull;

import com.byteplus.live.player.LivePlayerListener;
import com.byteplus.live.player.R;
import com.byteplus.live.settings.PreferenceUtil;

import java.util.Arrays;
import java.util.List;

public class MediaSettingsDialog extends SettingsDialogWithTab {
    private final LivePlayerListener mListener;
    private final Context mContext;
    public static final int[] TAB_NAMES = {R.string.medialive_video, R.string.medialive_audio};
    List<View> mViews;

    public MediaSettingsDialog(@NonNull Context context, @NonNull LivePlayerListener listener) {
        super(context);
        mListener = listener;
        mContext = context;
    }

    @Override
    public int[] getTabNames() {
        return TAB_NAMES;
    }

    @Override
    public List<View> generateTabViews() {
        if (mViews == null) {
            mViews = Arrays.asList(
                    createVideo(mContext, mListener),
                    createAudio(mContext, mListener)
            );
        }

        return mViews;
    }

    private static View createVideo(Context context, LivePlayerListener listener) {
        View root = LayoutInflater.from(context).inflate(R.layout.live_player_video_control, null);

        root.findViewById(R.id.screen_shot).setOnClickListener(v -> {
            listener.onSnapShot();
        });

        return root;
    }

    private static View createAudio(Context context, LivePlayerListener listener) {
        View root = LayoutInflater.from(context).inflate(R.layout.live_player_audio_control, null);

        SeekBar volumeSeekBar = root.findViewById(R.id.volume_seekbar);
        volumeSeekBar.setProgress(100);
        volumeSeekBar.setProgress((int) (PreferenceUtil.getInstance().getPullVolume(1.0f) * 100));
        volumeSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (listener == null) {
                    return;
                }
                int progress = volumeSeekBar.getProgress();
                float volume = (float) progress / 100.0f;
                listener.onSetVolume(volume);
            }
        });

        CheckBox volumeMute = root.findViewById(R.id.volume_mute);
        volumeMute.setOnCheckedChangeListener((checkBox, isChecked) -> {
            if (listener == null) {
                return;
            }
            if (checkBox == volumeMute) {
                listener.onSetMute(isChecked);
            }
        });
        if (listener != null) {
            volumeMute.setChecked(listener.onGetIsMute());
        }

        return root;
    }
}
