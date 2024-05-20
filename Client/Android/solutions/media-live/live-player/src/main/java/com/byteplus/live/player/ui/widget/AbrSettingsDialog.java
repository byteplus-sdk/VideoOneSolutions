// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.widget;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.fragment.app.DialogFragment;

import com.byteplus.live.player.R;
import com.byteplus.live.player.ui.activity.InputPullUrlActivity;
import com.byteplus.live.settings.AbrInfo;
import com.byteplus.live.settings.PreferenceUtil;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

public class AbrSettingsDialog extends DialogFragment {

    private SwitchCompat mDefaultSw;
    private RadioGroup mAbrGear;

    private EditText mUrlEd;
    private EditText mBitrateEd;

    public AbrSettingsDialog() {
        super(R.layout.live_dialog_abr_settings);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        Dialog dialog = requireDialog();
        dialog.setCanceledOnTouchOutside(false);

        Bundle arguments = getArguments();
        boolean isMainStream = arguments == null || arguments.getBoolean("extra_is_main_stream", true);

        ImageView close = view.findViewById(R.id.title_bar_left_iv);
        close.setImageResource(R.drawable.live_ic_close_black);
        close.setOnClickListener(v -> dismiss());

        TextView tvTitle = view.findViewById(R.id.title_bar_title_tv);
        tvTitle.setVisibility(View.VISIBLE);
        tvTitle.setText(R.string.medialive_abr_gear_setting);

        mAbrGear = view.findViewById(R.id.abr_gear);
        CompoundButton.OnCheckedChangeListener checkedChangeListener = (button, isChecked) -> {
            if (isChecked) {
                mAbrGear.check(button.getId());
            }
        };
        ((RadioButton) view.findViewById(R.id.abr_gear_origin)).setOnCheckedChangeListener(checkedChangeListener);
        ((RadioButton) view.findViewById(R.id.abr_gear_uhd)).setOnCheckedChangeListener(checkedChangeListener);
        ((RadioButton) view.findViewById(R.id.abr_gear_hd)).setOnCheckedChangeListener(checkedChangeListener);
        ((RadioButton) view.findViewById(R.id.abr_gear_ld)).setOnCheckedChangeListener(checkedChangeListener);
        ((RadioButton) view.findViewById(R.id.abr_gear_sd)).setOnCheckedChangeListener(checkedChangeListener);

        mUrlEd = view.findViewById(R.id.url);
        view.findViewById(R.id.scan).setOnClickListener(v -> scanUrl());

        mBitrateEd = view.findViewById(R.id.bitrate);

        mDefaultSw = view.findViewById(R.id.abr_gear_is_default);
        if (!isMainStream) {
            mDefaultSw.setVisibility(View.INVISIBLE);
        }

        view.findViewById(R.id.tv_add_abr).setOnClickListener(v -> {
            int gearCheckedId = mAbrGear.getCheckedRadioButtonId();
            String url = mUrlEd.getText().toString().trim();
            String bitrateStr = mBitrateEd.getText().toString().trim();
            if (gearCheckedId == -1
                    || TextUtils.isEmpty(url)
                    || TextUtils.isEmpty(bitrateStr)
            ) {
                Toast.makeText(getContext(), R.string.medialive_abr_input_not_complete, Toast.LENGTH_SHORT).show();
                return;
            }

            if (!url.contains(".flv")) {
                Toast.makeText(getContext(), R.string.medialive_pull_abr_only_support_flv, Toast.LENGTH_SHORT).show();
                return;
            }
            int bitrate;
            try {
                bitrate = Integer.parseInt(bitrateStr);
            } catch (NumberFormatException nfe) {
                Toast.makeText(getContext(), R.string.medialive_bitrate_format_error, Toast.LENGTH_SHORT).show();
                return;
            }

            AbrInfo abrInfo = new AbrInfo(
                    url,
                    bitrate);

            if (isMainStream) {
                configMainStream(gearCheckedId, abrInfo);
            } else {
                configBackupStream(gearCheckedId, abrInfo);
            }

            InputPullUrlActivity parent = (InputPullUrlActivity) requireActivity();
            parent.onAbrUrlAdded(isMainStream);
            dismiss();
        });

        String abrDefault = PreferenceUtil.getInstance().getPullAbrDefault("");
        mDefaultSw.setChecked(TextUtils.isEmpty(abrDefault));
    }

    private void configMainStream(int gearId, AbrInfo abrInfo) {
        if (gearId == R.id.abr_gear_origin) {
            PreferenceUtil.getInstance().setPullAbrOrigin(abrInfo.toString());
            if (mDefaultSw.isChecked()) {
                PreferenceUtil.getInstance().setPullAbrDefault(PreferenceUtil.PULL_ABR_ORIGIN);
            }
        } else if (gearId == R.id.abr_gear_uhd) {
            PreferenceUtil.getInstance().setPullAbrUhd(abrInfo.toString());
            if (mDefaultSw.isChecked()) {
                PreferenceUtil.getInstance().setPullAbrDefault(PreferenceUtil.PULL_ABR_UHD);
            }
        } else if (gearId == R.id.abr_gear_hd) {
            PreferenceUtil.getInstance().setPullAbrHd(abrInfo.toString());
            if (mDefaultSw.isChecked()) {
                PreferenceUtil.getInstance().setPullAbrDefault(PreferenceUtil.PULL_ABR_HD);
            }
        } else if (gearId == R.id.abr_gear_ld) {
            PreferenceUtil.getInstance().setPullAbrLd(abrInfo.toString());
            if (mDefaultSw.isChecked()) {
                PreferenceUtil.getInstance().setPullAbrDefault(PreferenceUtil.PULL_ABR_LD);
            }
        } else if (gearId == R.id.abr_gear_sd) {
            PreferenceUtil.getInstance().setPullAbrSd(abrInfo.toString());
            if (mDefaultSw.isChecked()) {
                PreferenceUtil.getInstance().setPullAbrDefault(PreferenceUtil.PULL_ABR_SD);
            }
        }
    }

    private void configBackupStream(int gearId, AbrInfo abrInfo) {
        if (gearId == R.id.abr_gear_origin) {
            PreferenceUtil.getInstance().setPullAbrOriginBackup(abrInfo.toString());
        } else if (gearId == R.id.abr_gear_uhd) {
            PreferenceUtil.getInstance().setPullAbrUhdBackup(abrInfo.toString());
        } else if (gearId == R.id.abr_gear_hd) {
            PreferenceUtil.getInstance().setPullAbrHdBackup(abrInfo.toString());
        } else if (gearId == R.id.abr_gear_ld) {
            PreferenceUtil.getInstance().setPullAbrLdBackup(abrInfo.toString());
        } else if (gearId == R.id.abr_gear_sd) {
            PreferenceUtil.getInstance().setPullAbrSdBackup(abrInfo.toString());
        }
    }

    void scanUrl() {
        IntentIntegrator integrator = new IntentIntegrator(requireActivity());
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
                mUrlEd.setText(url);
            }
        }
    });
}
