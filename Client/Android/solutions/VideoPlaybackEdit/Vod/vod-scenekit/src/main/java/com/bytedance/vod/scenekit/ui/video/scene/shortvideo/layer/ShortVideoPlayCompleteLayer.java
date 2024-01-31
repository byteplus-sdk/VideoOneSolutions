package com.bytedance.vod.scenekit.ui.video.scene.shortvideo.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import com.bytedance.playerkit.utils.event.Event;
import com.bytedance.vod.scenekit.VideoSettings;
import com.bytedance.vod.scenekit.ui.video.layer.FullScreenLayer;
import com.bytedance.vod.scenekit.ui.video.layer.PlayCompleteLayer;
import com.bytedance.vod.scenekit.ui.video.scene.PlayScene;

public class ShortVideoPlayCompleteLayer extends PlayCompleteLayer {
    public ShortVideoPlayCompleteLayer() {
        setIgnoreLock(true);
    }

    @Override
    protected void onPlaybackEvent(Event event) {
        if (VideoSettings.intValue(VideoSettings.SHORT_VIDEO_PLAYBACK_COMPLETE_ACTION) == 0) {
            // Loop mode, no need show PlayCompleteLayer
            dismiss();
            return;
        }

        if (FullScreenLayer.isFullScreen(videoView())) {
            // Only show in FullScreen/Landscape mode
            super.onPlaybackEvent(event);
        }
        // do nothing in Portrait mode
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!isFullScreenMode(toScene)) {
            dismiss();
        }
    }
}
