// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.activity;

import static com.byteplus.live.settings.PreferenceUtil.PULL_FORMAT_FLV;
import static com.byteplus.live.settings.PreferenceUtil.PULL_PROTOCOL_TCP;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.byteplus.live.player.LivePlayer;
import com.byteplus.live.player.R;
import com.byteplus.live.player.ui.widget.AbrSettingsDialog;
import com.byteplus.live.settings.AbrInfo;
import com.byteplus.live.settings.PreferenceUtil;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;


public class InputPullUrlActivity extends AppCompatActivity {
    private static final String TAG = "InputPullUrlActivity";
    private EditText mEditText = null;
    private boolean mIsMainStreamSettings = true;

    private SwitchCompat mAbrSw;
    private SwitchCompat mAutoAbrSw;

    private Spinner mSuggestProtocolSp;
    private Spinner mSuggestFormatSp;
    private SwitchCompat mSeiSw;

    private void initUI() {
        findViewById(com.byteplus.live.common.R.id.title_bar_left_iv).setOnClickListener(v -> finish());

        mEditText = findViewById(R.id.et_input_url);
        mEditText.setText(PreferenceUtil.getInstance().getPullUrl(""));

        View groupScanUrl = findViewById(R.id.group_input_url_scan);
        View groupAbrSetting = findViewById(R.id.group_abr_setting);

        mAbrSw = findViewById(R.id.abr);
        mAbrSw.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                groupScanUrl.setVisibility(View.INVISIBLE);
                groupAbrSetting.setVisibility(View.VISIBLE);
                mEditText.setEnabled(false);
                if (mIsMainStreamSettings) {
                    mEditText.setText(getMainAbrInfoStr());
                } else {
                    mEditText.setText(getBackupAbrInfoStr());
                }
            } else {
                groupScanUrl.setVisibility(View.VISIBLE);
                groupAbrSetting.setVisibility(View.INVISIBLE);
                mEditText.setEnabled(true);
                if (mIsMainStreamSettings) {
                    mEditText.setText(PreferenceUtil.getInstance().getPullUrl(""));
                } else {
                    mEditText.setText(PreferenceUtil.getInstance().getPullUrlBackup(""));
                }
                if (mAutoAbrSw != null) {
                    mAutoAbrSw.setChecked(false);
                }
            }
        });
        mAbrSw.setChecked(PreferenceUtil.getInstance().getPullAbr(false));

        mAutoAbrSw = findViewById(R.id.abr_auto_switch);
        mAutoAbrSw.setChecked(PreferenceUtil.getInstance().getPullAutoAbr(false));
        mAutoAbrSw.setOnCheckedChangeListener((button, isChecked) -> {
            if (isChecked) {
                if (!mAbrSw.isChecked()) {
                    mAutoAbrSw.setChecked(false);
                    Toast.makeText(InputPullUrlActivity.this, R.string.medialive_open_abr_toast, Toast.LENGTH_SHORT).show();
                }
            }
        });

        mSeiSw = findViewById(R.id.sei);
        mSeiSw.setChecked(PreferenceUtil.getInstance().getPullSei(false));

        mSuggestProtocolSp = findViewById(R.id.protocol);
        {
            String[] items = getResources().getStringArray(R.array.live_protocols);
            ArrayAdapter<String> spinnerAdapter = new ArrayAdapter<>(this, com.byteplus.live.common.R.layout.live_item_select, items);
            spinnerAdapter.setDropDownViewResource(com.byteplus.live.common.R.layout.live_item_drop);
            mSuggestProtocolSp.setAdapter(spinnerAdapter);
        }
        mSuggestProtocolSp.setSelection(PreferenceUtil.getInstance().getPullProtocol(PULL_PROTOCOL_TCP));

        mSuggestFormatSp = findViewById(R.id.format);
        {
            String[] items = getResources().getStringArray(R.array.live_formats);
            ArrayAdapter<String> spinnerAdapter = new ArrayAdapter<>(this, com.byteplus.live.common.R.layout.live_item_select, items);
            spinnerAdapter.setDropDownViewResource(com.byteplus.live.common.R.layout.live_item_drop);
            mSuggestFormatSp.setAdapter(spinnerAdapter);
        }
        mSuggestFormatSp.setSelection(PreferenceUtil.getInstance().getPullFormat(PULL_FORMAT_FLV));

        findViewById(R.id.tv_add_abr).setOnClickListener(v -> {
            AbrSettingsDialog dialog = new AbrSettingsDialog();
            Bundle args = new Bundle();
            args.putBoolean("extra_is_main_stream", mIsMainStreamSettings);
            dialog.setArguments(args);
            dialog.show(getSupportFragmentManager(), "add_abr_url_dialog");
        });
        findViewById(R.id.tv_clear_abr).setOnClickListener(v -> {
            PreferenceUtil.getInstance().clearAbr();
            mEditText.setText("");
        });

        TextView versionTv = findViewById(R.id.tv_liveplayer_version);
        versionTv.setText(getString(R.string.medialive_player_version_xxx, LivePlayer.getVersion()));

        findViewById(R.id.tv_entrance).setOnClickListener(v -> {
            if (saveSettings()) {
                Intent intent = new Intent(InputPullUrlActivity.this, LivePullActivity.class);
                intent.putExtra("pull_url", mEditText.getText().toString());
                startActivity(intent);
            }
        });

        groupScanUrl.setOnClickListener(v -> scanUrl());
    }

    public void onAbrUrlAdded(boolean main) {
        if (main) {
            mEditText.setText(getMainAbrInfoStr());
        } else {
            mEditText.setText(getBackupAbrInfoStr());
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Window window = getWindow();
        WindowCompat.setDecorFitsSystemWindows(window, false);
        WindowInsetsControllerCompat insetsController = WindowCompat.getInsetsController(window, findViewById(android.R.id.content));
        insetsController.setAppearanceLightStatusBars(true);
        insetsController.setAppearanceLightNavigationBars(true);

        setContentView(R.layout.live_activity_url_input);

        View root = findViewById(R.id.root);
        ViewCompat.setOnApplyWindowInsetsListener(root,
                (view, windowInsets) -> {
                    Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                    root.setPadding(insets.left, insets.top, insets.right, insets.bottom);
                    return WindowInsetsCompat.CONSUMED;
                }
        );

        initUI();
    }

    private boolean saveSettings() {
        if (mAbrSw != null) {
            PreferenceUtil.getInstance().setPullAbr(mAbrSw.isChecked());
        }

        if (mAbrSw == null || !mAbrSw.isChecked()) {
            if (mIsMainStreamSettings) {
                PreferenceUtil.getInstance().setPullUrl(mEditText.getText().toString());
            } else {
                PreferenceUtil.getInstance().setPullUrlBackup(mEditText.getText().toString());
            }
        }

        if (mAutoAbrSw != null) {
            PreferenceUtil.getInstance().setPullAutoAbr(mAutoAbrSw.isChecked());
        }
        if (mSeiSw != null) {
            PreferenceUtil.getInstance().setPullSei(mSeiSw.isChecked());
        }

        if (mSuggestFormatSp != null) {
            PreferenceUtil.getInstance().setPullFormat(mSuggestFormatSp.getSelectedItemPosition());
        }

        if (mSuggestProtocolSp != null) {
            PreferenceUtil.getInstance().setPullProtocol(mSuggestProtocolSp.getSelectedItemPosition());
        }
        return true;
    }

    private static String getAbrInfoStr(String resolution, String abrJsonStr) {
        if (!TextUtils.isEmpty(abrJsonStr)) {
            AbrInfo abrInfo = AbrInfo.json2AbrInfo(abrJsonStr);
            return resolution +
                    ": Bitrate= " + abrInfo.mBitrate +
                    "\n";
        } else {
            return "";
        }
    }

    private static String getMainAbrInfoStr() {
        PreferenceUtil prefs = PreferenceUtil.getInstance();
        return getAbrInfoStr("Origin", prefs.getPullAbrOrigin(""))
                + getAbrInfoStr("UHD", prefs.getPullAbrUhd(""))
                + getAbrInfoStr("HD", prefs.getPullAbrHd(""))
                + getAbrInfoStr("LD", prefs.getPullAbrLd(""))
                + getAbrInfoStr("SD", prefs.getPullAbrSd(""));
    }

    private static String getBackupAbrInfoStr() {
        PreferenceUtil prefs = PreferenceUtil.getInstance();
        return getAbrInfoStr("Origin", prefs.getPullAbrOriginBackup(""))
                + getAbrInfoStr("UHD", prefs.getPullAbrUhdBackup(""))
                + getAbrInfoStr("HD", prefs.getPullAbrHdBackup(""))
                + getAbrInfoStr("LD", prefs.getPullAbrLdBackup(""))
                + getAbrInfoStr("SD", prefs.getPullAbrSdBackup(""));
    }

    void scanUrl() {
        IntentIntegrator integrator = new IntentIntegrator(this);
        integrator.setOrientationLocked(false);
        integrator.createScanIntent();
        scanLauncher.launch(integrator.createScanIntent());
    }

    final ActivityResultLauncher<Intent> scanLauncher = registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), new ActivityResultCallback<ActivityResult>() {
        @Override
        public void onActivityResult(ActivityResult result) {
            IntentResult scanResult = IntentIntegrator.parseActivityResult(result.getResultCode(), result.getData());
            String url = scanResult.getContents();
            if (url != null) {
                Log.i(TAG, "Find url " + url + " from scanner.");
                mEditText.setText(url);
            }
        }
    });
}
