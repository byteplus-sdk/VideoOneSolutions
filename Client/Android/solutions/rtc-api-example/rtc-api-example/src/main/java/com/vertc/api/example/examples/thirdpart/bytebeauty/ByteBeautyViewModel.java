package com.vertc.api.example.examples.thirdpart.bytebeauty;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.util.Pair;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.ss.bytertc.engine.video.IVideoEffect;
import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectSection;

import java.util.List;
import java.util.Objects;

public class ByteBeautyViewModel extends ViewModel {
    private static final String TAG = "ByteBeauty";

    private IVideoEffect videoEffect;

    private EffectResourceManager resourceManager;

    @NonNull
    public IVideoEffect requireVideoEffect() {
        return Objects.requireNonNull(videoEffect);
    }

    public EffectResourceManager requireResourceManager() {
        return Objects.requireNonNull(resourceManager);
    }

    /**
     * Used to monitor Sticker select state between EffectSections
     */
    public MutableLiveData<Pair<EffectSection, String>> currentSticker = new MutableLiveData<>();

    public void init(IVideoEffect videoEffect, EffectResourceManager resourceManager) {
        this.videoEffect = videoEffect;
        this.resourceManager = resourceManager;
        resourceManager.initVideoEffectResource(() -> {
            String licPath = resourceManager.getLicensePath();
            String modelPath = resourceManager.getModelPath();

            { // Setup License & Model
                int retValue = videoEffect.initCVResource(licPath, modelPath);
                Log.i(TAG, "[ByteBeautyViewModel] initCVResource: result=" + retValue);
            }

            { // Enable VideoEffect
                int retValue = videoEffect.enableVideoEffect();
                Log.i(TAG, "[ByteBeautyViewModel] enableVideoEffect: result=" + retValue);
            }

            { // Init basic nodes
                List<String> effectNodePaths = resourceManager.basicEffectNodePaths();
                int retValue = videoEffect.setEffectNodes(effectNodePaths);
                Log.i(TAG, "[ByteBeautyViewModel] setVideoEffectNodes: result=" + retValue);
            }
        });
    }
}
