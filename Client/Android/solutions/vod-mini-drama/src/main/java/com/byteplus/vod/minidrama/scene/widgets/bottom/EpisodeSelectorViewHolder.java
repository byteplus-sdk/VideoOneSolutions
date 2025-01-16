// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.bottom;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.minidrama.R;

import java.text.DecimalFormat;

public class EpisodeSelectorViewHolder {
    public final View mSelectEpisodeView;
    public final TextView mSelectEpisodeDesc;
    public final TextView mSpeedSelectorView;

    public EpisodeSelectorViewHolder(View view) {
        mSelectEpisodeView = view.findViewById(R.id.bottomBarCardSelectEpisode);
        mSelectEpisodeView.setEnabled(false);
        mSelectEpisodeDesc = (TextView) mSelectEpisodeView;
        mSpeedSelectorView = view.findViewById(R.id.bottomBarCardSpeedSelector);
        mSpeedSelectorView.setEnabled(false);
    }

    public void bind(DramaInfo drama) {
        Resources resources = mSelectEpisodeDesc.getResources();
        mSelectEpisodeDesc.setText(resources.getString(R.string.vevod_mini_drama_video_detail_select_episode_total, drama.totalEpisodeNumber));
        mSelectEpisodeView.setEnabled(true);
    }

    public void setOnClickListener(@Nullable View.OnClickListener listener) {
        mSelectEpisodeView.setOnClickListener(listener);
    }

    public void updatePlaySpeed(float playSpeed) {
        DecimalFormat df = new DecimalFormat("0.0#X");
        mSpeedSelectorView.setText(df.format(playSpeed));
        mSpeedSelectorView.setEnabled(true);
    }

    public void setOnSpeedSelectorClickListener(@Nullable View.OnClickListener listener) {
        mSpeedSelectorView.setOnClickListener(listener);
    }
}
