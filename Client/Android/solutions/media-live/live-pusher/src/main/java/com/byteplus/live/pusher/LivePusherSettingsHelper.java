// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher;

import static com.byteplus.live.settings.PreferenceUtil.FPS_15;
import static com.byteplus.live.settings.PreferenceUtil.FPS_20;
import static com.byteplus.live.settings.PreferenceUtil.FPS_25;
import static com.byteplus.live.settings.PreferenceUtil.FPS_30;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_AUDIO_SAMPLE_RATE_44_1K;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE_BYTE_BUFFER;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_EXTERNAL_VIDEO_FRAME_FMT_TYPE_I420;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_ORIENTATION_LANDSCAPE;
import static com.byteplus.live.settings.PreferenceUtil.PUSH_ORIENTATION_PORTRAIT;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_1080P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_360P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_480P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_540P;
import static com.byteplus.live.settings.PreferenceUtil.RESOLUTION_720P;

import com.byteplus.live.settings.PreferenceUtil;

public class LivePusherSettingsHelper {
    static public String getPushUrl() {
        return PreferenceUtil.getInstance().getPushUrl("");
    }

    static public boolean isLandscape() {
        return PreferenceUtil.getInstance().getPushOrientation(PUSH_ORIENTATION_PORTRAIT) == PUSH_ORIENTATION_LANDSCAPE;
    }

    static public int getCaptureFpsSettings() {
        return PreferenceUtil.getInstance().getPushVideoCaptureFps(FPS_15);
    }

    static public int getCaptureResolutionSettings() {
        return PreferenceUtil.getInstance().getPushVideoCaptureResolution(RESOLUTION_720P);
    }

    static public int getEncodeFpsSettings() {
        return PreferenceUtil.getInstance().getPushVideoEncodeFps(FPS_15);
    }

    static public int getEncodeResolutionSettings() {
        return PreferenceUtil.getInstance().getPushVideoEncodeResolution(RESOLUTION_720P);
    }

    static public int getAudioEncodeSampleRate() {
        return PreferenceUtil.getInstance().getPushAudioEncodeSampleRate(PUSH_AUDIO_SAMPLE_RATE_44_1K);
    }

    static public int getExternalVideoFrameFmtType() {
        return PreferenceUtil.getInstance().getPushExternalVideoFrameFmtType(PUSH_EXTERNAL_VIDEO_FRAME_FMT_TYPE_I420);
    }

    static public int getExternalVideoFrameBufferType() {
        return PreferenceUtil.getInstance().getPushExternalVideoFrameBufferType(PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE_BYTE_BUFFER);
    }

    static public int getFpsVal(int settings) {
        if (settings == FPS_15) {
            return 15;
        } else if (settings == FPS_20) {
            return 20;
        } else if (settings == FPS_25) {
            return 25;
        } else if (settings == FPS_30) {
            return 30;
        } else {
            return 0;
        }
    }

    static public int getResolutionWidthVal(int settings) {
        if (settings == RESOLUTION_360P) {
            return 360;
        } else if (settings == RESOLUTION_480P) {
            return 480;
        } else if (settings == RESOLUTION_540P) {
            return 540;
        } else if (settings == RESOLUTION_720P) {
            return 720;
        } else if (settings == RESOLUTION_1080P) {
            return 1080;
        } else {
            return 0;
        }
    }

    static public int getResolutionHeightVal(int settings) {
        if (settings == RESOLUTION_360P) {
            return 640;
        } else if (settings == RESOLUTION_480P) {
            return 864;
        } else if (settings == RESOLUTION_540P) {
            return 960;
        } else if (settings == RESOLUTION_720P) {
            return 1280;
        } else if (settings == RESOLUTION_1080P) {
            return 1920;
        } else {
            return 0;
        }
    }

    static public int getCaptureFpsVal() {
        return getFpsVal(getCaptureFpsSettings());
    }

    static public int getCaptureWidthVal() {
        return getResolutionWidthVal(getCaptureResolutionSettings());
    }

    static public int getCaptureHeightVal() {
        return getResolutionHeightVal(getCaptureResolutionSettings());
    }

    static public int getEncodeFpsVal() {
        return getFpsVal(getEncodeFpsSettings());
    }
}
