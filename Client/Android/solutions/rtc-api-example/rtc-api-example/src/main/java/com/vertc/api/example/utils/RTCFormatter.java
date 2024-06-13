package com.vertc.api.example.utils;

import com.ss.bytertc.engine.type.MediaDeviceError;
import com.ss.bytertc.engine.type.MediaDeviceState;
import com.ss.bytertc.engine.type.MediaDeviceWarning;

public class RTCFormatter {
    public static String formatMediaDeviceState(int state) {
        switch (state) {
            case MediaDeviceState.MEDIA_DEVICE_STATE_STARTED:
                return "MEDIA_DEVICE_STATE_STARTED";
            case MediaDeviceState.MEDIA_DEVICE_STATE_RUNTIMEERROR:
                return "MEDIA_DEVICE_STATE_RUNTIME_ERROR";
            case MediaDeviceState.MEDIA_DEVICE_STATE_STOPPED:
                return "MEDIA_DEVICE_STATE_STOPPED";
            case MediaDeviceState.MEDIA_DEVICE_STATE_ADDED:
                return "MEDIA_DEVICE_STATE_ADDED";
            case MediaDeviceState.MEDIA_DEVICE_STATE_REMOVED:
                return "MEDIA_DEVICE_STATE_REMOVED";
            case MediaDeviceState.MEDIA_DEVICE_STATE_INTERRUPTION_BEGAN:
                return "MEDIA_DEVICE_STATE_INTERRUPTION_BEGAN";
            case MediaDeviceState.MEDIA_DEVICE_STATE_INTERRUPTION_ENDED:
                return "MEDIA_DEVICE_STATE_INTERRUPTION_ENDED";
            default:
                return "Unknown: " + state;
        }
    }

    public static String formatMediaDeviceError(int error) {
        switch (error) {
            case MediaDeviceError.MEDIA_DEVICE_ERROR_OK:
                return "MEDIA_DEVICE_ERROR_OK";
            case MediaDeviceError.MEDIA_DEVICE_ERROR_NOPERMISSION:
                return "MEDIA_DEVICE_ERROR_NO_PERMISSION";
            case MediaDeviceError.MEDIA_DEVICE_ERROR_DEVICEBUSY:
                return "MEDIA_DEVICE_ERROR_DEVICE_BUSY";
            case MediaDeviceError.MEDIA_DEVICE_ERROR_DEVICEFAILURE:
                return "MEDIA_DEVICE_ERROR_DEVICE_FAILURE";
            case MediaDeviceError.MEDIA_DEVICE_ERROR_DEVICENOTFOUND:
                return "MEDIA_DEVICE_ERROR_DEVICE_NOT_FOUND";
            case MediaDeviceError.MEDIA_DEVICE_ERROR_DEVICEDISCONNECTED:
                return "MEDIA_DEVICE_ERROR_DEVICE_DISCONNECTED";
            case MediaDeviceError.MEDIA_DEVICE_ERROR_DEVICENOCALLBACK:
                return "MEDIA_DEVICE_ERROR_DEVICE_NO_CALLBACK";
            case MediaDeviceError.MEDIA_DEVICE_ERROR_UNSUPPORTFORMAT:
                return "MEDIA_DEVICE_ERROR_UNSUPPORTED_FORMAT";
            default:
                return "Unknown Error: " + error;
        }
    }

    public static String formatMediaDeviceWarning(int warn) {
        switch (warn) {
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_OK:
                return "MEDIA_DEVICE_WARNING_OK";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_OPERATION_DENIED:
                return "MEDIA_DEVICE_WARNING_OPERATION_DENIED";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_CAPTURE_SILENCE:
                return "MEDIA_DEVICE_WARNING_CAPTURE_SILENCE";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_ANDROID_SYS_SILENCE:
                return "MEDIA_DEVICE_WARNING_ANDROID_SYS_SILENCE";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_ANDROID_SYS_SILENCE_DISAPPEAR:
                return "MEDIA_DEVICE_WARNING_ANDROID_SYS_SILENCE_DISAPPEAR";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_DETECT_CLIPPING:
                return "MEDIA_DEVICE_WARNING_DETECT_CLIPPING";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_DETECT_LEAK_ECHO:
                return "MEDIA_DEVICE_WARNING_DETECT_LEAK_ECHO";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_DETECT_LOW_SNR:
                return "MEDIA_DEVICE_WARNING_DETECT_LOW_SNR";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_DETECT_INSERT_SILENCE:
                return "MEDIA_DEVICE_WARNING_DETECT_INSERT_SILENCE";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_CAPTURE_DETECT_SILENCE:
                return "MEDIA_DEVICE_WARNING_CAPTURE_DETECT_SILENCE";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_CAPTURE_DETECT_SILENCE_DISAPPEAR:
                return "MEDIA_DEVICE_WARNING_CAPTURE_DETECT_SILENCE_DISAPPEAR";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_CAPTURE_DETECT_HOWLING:
                return "MEDIA_DEVICE_WARNING_CAPTURE_DETECT_HOWLING";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_INVALID_SCENARIO:
                return "MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_INVALID_SCENARIO";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_NOT_EXISTS:
                return "MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_NOT_EXISTS";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_FAILED_BY_PRIORITY:
                return "MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_FAILED_BY_PRIORITY";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_NOT_VOIP_MODE:
                return "MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_NOT_VOIP_MODE";
            case MediaDeviceWarning.MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_DEVICE_NOT_START:
                return "MEDIA_DEVICE_WARNING_SET_AUDIO_ROUTE_DEVICE_NOT_START";
            default:
                return "Unkown Warn: " + warn;
        }
    }
}
