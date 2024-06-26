// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.settings;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import com.byteplus.live.common.AppUtil;

public class PreferenceUtil {

    private static PreferenceUtil sInstance;

    public static PreferenceUtil getInstance() {
        if (sInstance == null) {
            synchronized (PreferenceUtil.class) {
                if (sInstance == null) {
                    sInstance = new PreferenceUtil();
                }
            }
        }
        return sInstance;
    }

    private static final String SHARE_PREFERENCE_NAME = "TTSDK_LIVE_DEMO";

    private static final String PULL_ABR = "PULL_ABR";
    private static final String PULL_AUTO_ABR = "PULL_AUTO_ABR";
    private static final String PULL_SEI = "PULL_SEI";
    private static final String PULL_FORMAT = "PULL_FORMAT";
    private static final String PULL_PROTOCOL = "PULL_PROTOCOL";
    private static final String PULL_URL = "PULL_URL";
    private static final String PULL_URL_BACKUP = "PULL_URL_BACKUP";
    private static final String PULL_VOLUME = "PULL_VOLUME";
    private static final String PULL_ENABLE_BACKGROUND_PLAY = "PULL_ENABLE_BACKGROUND_PLAY";

    private static final String PULL_ABR_DEFAULT = "PULL_ABR_DEFAULT";
    private static final String PULL_ABR_CURRENT = "PULL_ABR_CURRENT";

    public static final String PULL_ABR_ORIGIN = "PULL_ABR_ORIGIN";
    public static final String PULL_ABR_UHD = "PULL_ABR_UHD";
    public static final String PULL_ABR_HD = "PULL_ABR_HD";
    public static final String PULL_ABR_LD = "PULL_ABR_LD";
    public static final String PULL_ABR_SD = "PULL_ABR_SD";

    private static final String PULL_ABR_ORIGIN_BACKUP = "PULL_ABR_ORIGIN_BACKUP";
    private static final String PULL_ABR_UHD_BACKUP = "PULL_ABR_UHD_BACKUP";
    private static final String PULL_ABR_HD_BACKUP = "PULL_ABR_HD_BACKUP";
    private static final String PULL_ABR_LD_BACKUP = "PULL_ABR_LD_BACKUP";
    private static final String PULL_ABR_SD_BACKUP = "PULL_ABR_SD_BACKUP";

    private static final String PULL_ENABLE_CYCLE_INFO = "PULL_ENABLE_CYCLE_INFO";
    private static final String PULL_ENABLE_CALLBACK_INFO = "PULL_ENABLE_CALLBACK_INFO";
    private static final String PULL_LOG_LEVEL = "PULL_LOG_LEVEL";

    public static final int PULL_RENDER_FILL_MODE_ASPECT_FIT = 0;
    public static final int PULL_RENDER_FILL_MODE_FULL_FILL = 1;
    public static final int PULL_RENDER_FILL_MODE_ASPECT_FILL = 2;

    public static final int PULL_ROTATION_0 = 0;
    public static final int PULL_ROTATION_90 = 1;
    public static final int PULL_ROTATION_180 = 2;
    public static final int PULL_ROTATION_270 = 3;

    public static final int PULL_MIRROR_NONE = 0;
    public static final int PULL_MIRROR_HORIZONTAL = 1;
    public static final int PULL_MIRROR_VERTICAL = 2;

    public static final int PULL_FORMAT_FLV = 0;
    public static final int PULL_FORMAT_HLS = 1;
    public static final int PULL_FORMAT_RTM = 2;

    public static final int PULL_PROTOCOL_TCP = 0;
    public static final int PULL_PROTOCOL_TLS = 1;
    public static final int PULL_PROTOCOL_QUIC = 2;

    public static final int PULL_BUFFER_TYPE_BYTE_BUFFER = 0;
    public static final int PULL_BUFFER_TYPE_BYTE_ARRAY = 1;
    public static final int PULL_BUFFER_TYPE_TEXTURE = 2;

    public static final int PULL_PIXEL_FORMAT_RGBA32 = 0;
    public static final int PULL_PIXEL_FORMAT_TEXTURE = 1;

