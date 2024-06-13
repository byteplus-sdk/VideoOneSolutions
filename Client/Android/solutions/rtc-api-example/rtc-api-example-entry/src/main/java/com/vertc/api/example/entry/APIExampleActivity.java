// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertc.api.example.entry;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;

import com.vertcdemo.core.utils.Activities;

public class APIExampleActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Activities.transparentStatusBar(this);

        setContentView(R.layout.activity_api_example);

        WindowCompat.getInsetsController(getWindow(), findViewById(R.id.content))
                .setAppearanceLightStatusBars(true);
    }
}
