// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.pay;

import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.Guideline;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.byteplus.minidrama.R;
import com.byteplus.vod.scenekit.utils.UIUtils;

public class DramaEpisodeMockAdActivity extends AppCompatActivity {
    private static final String MOCK_AD_RESOURCE = "https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/ad.gif";

    private Handler handler;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        UIUtils.setSystemBarTheme(
                this,
                Color.TRANSPARENT,
                false,
                true,
                Color.TRANSPARENT,
                true,
                true
        );

        setContentView(R.layout.vevod_mini_drama_episode_mock_ad_activity);

        Guideline guidelineTop = findViewById(R.id.guideline_top);
        ViewCompat.setOnApplyWindowInsetsListener(guidelineTop, (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.statusBars());
            guidelineTop.setGuidelineBegin(insets.top);
            return WindowInsetsCompat.CONSUMED;
        });

        ImageView adView = findViewById(R.id.ad_view);
        Glide.with(adView)
                .load(MOCK_AD_RESOURCE)
                .diskCacheStrategy(DiskCacheStrategy.NONE)
                .error(R.drawable.vevod_mini_drama_cover_demo)
                .into(adView);

        View countDown = findViewById(R.id.count_down);
        countDown.setEnabled(false);
        countDown.setOnClickListener(v -> {
            setResult(RESULT_OK);
            finish();
        });

        TextView timeView = findViewById(R.id.time);
        View closeView = findViewById(R.id.close);

        handler = new Handler(Looper.getMainLooper(), msg -> {
            int time = msg.arg1;
            if (time <= 0) {
                closeView.setVisibility(View.VISIBLE);
                timeView.setVisibility(View.GONE);
                countDown.setEnabled(true);
            } else {
                timeView.setText(getString(R.string.vevod_mini_drama_x_seconds, time));
                Message next = handler.obtainMessage(0, time - 1, 0);
                handler.sendMessageDelayed(next, 1000);
            }
            return true;
        });

        handler.obtainMessage(0, 10, 0)
                .sendToTarget();

        getOnBackPressedDispatcher().addCallback(new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                if (countDown.isEnabled()) {
                    setResult(RESULT_OK);
                }
                finish();
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }
}
