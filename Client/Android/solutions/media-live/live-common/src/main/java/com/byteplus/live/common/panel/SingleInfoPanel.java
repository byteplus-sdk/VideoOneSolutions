// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common.panel;

import android.view.View;
import android.widget.TextView;

import androidx.annotation.MainThread;
import androidx.annotation.StringRes;

import com.byteplus.live.common.R;

@MainThread
public class SingleInfoPanel extends InfoPanel {
    private final TextView mContentView;

    public SingleInfoPanel(@StringRes int title, View root) {
        super(title, root);
        mContentView = root.findViewById(R.id.content);
    }

    public void updateContent(String content) {
        if (!isEnabled()) {
            return;
        }
        mContentView.setText(content);
    }

    public void setEnabled(boolean enabled) {
        super.setEnabled(enabled);
        if (!enabled) {
            mContentView.setText("");
        }
    }
}
