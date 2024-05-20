// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.widget;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.byteplus.live.player.LivePlayerListener;
import com.byteplus.live.player.R;

import java.util.Arrays;
import java.util.List;

public class BasicSettingsDialog extends SettingsDialogWithTab {
    private final LivePlayerListener mListener;
    private final Context mContext;

    PlayCtrlLayout mPlayCtrlLayout;
    public static final int[] TAB_NAMES = {
            R.string.medialive_play_control,
            R.string.medialive_info_display
    };

    public BasicSettingsDialog(@NonNull Context context, LivePlayerListener listener) {
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
        mPlayCtrlLayout = new PlayCtrlLayout(mContext, mListener);
        return Arrays.asList(mPlayCtrlLayout.getRoot(), PlayInfoLayout.create(mContext, mListener));
    }

    public void switchResolution(String resolution) {
        if (mPlayCtrlLayout != null) {
            mPlayCtrlLayout.setResolution(resolution);
        }
    }
}
