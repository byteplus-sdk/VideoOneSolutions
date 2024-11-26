// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.vod.function;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.byteplus.vod.scenekit.ui.base.BaseActivity;
import com.videoone.vod.function.fragment.PlaylistFragment;
import com.videoone.vod.function.fragment.PreventRecordingFragment;
import com.videoone.vod.function.fragment.SubtitleFragment;
import com.videoone.vod.function.fragment.VodFunctionFragment;

public class VodFunctionActivity extends BaseActivity {
    private static final String TAG = "VodFunction";
    public static final String EXTRA_VIDEO_ITEM = "extra_video_item";

    public static final String EXTRA_VIDEO_LIST = "extra_video_list";

    public static final String EXTRA_PLAY_MODE = "extra_play_mode";

    public static final String EXTRA_FUNCTION = "extra_function";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FragmentManager manager = getSupportFragmentManager();
        Fragment fragment = manager.findFragmentByTag("single-function-fragment");
        if (fragment == null) {
            Intent intent = getIntent();
            Function function = (Function) intent.getSerializableExtra(EXTRA_FUNCTION);
            assert function != null : "No function provided";

            switch (function) {
                case VIDEO_PLAYBACK: {
                    fragment = new VodFunctionFragment();
                    fragment.setArguments(intent.getExtras());
                    break;
                }
                case SMART_SUBTITLES: {
                    fragment = new SubtitleFragment();
                    fragment.setArguments(intent.getExtras());
                    break;
                }
                case PREVENT_RECORDING: {
                    fragment = new PreventRecordingFragment();
                    fragment.setArguments(intent.getExtras());
                    break;
                }
                case PLAYLIST: {
                    fragment = new PlaylistFragment();
                    fragment.setArguments(intent.getExtras());
                    break;
                }
                default:
                    finish();
                    Log.d(TAG, "Unsupported function: " + function);
                    return;
            }

            manager.beginTransaction()
                    .add(android.R.id.content, fragment, "single-function-fragment")
                    .commit();

        }
    }
}
