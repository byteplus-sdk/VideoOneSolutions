// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.entrance;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.byteplus.live.player.ui.activity.InputPullUrlActivity;
import com.byteplus.live.pusher.ui.activities.LiveCaptureType;
import com.byteplus.live.pusher.ui.activities.LivePushActivity;
import com.pandora.common.globalsettings.GlobalSdkParams;

import org.json.JSONObject;

import java.util.Arrays;

public class MediaLiveFunctionFragment extends PermissionFragment {

    private static final String TAG = "MediaLiveFunction";

    private MediaLiveViewModel mViewModel;

    public MediaLiveFunctionFragment() {
        super(R.layout.fragment_medialive_function);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(MediaLiveViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // Live stream pushing
        // Camera
        view.findViewById(R.id.live_push_camera).setOnClickListener(v -> {
            startLivePushPage(requireContext(), LiveCaptureType.CAMERA);
        });
        // Voice & black frames/pictures
        view.findViewById(R.id.live_push_audio).setOnClickListener(v -> {
            startLivePushPage(requireContext(), LiveCaptureType.AUDIO);
        });
        // Screen
        view.findViewById(R.id.live_push_screen).setOnClickListener(v -> {
            startLivePushPage(requireContext(), LiveCaptureType.SCREEN);
        });
        // Video file
        view.findViewById(R.id.live_push_file).setOnClickListener(v -> {
            startLivePushPage(requireContext(), LiveCaptureType.FILE);
        });

        // Live stream pulling

        // Pull stream
        view.findViewById(R.id.live_pull).setOnClickListener(v -> {
            askForPermission(
                    Arrays.asList(Manifest.permission.CAMERA, Manifest.permission.CAMERA),
                    () -> startActivity(new Intent(requireContext(), InputPullUrlActivity.class)),
                    () -> Toast.makeText(requireContext(), "Missing required permission(s)", Toast.LENGTH_LONG).show()
            );
        });

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

    private void startLivePushPage(Context context, @LiveCaptureType int liveCaptureType) {
        askForPermission(
                Arrays.asList(Manifest.permission.CAMERA, Manifest.permission.CAMERA),
                () -> startLivePushPageImpl(context, liveCaptureType),
                () -> Toast.makeText(context, "Missing required permission(s)", Toast.LENGTH_LONG).show()
        );
    }

    private void startLivePushPageImpl(Context context, @LiveCaptureType int liveCaptureType) {
        if (!mViewModel.isResourceReady()) {
            Toast.makeText(context, "Loading resource...", Toast.LENGTH_SHORT).show();
            return;
        }

        Intent intent = new Intent(context, LivePushActivity.class);
        intent.putExtra(LivePushActivity.EXTRA_CAPTURE_TYPE, liveCaptureType);
        context.startActivity(intent);
    }

    static {
        GlobalSdkParams.getInstance().addListener(msg -> {
            JSONObject settings = GlobalSdkParams.getInstance().getSettings();
            Log.d(TAG, "[GlobalSdkParams] Notify msg: " + msg);
            Log.d(TAG, "[GlobalSdkParams] Settings update: " + settings);
        });
    }
}
