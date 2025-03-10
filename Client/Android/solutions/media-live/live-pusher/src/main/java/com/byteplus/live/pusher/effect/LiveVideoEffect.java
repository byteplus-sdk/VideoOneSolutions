// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher.effect;

import static com.vertcdemo.effect.core.IEffect.trim;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.live.VeLiveVideoEffectManager;
import com.vertcdemo.effect.core.IEffect;
import com.vertcdemo.effect.ui.EffectHandlerUpdatePolicy;
import com.vertcdemo.effect.ui.OnEffectHandlerUpdatedListener;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class LiveVideoEffect implements IEffect {
    private static final String TAG = "LiveVideoEffect";

    private static final EffectHandlerUpdatePolicy UPDATE_POLICY = EffectHandlerUpdatePolicy.DISCARD;

    @Nullable
    private VeLiveVideoEffectManager mEffectManager;
    @Nullable
    private String mLastStickerPath = "";

    @Nullable
    OnEffectHandlerUpdatedListener onEffectHandlerUpdatedListener;

    public LiveVideoEffect(@Nullable VeLiveVideoEffectManager effectManager) {
        mEffectManager = effectManager;
    }

    public void setOnEffectHandlerUpdatedListener(@Nullable OnEffectHandlerUpdatedListener listener) {
        this.onEffectHandlerUpdatedListener = listener;
    }

    public void setEffectManager(@Nullable VeLiveVideoEffectManager effectManager) {
        Log.d(TAG, "setEffectManager: ");
        mEffectManager = effectManager;
        mLastStickerPath = "";
        OnEffectHandlerUpdatedListener listener = onEffectHandlerUpdatedListener;
        if (listener != null) {
            listener.onEffectHandlerUpdated(UPDATE_POLICY);
        }
    }

    private final VeLivePusherDef.VeLiveVideoEffectCallback mCallback = new VeLivePusherDef.VeLiveVideoEffectCallback() {
        @Override
        public void onResult(int result, String message) {
            Log.d(TAG, "Callback: result=" + result + "; message=" + message);
        }
    };

    @NonNull
    @Override
    public EffectResult enableEffect(@NonNull String licensePath, @NonNull String modelPath) {
        Log.d(TAG, "enableEffect: licensePath='" + trim(licensePath) + "'"
                + ", modelPath='" + trim(modelPath) + "'");
        VeLiveVideoEffectManager manager = mEffectManager;
        if (manager == null) {
            return EffectResult.OK;
        }

        int setupResult = manager.setupWithConfig(VeLivePusherDef.VeLiveVideoEffectLicenseConfiguration.create(licensePath));
        Log.e(TAG, "enableEffect: setupWithConfig=" + setupResult);
        if (setupResult != 0) {
            return new EffectResult(setupResult, "setupWithConfig error(" + setupResult + ")");
        }
        int setModelPathResult = manager.setAlgorithmModelPath(modelPath);
        Log.e(TAG, "enableEffect: setAlgorithmModelPath=" + setModelPathResult);
        if (setModelPathResult != 0) {
            return new EffectResult(setModelPathResult, "setAlgorithmModelPath error(" + setModelPathResult + ")");
        }
        manager.setEnable(true, mCallback);
        return EffectResult.OK;
    }

    @Override
    public void setEffectNodes(@NonNull List<String> paths) {
        Log.d(TAG, "setEffectNodes: " + Arrays.toString(trim(paths)));
        VeLiveVideoEffectManager manager = mEffectManager;
        if (manager == null) {
            return;
        }

        List<String> items = new ArrayList<>(paths);
        if (!TextUtils.isEmpty(mLastStickerPath)) {
            items.add(mLastStickerPath);
        }
        manager.setComposeNodes(items.toArray(new String[0]));
    }

    @Override
    public void updateEffectNode(@NonNull String path, @NonNull String key, float value) {
        Log.d(TAG, "updateEffectNode: path='" + trim(path) + "'"
                + ", key='" + key + "'"
                + ", value=" + value
        );
        VeLiveVideoEffectManager manager = mEffectManager;
        if (manager == null) {
            return;
        }

        manager.updateComposerNodeIntensity(path, key, value);
    }

    @Override
    public void setColorFilter(@NonNull String path) {
        Log.d(TAG, "setColorFilter: path='" + trim(path) + "'");
        VeLiveVideoEffectManager manager = mEffectManager;
        if (manager == null) {
            return;
        }

        if (TextUtils.isEmpty(path)) {
            manager.setFilter("");
        } else {
            manager.setFilter(path);
        }
    }

    @Override
    public void setColorFilterIntensity(float intensity) {
        Log.d(TAG, "setColorFilterIntensity: intensity=" + intensity);
        VeLiveVideoEffectManager manager = mEffectManager;
        if (manager == null) {
            return;
        }

        manager.updateFilterIntensity(intensity);
    }

    @Override
    public void setSticker(@NonNull String path) {
        Log.d(TAG, "setSticker: path='" + trim(path) + "'");
        VeLiveVideoEffectManager manager = mEffectManager;
        if (manager == null) {
            return;
        }

        if (TextUtils.equals(mLastStickerPath, path)) {
            return;
        }
        if (!TextUtils.isEmpty(mLastStickerPath)) {
            manager.removeComposeNodes(new String[]{mLastStickerPath});
        }
        if (!TextUtils.isEmpty(path)) {
            manager.appendComposeNodes(new String[]{path});
        }
        mLastStickerPath = path;
    }
}
