// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.entrance;

import static com.pandora.common.env.config.LogConfig.LogLevel.Debug;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.byteplus.live.player.ui.activity.InputPullUrlActivity;
import com.byteplus.live.pusher.ui.activities.LiveCaptureType;
import com.byteplus.live.pusher.ui.activities.LivePushActivity;
import com.pandora.common.applog.AppLogWrapper;
import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;
import com.pandora.common.env.config.LogConfig;
import com.pandora.common.globalsettings.GlobalSdkParams;
import com.pandora.ttlicense2.LicenseManager;

import org.json.JSONObject;

import java.util.Arrays;
import java.util.Objects;

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
        mViewModel.prepareResource(requireContext());
        initTTSDK();
    }

    public void initTTSDK() {
        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_APP_ID)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_APP_ID in gradle.properties!");
        }

        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_LICENSE_URI)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_LICENSE_URI in gradle.properties!");
        }

        Context context = requireContext().getApplicationContext();
        Env.openDebugLog(true);
        Env.openAppLog(true);
        LicenseManager.turnOnLogcat(true);
        String logPath = Objects.requireNonNull(context.getExternalFilesDir("TTSDK")).getAbsolutePath();
        LogConfig config = new LogConfig.Builder(context)
                .setLogPath(logPath)
                .setLogLevel(Debug)
                .build();
        Env.init(new Config.Builder()
                .setApplicationContext(context)
                .setAppID(BuildConfig.LIVE_TTSDK_APP_ID)
                .setAppName(BuildConfig.LIVE_TTSDK_APP_NAME)
                .setAppChannel(BuildConfig.LIVE_TTSDK_APP_CHANNEL)
                .setLicenseUri(BuildConfig.LIVE_TTSDK_LICENSE_URI)
                .setLicenseCallback(new LogLicenseManagerCallback())
                .setLogConfig(config)
                .build());
        showBuildInfo();
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

    private static void showBuildInfo() {
        Log.d(TAG, "[showBuildInfo] " + "TTSDK: " + Env.getVersion() +
                "\n  Flavor: " + Env.getFlavor() +
                "\n  BuildType: " + Env.getBuildType() +
                "\n  VersionCode: " + Env.getVersionCode() +
                "\n  AppID: " + Env.getAppID() +
                "\n  DeviceId: " + AppLogWrapper.getDid() +
                "\n  UUID: " + AppLogWrapper.getUserUniqueID() +
                "\n  License 2.0 is open");
    }

    static {
        GlobalSdkParams.getInstance().addListener(msg -> {
            JSONObject settings = GlobalSdkParams.getInstance().getSettings();
            Log.d(TAG, "[GlobalSdkParams] Notify msg: " + msg);
            Log.d(TAG, "[GlobalSdkParams] Settings update: " + settings);
        });
    }
}
