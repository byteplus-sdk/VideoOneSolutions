// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.byteplus.minidrama.R;

public class DramaLoadingDialog extends DialogFragment {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCancelable(false);
        setStyle(STYLE_NO_TITLE, R.style.VeVodMiniDramaProgressDialog);
    }

    public DramaLoadingDialog() {
        super(R.layout.vevod_mini_drama_loading_dialog);
    }
}