    private static final String PUSH_URL = "PUSH_URL";
    private static final String PUSH_VIDEO_CAPTURE_RESOLUTIONS = "PUSH_VIDEO_CAPTURE_RESOLUTIONS";
    private static final String PUSH_VIDEO_ENCODE_RESOLUTIONS = "PUSH_VIDEO_ENCODE_RESOLUTIONS";
    private static final String PUSH_VIDEO_CAPTURE_FPS = "PUSH_VIDEO_CAPTURE_FPS";
    private static final String PUSH_VIDEO_ENCODE_FPS = "PUSH_VIDEO_ENCODE_FPS";
    private static final String PUSH_AUDIO_SAMPLE_RATE = "PUSH_AUDIO_SAMPLE_RATE";
    private static final String PUSH_ORIENTATION = "PUSH_ORIENTATION";
    private static final String PUSH_EXTERNAL_VIDEO_FRAME_TYPE = "PUSH_EXTERNAL_VIDEO_FRAME_TYPE";
    private static final String PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE = "PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE";

    private static final String PUSH_LOG_LEVEL = "PUSH_LOG_LEVEL";

    private static final String PUSH_ENABLE_APP_AUDIO = "PUSH_ENABLE_APP_AUDIO";

    public static final int RESOLUTION_360P = 0;
    public static final int RESOLUTION_480P = 1;
    public static final int RESOLUTION_540P = 2;
    public static final int RESOLUTION_720P = 3;
    public static final int RESOLUTION_1080P = 4;

    public static final int FPS_15 = 0;
    public static final int FPS_20 = 1;
    public static final int FPS_25 = 2;
    public static final int FPS_30 = 3;

    public static final int PUSH_AUDIO_SAMPLE_RATE_8K = 0;
    public static final int PUSH_AUDIO_SAMPLE_RATE_16K = 1;
    public static final int PUSH_AUDIO_SAMPLE_RATE_32K = 2;
    public static final int PUSH_AUDIO_SAMPLE_RATE_44_1K = 3;
    public static final int PUSH_AUDIO_SAMPLE_RATE_48K = 4;

    public static final int PUSH_VIDEO_CAPTURE_FRONT = 0;
    public static final int PUSH_VIDEO_CAPTURE_BACK = 1;
    public static final int PUSH_VIDEO_CAPTURE_DUAL = 2;
    public static final int PUSH_VIDEO_CAPTURE_SCREEN = 3;
    public static final int PUSH_VIDEO_CAPTURE_EXTERNAL = 4;
    public static final int PUSH_VIDEO_CAPTURE_CUSTOM_IMAGE = 5;
    public static final int PUSH_VIDEO_CAPTURE_LAST_FRAME = 6;
    public static final int PUSH_VIDEO_CAPTURE_DUMMY_FRAME = 7;

    public static final int PUSH_AUDIO_CAPTURE_MICROPHONE = 0;
    public static final int PUSH_AUDIO_CAPTURE_VOICE_COMMUNICATION = 1;
    public static final int PUSH_AUDIO_CAPTURE_VOICE_RECOGNITION = 2;
    public static final int PUSH_AUDIO_CAPTURE_EXTERNAL = 3;
    public static final int PUSH_AUDIO_CAPTURE_MUTE_FRAME = 4;

    public static final int PUSH_VIDEO_CAPTURE_MIRROR = 0;
    public static final int PUSH_VIDEO_PREVIEW_MIRROR = 1;
    public static final int PUSH_VIDEO_PUSH_MIRROR = 2;

    public static final int NETWORK_QUALITY_UNKNOWN = 0;
    public static final int NETWORK_QUALITY_BAD = 1;
    public static final int NETWORK_QUALITY_POOR = 2;
    public static final int NETWORK_QUALITY_GOOD = 3;

    public static final int PULL_LOG_LEVEL_NONE = 0;
    public static final int PULL_LOG_LEVEL_ERROR = 1;
    public static final int PULL_LOG_LEVEL_WARN = 2;
    public static final int PULL_LOG_LEVEL_INFO = 3;
    public static final int PULL_LOG_LEVEL_DEBUG = 4;
    public static final int PULL_LOG_LEVEL_VERBOSE = 5;

    public static final int PUSH_ORIENTATION_LANDSCAPE = 0;
    public static final int PUSH_ORIENTATION_PORTRAIT = 1;

