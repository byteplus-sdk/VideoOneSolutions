// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload.widget;

import android.app.Dialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.byteplus.vodupload.R;

public class ProgressDialog extends Dialog {

    private TextView mTextView;

    public ProgressDialog(@NonNull Context context) {
        super(context, R.style.VodProgressDialog);
        setContentView(R.layout.dialog_vod_progress);
        mTextView = findViewById(R.id.progress_tv);
    }

    public void setProgressText(CharSequence txt) {
        mTextView.setVisibility(TextUtils.isEmpty(txt) ? View.GONE : View.VISIBLE);
        mTextView.setText(txt);
    }
}
