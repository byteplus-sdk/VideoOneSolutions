package com.vertc.api.example.examples.video.customcapture;

import android.content.Context;
import android.util.Log;
import android.util.Size;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import com.google.common.util.concurrent.ListenableFuture;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;

public class CameraHelper {
    private static final String TAG = "CameraHelper";

    private static final CameraSelector CAMERA = CameraSelector.DEFAULT_BACK_CAMERA;
    private static final Size BOUND_SIZE = new Size(1280, 720);

    private final ImageAnalysis analysis;

    public CameraHelper(
            @ImageAnalysis.OutputImageFormat int outputFormat,
            @NonNull Executor executor,
            @NonNull ImageAnalysis.Analyzer analyzer
    ) {
        analysis = new ImageAnalysis.Builder()
                .setOutputImageFormat(outputFormat)
                .setResolutionSelector(new ResolutionSelector.Builder()
                        .setResolutionStrategy(
                                new ResolutionStrategy(
                                        BOUND_SIZE,
                                        ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER)
                        )
                        .build())
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build();

        analysis.setAnalyzer(executor, analyzer);
    }

    public void bind(AppCompatActivity activity) {
        bind(activity, activity);
    }

    public void bind(Context context, LifecycleOwner lifecycleOwner) {
        ListenableFuture<ProcessCameraProvider> future = ProcessCameraProvider.getInstance(context);
        future.addListener(() -> {
            try {
                ProcessCameraProvider provider = future.get();
                if (provider.isBound(analysis)) {
                    Log.d(TAG, "bind: already bound");
                    return;
                }
                provider.bindToLifecycle(lifecycleOwner, CAMERA, analysis);
            } catch (ExecutionException | InterruptedException e) {
                throw new RuntimeException(e);
            }
        }, ContextCompat.getMainExecutor(context));
    }

    public void unbind(Context context) {
        ListenableFuture<ProcessCameraProvider> future = ProcessCameraProvider.getInstance(context);
        future.addListener(() -> {
            try {
                ProcessCameraProvider provider = future.get();
                if (provider.isBound(analysis)) {
                    provider.unbind(analysis);
                } else {
                    Log.d(TAG, "unbind: not bound");
                }
            } catch (ExecutionException | InterruptedException e) {
                throw new RuntimeException(e);
            }
        }, ContextCompat.getMainExecutor(context));
    }
}