    public static final int PUSH_EXTERNAL_VIDEO_FRAME_FMT_TYPE_I420 = 0;
    public static final int PUSH_EXTERNAL_VIDEO_FRAME_FMT_TYPE_NV12 = 1;
    public static final int PUSH_EXTERNAL_VIDEO_FRAME_FMT_TYPE_NV21 = 2;
    public static final int PUSH_EXTERNAL_VIDEO_FRAME_FMT_TYPE_2D_TEXTURE = 3;
    public static final int PUSH_EXTERNAL_VIDEO_FRAME_FMT_TYPE_OES_TEXTURE = 4;

    public static final int PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE_BYTE_BUFFER = 0;
    public static final int PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE_BYTE_ARRAY = 1;
    public static final int PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE_TEXTURE_ID = 2;

    public static final int PUSH_VIDEO_RENDER_MODE_FILL = 0;
    public static final int PUSH_VIDEO_RENDER_MODE_FIT = 1;
    public static final int PUSH_VIDEO_RENDER_MODE_HIDDEN = 2;

    private final SharedPreferences mSharedPreferences;

    private PreferenceUtil() {
        Application context = AppUtil.getApplicationContext();
        mSharedPreferences = context.getSharedPreferences(SHARE_PREFERENCE_NAME, Context.MODE_PRIVATE);
    }

    public void setStringValue(String key, String value) {
        mSharedPreferences.edit()
                .putString(key, value)
                .apply();
    }

    public String getStringValue(String key, String defaultValue) {
        return mSharedPreferences.getString(key, defaultValue);
    }

    public void setBooleanValue(String key, boolean value) {
        mSharedPreferences.edit()
                .putBoolean(key, value)
                .apply();
    }

    public boolean getBooleanValue(String key, boolean defaultValue) {
        return mSharedPreferences.getBoolean(key, defaultValue);
    }

    public void setIntValue(String key, int value) {
        mSharedPreferences.edit()
                .putInt(key, value)
                .apply();
    }

    public int getIntValue(String key, int defaultValue) {
        return mSharedPreferences.getInt(key, defaultValue);
    }

    public void setFloatValue(String key, float value) {
        mSharedPreferences.edit()
                .putFloat(key, value)
                .apply();
    }

    public float getFloatValue(String key, float defaultValue) {
        return mSharedPreferences.getFloat(key, defaultValue);
    }

    public void setLongValue(String key, long value) {
        mSharedPreferences.edit()
                .putLong(key, value)
                .apply();
    }

    public long getLongValue(String key, long defaultValue) {
        return mSharedPreferences.getLong(key, defaultValue);
    }

    public void setPullAbr(boolean enable) {
        setBooleanValue(PULL_ABR, enable);
    }

    public boolean getPullAbr(boolean defaultValue) {
        return getBooleanValue(PULL_ABR, defaultValue);
    }

    public void setPullAutoAbr(boolean enable) {
        setBooleanValue(PULL_AUTO_ABR, enable);
    }

    public boolean getPullAutoAbr(boolean defaultValue) {
        return getBooleanValue(PULL_AUTO_ABR, defaultValue);
    }

    public void setPullEnableBackgroundPlay(boolean enable) {
        setBooleanValue(PULL_ENABLE_BACKGROUND_PLAY, enable);
    }

    public boolean getPullEnableBackgroundPlay(boolean defaultValue) {
        return getBooleanValue(PULL_ENABLE_BACKGROUND_PLAY, defaultValue);
    }

    public void setPullSei(boolean enable) {
        setBooleanValue(PULL_SEI, enable);
    }

    public boolean getPullSei(boolean defaultValue) {
        return getBooleanValue(PULL_SEI, defaultValue);
    }

    public boolean getPullEnableTextureRender(boolean defaultValue) {
        return defaultValue;
    }

    public boolean getPullEnableAudioSelfRender(boolean defaultValue) {
        return defaultValue;
    }

    public void setPullFormat(int format) {
        setIntValue(PULL_FORMAT, format);
    }

    public int getPullFormat(int defaultValue) {
        return getIntValue(PULL_FORMAT, defaultValue);
    }

    public void setPullProtocol(int protocol) {
        setIntValue(PULL_PROTOCOL, protocol);
    }

    public int getPullProtocol(int defaultValue) {
        return getIntValue(PULL_PROTOCOL, defaultValue);
    }

