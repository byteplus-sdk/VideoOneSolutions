// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.playerkit.player.ve.utils;

import com.ss.ttvideoengine.PlayerEventListener;
import com.ss.ttvideoengine.PlayerEventSimpleListener;
import com.ss.ttvideoengine.Resolution;
import com.ss.ttvideoengine.SeekCompletionListener;
import com.ss.ttvideoengine.TTVideoEngine;
import com.ss.ttvideoengine.VideoEngineCallback;
import com.ss.ttvideoengine.VideoEngineInfoListener;
import com.ss.ttvideoengine.VideoEngineInfos;
import com.ss.ttvideoengine.VideoInfoListener;
import com.ss.ttvideoengine.model.VideoModel;
import com.ss.ttvideoengine.utils.Error;

import java.util.Map;

public class TTVideoEngineListenerAdapter extends PlayerEventSimpleListener implements VideoEngineCallback,
        SeekCompletionListener,
        VideoInfoListener,
        VideoEngineInfoListener,
        PlayerEventListener {

    @Override
    public void onCompletion(boolean b) {

    }

    @Override
    public void onVideoEngineInfos(VideoEngineInfos videoEngineInfos) {

    }

    @Override
    public boolean onFetchedVideoInfo(VideoModel videoModel) {
        return false;
    }

    @Override
    public void onPlaybackStateChanged(TTVideoEngine engine, int playbackState) {
    }

    @Override
    public void onLoadStateChanged(TTVideoEngine engine, int loadState) {
    }

    @Override
    public void onVideoSizeChanged(TTVideoEngine engine, int width, int height) {
    }

    @Override
    public void onBufferingUpdate(TTVideoEngine engine, int percent) {
    }

    @Override
    public void onPrepare(TTVideoEngine engine) {
    }

    @Override
    public void onPrepared(TTVideoEngine engine) {
    }

    @Override
    public void onRenderStart(TTVideoEngine engine) {
    }

    @Override
    public void onReadyForDisplay(TTVideoEngine engine) {
    }

    @Override
    public void onStreamChanged(TTVideoEngine engine, int type) {
    }

    @Override
    public void onCompletion(TTVideoEngine engine) {
    }

    @Override
    public void onError(Error error) {
    }

    @Override
    public void onVideoStatusException(int status) {
    }

    @Override
    public void onABRPredictBitrate(int mediaType, int bitrate) {
    }

    @Override
    public void onSARChanged(int num, int den) {
    }

    @Override
    public void onBufferStart(int reason, int afterFirstFrame, int action) {
    }

    @Override
    public void onBufferEnd(int code) {
    }

    @Override
    public void onVideoURLRouteFailed(Error error, String url) {
    }

    @Override
    public void onVideoStreamBitrateChanged(Resolution resolution, int bitrate) {
    }

    @Override
    public void onFrameDraw(int frameCount, Map map) {
    }

    @Override
    public void onInfoIdChanged(int infoId) {
    }

    @Override
    public void onAVBadInterlaced(Map map) {
    }

    @Override
    public void onFrameAboutToBeRendered(TTVideoEngine engine, int type, long pts, long wallClockTime, Map<Integer, String> frameData) {
    }

    @Override
    public String getEncryptedLocalTime() {
        return null;
    }
}
