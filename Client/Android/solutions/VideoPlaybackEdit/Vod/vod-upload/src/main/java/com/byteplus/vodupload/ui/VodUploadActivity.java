// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload.ui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.bytedance.vod.scenekit.utils.UIUtils;
import com.byteplus.vodupload.R;

import java.io.File;

public class VodUploadActivity extends AppCompatActivity {
    private static final String TAG = "VodUploadActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UIUtils.setSystemBarTheme(
                this,
                Color.TRANSPARENT,
                false,
                true,
                Color.TRANSPARENT,
                false,
                true
        );

        setContentView(R.layout.activity_vod_upload);

        if (getSupportFragmentManager()
                .findFragmentById(R.id.vod_upload_container) == null) {
            VodUploadMainFragment fragment = new VodUploadMainFragment();
            getSupportFragmentManager()
                    .beginTransaction()
                    .add(R.id.vod_upload_container, fragment, "upload_main")
                    .commit();
        }
    }

    private void transPreviewFragment(String videoPath) {
        VodUploadPreviewFragment fragment = new VodUploadPreviewFragment();
        Bundle bundle = new Bundle();
        bundle.putCharSequence(VodUploadPreviewFragment.EXTRA_MEDIA_PATH, videoPath);
        fragment.setArguments(bundle);

        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.vod_upload_container, fragment, "upload_preview")
                .commitNow();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == ActivityRequestCode.CKEDITOR_ACTIVITY
                || requestCode == ActivityRequestCode.PREVIEW_ACTIVITY) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                String editCompileVideoPath = data.getStringExtra(ExtraConstants.EXTRA_COMPILE_VIDEO_PATH);
                Log.e(TAG, "onActivityResult editCompileVideoPath : " + editCompileVideoPath);
                if (editCompileVideoPath != null && !editCompileVideoPath.isEmpty()) {
                    //通知本地相册刷新
                    Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
                    intent.setData(Uri.fromFile(new File(editCompileVideoPath)));
                    sendBroadcast(intent);

                    transPreviewFragment(editCompileVideoPath);
                }
            }
        }
    }
}