    public void setPullUrl(String url) {
        setStringValue(PULL_URL, url);
    }

    public String getPullUrl(String defaultUrl) {
        return getStringValue(PULL_URL, defaultUrl);
    }

    public void setPullUrlBackup(String url) {
        setStringValue(PULL_URL_BACKUP, url);
    }

    public String getPullUrlBackup(String defaultUrl) {
        return getStringValue(PULL_URL_BACKUP, defaultUrl);
    }

    public void setPullAbrOrigin(String url) {
        setStringValue(PULL_ABR_ORIGIN, url);
    }

    public String getPullAbrOrigin(String defaultUrl) {
        return getStringValue(PULL_ABR_ORIGIN, defaultUrl);
    }

    public void setPullAbrUhd(String url) {
        setStringValue(PULL_ABR_UHD, url);
    }

    public String getPullAbrUhd(String defaultUrl) {
        return getStringValue(PULL_ABR_UHD, defaultUrl);
    }

    public void setPullAbrHd(String url) {
        setStringValue(PULL_ABR_HD, url);
    }

    public String getPullAbrHd(String defaultUrl) {
        return getStringValue(PULL_ABR_HD, defaultUrl);
    }

    public void setPullAbrLd(String url) {
        setStringValue(PULL_ABR_LD, url);
    }

    public String getPullAbrLd(String defaultUrl) {
        return getStringValue(PULL_ABR_LD, defaultUrl);
    }

    public void setPullAbrSd(String url) {
        setStringValue(PULL_ABR_SD, url);
    }

    public String getPullAbrSd(String defaultUrl) {
        return getStringValue(PULL_ABR_SD, defaultUrl);
    }

    public void setPullAbrDefault(String url) {
        setStringValue(PULL_ABR_DEFAULT, url);
    }

    public void clearAbr() {
        setPullAbrDefault(null);
        setPullAbrOrigin(null);
        setPullAbrUhd(null);
        setPullAbrHd(null);
        setPullAbrLd(null);
        setPullAbrSd(null);

        setPullAbrOriginBackup(null);
        setPullAbrUhdBackup(null);
        setPullAbrHdBackup(null);
        setPullAbrLdBackup(null);
        setPullAbrSdBackup(null);
    }

    public String getPullAbrDefault(String defaultUrl) {
        return getStringValue(PULL_ABR_DEFAULT, defaultUrl);
    }

    public void setPullAbrCurrent(String url) {
        setStringValue(PULL_ABR_CURRENT, url);
    }

    public String getPullAbrCurrent(String defaultUrl) {
        return getStringValue(PULL_ABR_CURRENT, defaultUrl);
    }

    public void setPullAbrOriginBackup(String url) {
        setStringValue(PULL_ABR_ORIGIN_BACKUP, url);
    }

    public String getPullAbrOriginBackup(String defaultUrl) {
        return getStringValue(PULL_ABR_ORIGIN_BACKUP, defaultUrl);
    }

    public void setPullAbrUhdBackup(String url) {
        setStringValue(PULL_ABR_UHD_BACKUP, url);
    }

    public String getPullAbrUhdBackup(String defaultUrl) {
        return getStringValue(PULL_ABR_UHD_BACKUP, defaultUrl);
    }

    public void setPullAbrHdBackup(String url) {
        setStringValue(PULL_ABR_HD_BACKUP, url);
    }

    public String getPullAbrHdBackup(String defaultUrl) {
        return getStringValue(PULL_ABR_HD_BACKUP, defaultUrl);
    }

    public void setPullAbrLdBackup(String url) {
        setStringValue(PULL_ABR_LD_BACKUP, url);
    }

    public String getPullAbrLdBackup(String defaultUrl) {
        return getStringValue(PULL_ABR_LD_BACKUP, defaultUrl);
    }

    public void setPullAbrSdBackup(String url) {
        setStringValue(PULL_ABR_SD_BACKUP, url);
    }

    public String getPullAbrSdBackup(String defaultUrl) {
        return getStringValue(PULL_ABR_SD_BACKUP, defaultUrl);
    }

    public void setPullEnableCycleInfo(boolean enable) {
        setBooleanValue(PULL_ENABLE_CYCLE_INFO, enable);
    }

