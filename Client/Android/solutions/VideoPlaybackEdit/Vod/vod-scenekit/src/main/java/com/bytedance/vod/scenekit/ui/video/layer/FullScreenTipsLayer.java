package com.bytedance.vod.scenekit.ui.video.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.ui.video.layer.base.AnimateLayer;
import com.bytedance.vod.settingskit.Option;

public class FullScreenTipsLayer extends AnimateLayer {
    @Nullable
    @Override
    public String tag() {
        return "full-screen-tips";
    }

    @Nullable
    @Override
    protected View createView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_full_screen_tips_layer, parent, false);
        view.setOnClickListener(v -> dismiss());
        return view;
    }

    @Override
    public void show() {
        if (!isFullScreenMode(playScene())) {
            return;
        }
        super.show();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (isFullScreenMode(toScene)) {
            Option option = VideoSettings.option(VideoSettings.COMMON_SHOW_FULL_SCREEN_TIPS);
            if (option.booleanValue()) {
                animateShow(true);
                option.saveUserValue(Boolean.FALSE);
            }
        } else {
            dismiss();
        }
    }

    @Override
    protected long animateDismissDelay() {
        return 3000;
    }
}
