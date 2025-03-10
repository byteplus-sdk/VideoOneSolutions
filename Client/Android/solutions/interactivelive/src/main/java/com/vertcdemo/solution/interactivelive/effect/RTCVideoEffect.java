// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.effect;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.ss.bytertc.engine.video.IVideoEffect;
import com.vertcdemo.effect.core.IEffect;

import static com.vertcdemo.effect.core.IEffect.trim;

import com.vertcdemo.effect.ui.OnEffectHandlerUpdatedListener;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class RTCVideoEffect implements IEffect {
    private static final String TAG = "RTCVideoEffect";
    @Nullable
    private final IVideoEffect mVideoEffect;

    private String mLastStickerPath;

    public RTCVideoEffect(@Nullable IVideoEffect videoEffect) {
        this.mVideoEffect = videoEffect;
    }

    @NonNull
    @Override
    public EffectResult enableEffect(@NonNull String licensePath, @NonNull String modelPath) {
        Log.d(TAG, "enableEffect: licensePath='" + trim(licensePath) + "'"
                + ", modelPath='" + trim(modelPath) + "'");
        if (mVideoEffect == null) {
            Log.w(TAG, "No IVideoEffect provided");
            return EffectResult.OK;
        }
        int initResult = mVideoEffect.initCVResource(licensePath, modelPath);
        Log.e(TAG, "enableEffect: initCVResource: code=" + initResult);
        if (initResult != 0) {
            return new EffectResult(initResult, ErrorCodes.str(initResult));
        }
        int enableResult = mVideoEffect.enableVideoEffect();
        Log.e(TAG, "enableEffect: enableVideoEffect: code=" + enableResult);
        if (enableResult != 0) {
            return new EffectResult(enableResult, ErrorCodes.str(enableResult));
        }

        return EffectResult.OK;
    }

    @Override
    public void setEffectNodes(@NonNull List<String> paths) {
        Log.d(TAG, "setEffectNodes: " + Arrays.toString(trim(paths)));
        if (mVideoEffect == null) {
            Log.w(TAG, "No IVideoEffect provided");
            return;
        }
        List<String> tmp = new ArrayList<>(paths);
        if (!TextUtils.isEmpty(mLastStickerPath)) {
            tmp.add(mLastStickerPath);
        }
        mVideoEffect.setEffectNodes(tmp);
    }

    @Override
    public void updateEffectNode(@NonNull String path, @NonNull String key, float value) {
        Log.d(TAG, "updateEffectNode: path='" + trim(path) + "'"
                + ", key='" + key + "'"
                + ", value=" + value
        );
        if (mVideoEffect == null) {
            Log.w(TAG, "No IVideoEffect provided");
            return;
        }

        mVideoEffect.updateEffectNode(path, key, value);
    }

    @Override
    public void setColorFilter(@NonNull String path) {
        Log.d(TAG, "setColorFilter: path='" + trim(path) + "'");
        if (mVideoEffect == null) {
            Log.w(TAG, "No IVideoEffect provided");
            return;
        }

        if (TextUtils.isEmpty(path)) {
            mVideoEffect.setColorFilter("");
        } else {
            mVideoEffect.setColorFilter(path);
        }
    }

    @Override
    public void setColorFilterIntensity(float intensity) {
        Log.d(TAG, "setColorFilterIntensity: intensity=" + intensity);
        if (mVideoEffect == null) {
            Log.w(TAG, "No IVideoEffect provided");
            return;
        }

        mVideoEffect.setColorFilterIntensity(intensity);
    }

    @Override
    public void setSticker(@NonNull String path) {
        Log.d(TAG, "setSticker: path='" + trim(path) + "'");
        if (mVideoEffect == null) {
            Log.w(TAG, "No IVideoEffect provided");
            return;
        }

        if (TextUtils.equals(mLastStickerPath, path)) {
            return;
        }

        if (!TextUtils.isEmpty(mLastStickerPath)) {
            mVideoEffect.removeEffectNodes(Collections.singletonList(mLastStickerPath));
        }
        if (!TextUtils.isEmpty(path)) {
            mVideoEffect.appendEffectNodes(Collections.singletonList(path));
        }
        mLastStickerPath = path;
    }

    @Override
    public void setOnEffectHandlerUpdatedListener(@Nullable OnEffectHandlerUpdatedListener listener) {

    }
}
