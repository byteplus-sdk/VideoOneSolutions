package com.vertc.api.example.base;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.util.Consumer;

import com.vertc.api.example.utils.ExampleExecutor;

import java.security.SecureRandom;
import java.util.Random;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

public class ExampleBaseActivity extends AppCompatActivity {
    private static final Random random = new SecureRandom();

    protected final String localUid = "user_" + random.nextInt(1000);

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED
                    || ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                launcher.launch(new String[]{
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.CAMERA
                });
            }
        }
    }

    private ProgressDialogFragment mLoadingDialog;

    protected void showLoadingDialog() {
        if (mLoadingDialog == null) {
            mLoadingDialog = new ProgressDialogFragment();
        }

        mLoadingDialog.show(getSupportFragmentManager(), "loading");
    }

    public void dismissLoadingDialog() {
        if (mLoadingDialog != null) {
            mLoadingDialog.dismiss();
        }
    }

    private final ActivityResultLauncher<String[]> launcher =
            registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(), results -> {

            });

    @MainThread
    protected void requestRoomToken(String roomId, String userId, @NonNull Consumer<String> consumer) {
        Future<String> future = RTCTokenManager.getInstance().getToken(roomId, userId);
        if (future.isDone()) {
            try {
                consumer.accept(future.get());
            } catch (ExecutionException | InterruptedException e) {
                throw new RuntimeException(e);
            }
        } else {
            showLoadingDialog();
            ExampleExecutor.cached.submit(() -> {
                try {
                    String result = future.get();
                    runOnUiThread(() -> {
                        dismissLoadingDialog();
                        consumer.accept(result);
                    });
                } catch (ExecutionException | InterruptedException e) {
                    throw new RuntimeException(e);
                }
            });
        }
    }
}
