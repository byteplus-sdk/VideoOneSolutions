// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveResponse;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.databinding.DialogLiveEndCoAudienceBinding;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkKickResultEvent;
import com.videoone.avatars.Avatars;

public class EndCoAudienceDialog extends DialogFragment {

    @Override
    public int getTheme() {
        return R.style.LiveCommonDialogTheme;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_live_end_co_audience, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        final Bundle arguments = requireArguments();
        final String roomId = arguments.getString("roomId");
        final String hostId = arguments.getString("hostId");
        final String audienceId = arguments.getString("audienceId");
        final String audienceName = arguments.getString("audienceName");

        DialogLiveEndCoAudienceBinding binding = DialogLiveEndCoAudienceBinding.bind(view);
        binding.userName.setText(audienceName);

        Glide.with(binding.userAvatar)
                .load(Avatars.byUserId(audienceId))
                .into(binding.userAvatar);

        binding.button1.setOnClickListener(v -> {
            dismiss();
            IRequestCallback<LiveResponse> callback = o -> SolutionEventBus.post(new AudienceLinkKickResultEvent(audienceId));
            LiveRTCManager.ins().getRTSClient().kickAudienceByHost(
                    roomId, hostId,
                    roomId, audienceId,
                    callback);
        });

        binding.button2.setOnClickListener(v -> dismiss());
    }
}
