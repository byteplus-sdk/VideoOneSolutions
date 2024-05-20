// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.entrance;


import static com.pandora.common.env.config.LogConfig.LogLevel.Debug;

import android.Manifest;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.byteplus.live.pusher.MediaResourceMgr;
import com.pandora.common.applog.AppLogWrapper;
import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;
import com.pandora.common.env.config.LogConfig;
import com.pandora.common.globalsettings.GlobalSdkParams;
import com.pandora.ttlicense2.LicenseManager;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class UIMainActivity extends AppCompatActivity {

    public static final String ACTION_MEDIA_LIVE_PUSH = "com.byteplus.videoone.medialive.action.LIVE_PUSH";
    public static final String ACTION_MEDIA_LIVE_PULL = "com.byteplus.videoone.medialive.action.MEDIA_LIVE_PULL";

    private static final String TAG = "UIMainActivity";

    private static boolean mIsResourceReady = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Window window = getWindow();
        WindowCompat.setDecorFitsSystemWindows(window, false);
        WindowInsetsControllerCompat insetsController = WindowCompat.getInsetsController(window, findViewById(android.R.id.content));
        insetsController.setAppearanceLightStatusBars(true);
        insetsController.setAppearanceLightNavigationBars(true);

        setContentView(R.layout.live_activity_entrance);
        View root = findViewById(R.id.root);
        ViewCompat.setOnApplyWindowInsetsListener(root,
                (view, windowInsets) -> {
                    Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                    root.setPadding(insets.left, insets.top, insets.right, insets.bottom);
                    return WindowInsetsCompat.CONSUMED;
                }
        );

        initUI();
        checkPermission();
        initTTSDK();
        if (!mIsResourceReady) {
            new Thread(() -> {
                prepareExternalMediaResource();
                prepareEffectResource();
                mIsResourceReady = true;
            }).start();
        }

        showBuildInfo();
    }

    private void initUI() {
        TextView titleView = findViewById(R.id.title_bar_title_tv);
        titleView.setVisibility(View.VISIBLE);
        titleView.setText(R.string.medialive_navbar_title);

        findViewById(R.id.title_bar_left_iv)
                .setOnClickListener(v -> finish());

        ((TextView) findViewById(R.id.tv_sdk_version)).setText(
                getString(R.string.ttsdk_version_xxx, Env.getVersion()));

        findViewById(R.id.push).setOnClickListener(v -> {
            if (!mIsResourceReady) {
                Toast.makeText(UIMainActivity.this, "Loading resource...", Toast.LENGTH_SHORT).show();
                return;
            }

            Intent intent = new Intent(ACTION_MEDIA_LIVE_PUSH);
            intent.setPackage(getPackageName());
            try {
                startActivity(intent);
            } catch (ActivityNotFoundException anfe) {
                Toast.makeText(UIMainActivity.this, "No implement: ACTION_MEDIA_LIVE_PUSH", Toast.LENGTH_LONG).show();
            }
        });

        findViewById(R.id.pull).setOnClickListener(v -> {
            Intent intent = new Intent(ACTION_MEDIA_LIVE_PULL);
            intent.setPackage(getPackageName());
            try {
                startActivity(intent);
            } catch (ActivityNotFoundException anfe) {
                Toast.makeText(UIMainActivity.this, "No implement: ACTION_MEDIA_LIVE_PULL", Toast.LENGTH_LONG).show();
            }
        });
    }

    private void prepareExternalMediaResource() {
        MediaResourceMgr.prepare(this);
    }

    private void prepareEffectResource() {
    }

    public void initTTSDK() {
        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_APP_ID)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_APP_ID in gradle.properties!");
        }

        if (TextUtils.isEmpty(BuildConfig.LIVE_TTSDK_LICENSE_URI)) {
            throw new RuntimeException("Please setup LIVE_TTSDK_LICENSE_URI in gradle.properties!");
        }

        Context context = getApplicationContext();
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
    }

    final ActivityResultLauncher<String[]> requestPermissionsLauncher = registerForActivityResult(
            new ActivityResultContracts.RequestMultiplePermissions(),
            results -> {

            });

    private void checkPermission() {
        String[] permissions = new String[]{
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.MODIFY_AUDIO_SETTINGS,
                Manifest.permission.ACCESS_NETWORK_STATE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
        };

        List<String> permissionList = new ArrayList<>();
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                permissionList.add(permission);
            }
        }
        if (permissionList.isEmpty()) {
            return;
        }
        requestPermissionsLauncher.launch(permissionList.toArray(new String[0]));
    }

    public String getMetaData(String key) {
        try {
            ApplicationInfo appInfo = getPackageManager().getApplicationInfo(
                    getPackageName(), PackageManager.GET_META_DATA);
            String value = appInfo.metaData.getString(key);
            return value == null ? "" : value;
        } catch (PackageManager.NameNotFoundException e) {
            Log.d(TAG, "getMetaData failed.", e);
        }

        return "";
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
