// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.common.panel;

import android.view.View;
import android.widget.TextView;

import androidx.annotation.StringRes;

import com.byteplus.live.common.R;


class InfoPanel {
    protected final View mRoot;

    protected boolean mEnabled;

    protected InfoPanel(@StringRes int title, View root) {
        mRoot = root;

        TextView titleView = root.findViewById(R.id.title);
        titleView.setText(title);
    }

    public void setEnabled(boolean enabled) {
        this.mEnabled = enabled;
        mRoot.setVisibility(enabled ? View.VISIBLE : View.GONE);
    }

    public boolean isEnabled() {
        return mEnabled;
    }
}