    public boolean getPullEnableCycleInfo(boolean defaultValue) {
        return getBooleanValue(PULL_ENABLE_CYCLE_INFO, defaultValue);
    }

    public void setPullEnableCallbackInfo(boolean enable) {
        setBooleanValue(PULL_ENABLE_CALLBACK_INFO, enable);
    }

    public boolean getPullEnableCallbackInfo(boolean defaultValue) {
        return getBooleanValue(PULL_ENABLE_CALLBACK_INFO, defaultValue);
    }

    public void setPullVolume(float volume) {
        setFloatValue(PULL_VOLUME, volume);
    }

    public float getPullVolume(float defaultValue) {
        return getFloatValue(PULL_VOLUME, defaultValue);
    }

    public void setPullLogLevel(int level) {
        setIntValue(PULL_LOG_LEVEL, level);
    }

    public int getPullLogLevel(int defaultValue) {
        return getIntValue(PULL_LOG_LEVEL, defaultValue);
    }

    public void setPushUrl(String url) {
        setStringValue(PUSH_URL, url);
    }

    public String getPushUrl(String defaultUrl) {
        return getStringValue(PUSH_URL, defaultUrl);
    }

    public void setPushVideoCaptureResolution(int resolution) {
        setIntValue(PUSH_VIDEO_CAPTURE_RESOLUTIONS, resolution);
    }

    public int getPushVideoCaptureResolution(int defaultValue) {
        return getIntValue(PUSH_VIDEO_CAPTURE_RESOLUTIONS, defaultValue);
    }

    public void setPushVideoEncodeResolution(int resolution) {
        setIntValue(PUSH_VIDEO_ENCODE_RESOLUTIONS, resolution);
    }

    public int getPushVideoEncodeResolution(int defaultValue) {
        return getIntValue(PUSH_VIDEO_ENCODE_RESOLUTIONS, defaultValue);
    }

    public void setPushVideoCaptureFps(int fps) {
        setIntValue(PUSH_VIDEO_CAPTURE_FPS, fps);
    }

    public int getPushVideoCaptureFps(int defaultValue) {
        return getIntValue(PUSH_VIDEO_CAPTURE_FPS, defaultValue);
    }

    public void setPushVideoEncodeFps(int fps) {
        setIntValue(PUSH_VIDEO_ENCODE_FPS, fps);
    }

    public int getPushVideoEncodeFps(int defaultValue) {
        return getIntValue(PUSH_VIDEO_ENCODE_FPS, defaultValue);
    }

    public void setPushAudioEncodeSampleRate(int sampleRate) {
        setIntValue(PUSH_AUDIO_SAMPLE_RATE, sampleRate);
    }

    public int getPushAudioEncodeSampleRate(int defaultValue) {
        return getIntValue(PUSH_AUDIO_SAMPLE_RATE, defaultValue);
    }

    public void setPushExternalVideoFrameType(int type) {
        setIntValue(PUSH_EXTERNAL_VIDEO_FRAME_TYPE, type);
    }

    public int getPushExternalVideoFrameFmtType(int defaultValue) {
        return getIntValue(PUSH_EXTERNAL_VIDEO_FRAME_TYPE, defaultValue);
    }

    public void setPushExternalVideoFrameBufferType(int type) {
        setIntValue(PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE, type);
    }

    public int getPushExternalVideoFrameBufferType(int defaultValue) {
        return getIntValue(PUSH_EXTERNAL_VIDEO_FRAME_BUFFER_TYPE, defaultValue);
    }

    public void setPushLogLevel(int level) {
        setIntValue(PUSH_LOG_LEVEL, level);
    }

    public int getPushLogLevel(int defaultValue) {
        return getIntValue(PUSH_LOG_LEVEL, defaultValue);
    }

    public void setPushOrientation(int orientation) {
        setIntValue(PUSH_ORIENTATION, orientation);
    }

    public int getPushOrientation(int defaultValue) {
        return getIntValue(PUSH_ORIENTATION, defaultValue);
    }

    public void setPushEnableAppAudio(boolean enable) {
        setBooleanValue(PUSH_ENABLE_APP_AUDIO, enable);
    }

    public boolean getPushEnableAppAudio(boolean defaultValue) {
        return getBooleanValue(PUSH_ENABLE_APP_AUDIO, defaultValue);
    }
}
