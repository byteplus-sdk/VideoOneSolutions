// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.settings;

import android.util.Range;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveRoleType;

public class SettingsViewModel extends ViewModel {

    public static final int VIDEO_FPS_15 = 15;
    public static final int VIDEO_FPS_20 = 20;

    public static final int VIDEO_QUALITY_1080 = 1080;
    public static final int VIDEO_QUALITY_720 = 720;
    public static final int VIDEO_QUALITY_540 = 540;

    public static final Range<Integer> BITRATE_RANGE_1080 = new Range<>(1000, 3800);
    public static final Range<Integer> BITRATE_RANGE_720 = new Range<>(800, 1900);
    public static final Range<Integer> BITRATE_RANGE_540 = new Range<>(500, 1520);

    public final MutableLiveData<Boolean> showQualityItem = new MutableLiveData<>(false);

    public final MutableLiveData<Integer> videoFPS = new MutableLiveData<>(VIDEO_FPS_15);
    public final MutableLiveData<Integer> videoQuality = new MutableLiveData<>(VIDEO_QUALITY_720);

    public final MutableLiveData<Range<Integer>> videoBitrateRange = new MutableLiveData<>(BITRATE_RANGE_720);

    public int currentBitrate = 20;

    public int minBitrate = 0;
    public int maxBitrate = 100;
    private final int role = LiveRoleType.HOST;

    public void init() {
        final LiveRTCManager manager = LiveRTCManager.ins();

        final int frameRate = manager.getFrameRate(role);
        if (frameRate == 20) {
            videoFPS.setValue(VIDEO_FPS_20);
        } else {
            videoFPS.setValue(VIDEO_FPS_15);
        }

        currentBitrate = manager.getBitrate(role);  // Constraint by VideoQuality, should set before VideoQuality

        final int width = manager.getWidth(role);
        if (width == 1080) {
            videoQuality.setValue(VIDEO_QUALITY_1080);
            updateVideoBitrateRange(BITRATE_RANGE_1080);
        } else if (width == 540) {
            videoQuality.setValue(VIDEO_QUALITY_540);
            updateVideoBitrateRange(BITRATE_RANGE_540);
        } else {
            videoQuality.setValue(VIDEO_QUALITY_720);
            updateVideoBitrateRange(BITRATE_RANGE_720);
        }
    }

    public void setVideoFPS(int fps) {
        videoFPS.postValue(fps);

        LiveRTCManager.ins().setFrameRate(role, fps);
    }

    public void updateVideoBitrateRange(Range<Integer> range) {
        this.minBitrate = range.getLower();
        this.maxBitrate = range.getUpper();

        if (currentBitrate >= maxBitrate) {
            currentBitrate = maxBitrate;
        } else if (currentBitrate <= minBitrate) {
            currentBitrate = minBitrate;
        }

        videoBitrateRange.postValue(range);
    }

    public void updateToRTCVideo() {
        LiveRTCManager.ins().setBitrate(role, currentBitrate);
    }

    public int setVideoBitrateByProgress(int progress) {
        currentBitrate = minBitrate + progress;
        return currentBitrate;
    }

    public int getVideoBitrateByProgress() {
        return (currentBitrate - minBitrate);
    }

    public void setVideoQualityAndBitrateRange(int quality) {
        videoQuality.postValue(quality);
        switch (quality) {
            case VIDEO_QUALITY_1080:
                updateVideoBitrateRange(BITRATE_RANGE_1080);
                LiveRTCManager.ins().setResolution(role, 1080, 1920, currentBitrate);
                break;
            case VIDEO_QUALITY_720:
                updateVideoBitrateRange(BITRATE_RANGE_720);
                LiveRTCManager.ins().setResolution(role, 720, 1280, currentBitrate);
                break;
            case VIDEO_QUALITY_540:
                updateVideoBitrateRange(BITRATE_RANGE_540);
                LiveRTCManager.ins().setResolution(role, 540, 960, currentBitrate);
                break;
        }
    }
}
