// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_ACTUAL_AUDIO_CAPTURE_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_ACTUAL_AUDIO_PLAYER_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_AEC_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_AGC_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_EARMONITOR;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_ECHO_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_MIX_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_NS_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_PLAYER_STARTED;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_PLAYER_STOPED;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_RECORDING_START;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_ADM_RECORDING_STOP;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_AUDIO_CHANNEL_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_AUDIO_ENCODER_FORMAT_CHANGED;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_AUDIO_STARTED_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_AUDIO_STARTINT_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_AUDIO_STOPED_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_AUTO_BRIGHTEN_STATUS_CHANGE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_CAPTURE_FIRST_FRAME;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RECEIVE_LOCAL_VIDEO_FIRST_FRAME;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RESOLUTION_CHANGED;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RTMP_CONNECTED;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RTMP_CONNECTING;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RTMP_CONNECT_FAIL;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RTMP_DISCONNECTED;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RTMP_RECONNECTING;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_RTMP_SEND_SLOW;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_STARTED_PUBLISH;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_STARTING_PUBLISH;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_STOPED_PUBLISH;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_VIDEO_ENCODER_FORMAT_CHANGED;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_VIDEO_FPS_CHANGE_INTERNAL;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_VIDEO_STARTED_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_VIDEO_STARTING_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_INFO_VIDEO_STOPED_CAPTURE;
import static com.ss.avframework.livestreamv2.Constants.MSG_NOTIFY_TOGGLE_CAMERA;
import static com.ss.avframework.livestreamv2.Constants.MSG_REPORT_NETWORK_QUALITY;
import static com.ss.avframework.livestreamv2.Constants.MSG_REPORT_TRANSPORT_BPS;
import static com.ss.avframework.livestreamv2.Constants.MSG_REPORT_TRANSPORT_FPS;

import java.util.HashMap;
import java.util.Map;

class InfoMapper {
    static final Map<Integer, String> CODE_MAP = new HashMap<>();

    static {
        CODE_MAP.put(MSG_INFO_STARTING_PUBLISH, "MSG_INFO_STARTING_PUBLISH");
        CODE_MAP.put(MSG_INFO_STARTED_PUBLISH, "MSG_INFO_STARTED_PUBLISH");
        CODE_MAP.put(MSG_INFO_STOPED_PUBLISH, "MSG_INFO_STOPED_PUBLISH");
        CODE_MAP.put(MSG_INFO_VIDEO_STARTING_CAPTURE, "MSG_INFO_VIDEO_STARTING_CAPTURE");
        CODE_MAP.put(MSG_INFO_VIDEO_STARTED_CAPTURE, "MSG_INFO_VIDEO_STARTED_CAPTURE");
        CODE_MAP.put(MSG_INFO_VIDEO_STOPED_CAPTURE, "MSG_INFO_VIDEO_STOPED_CAPTURE");
        CODE_MAP.put(MSG_INFO_AUDIO_STARTINT_CAPTURE, "MSG_INFO_AUDIO_STARTINT_CAPTURE");
        CODE_MAP.put(MSG_INFO_AUDIO_STARTED_CAPTURE, "MSG_INFO_AUDIO_STARTED_CAPTURE");
        CODE_MAP.put(MSG_INFO_AUDIO_STOPED_CAPTURE, "MSG_INFO_AUDIO_STOPED_CAPTURE");
        CODE_MAP.put(MSG_INFO_RTMP_CONNECTING, "MSG_INFO_RTMP_CONNECTING");
        CODE_MAP.put(MSG_INFO_RTMP_CONNECTED, "MSG_INFO_RTMP_CONNECTED");
        CODE_MAP.put(MSG_INFO_RTMP_CONNECT_FAIL, "MSG_INFO_RTMP_CONNECT_FAIL");
        CODE_MAP.put(MSG_INFO_RTMP_SEND_SLOW, "MSG_INFO_RTMP_SEND_SLOW");
        CODE_MAP.put(MSG_INFO_RTMP_DISCONNECTED, "MSG_INFO_RTMP_DISCONNECTED");
        CODE_MAP.put(MSG_INFO_RTMP_RECONNECTING, "MSG_INFO_RTMP_RECONNECTING");
        CODE_MAP.put(MSG_INFO_VIDEO_ENCODER_FORMAT_CHANGED, "MSG_INFO_VIDEO_ENCODER_FORMAT_CHANGED");
        CODE_MAP.put(MSG_INFO_AUDIO_CHANNEL_CHANGE, "MSG_INFO_AUDIO_CHANNEL_CHANGE");
        CODE_MAP.put(MSG_INFO_ADM_PLAYER_STARTED, "MSG_INFO_ADM_PLAYER_STARTED");
        CODE_MAP.put(MSG_INFO_ADM_PLAYER_STOPED, "MSG_INFO_ADM_PLAYER_STOPED");
        CODE_MAP.put(MSG_INFO_ADM_RECORDING_START, "MSG_INFO_ADM_RECORDING_START");
        CODE_MAP.put(MSG_INFO_ADM_RECORDING_STOP, "MSG_INFO_ADM_RECORDING_STOP");
        CODE_MAP.put(MSG_INFO_ADM_AEC_CHANGE, "MSG_INFO_ADM_AEC_CHANGE");
        CODE_MAP.put(MSG_INFO_ADM_ECHO_CHANGE, "MSG_INFO_ADM_ECHO_CHANGE");
        CODE_MAP.put(MSG_INFO_ADM_MIX_CHANGE, "MSG_INFO_ADM_MIX_CHANGE");
        CODE_MAP.put(MSG_INFO_ADM_AGC_CHANGE, "MSG_INFO_ADM_AGC_CHANGE");
        CODE_MAP.put(MSG_INFO_ADM_NS_CHANGE, "MSG_INFO_ADM_NS_CHANGE");
        CODE_MAP.put(MSG_INFO_RESOLUTION_CHANGED, "MSG_INFO_RESOLUTION_CHANGED");
        CODE_MAP.put(MSG_INFO_RECEIVE_LOCAL_VIDEO_FIRST_FRAME, "MSG_INFO_RECEIVE_LOCAL_VIDEO_FIRST_FRAME");
        CODE_MAP.put(MSG_INFO_AUDIO_ENCODER_FORMAT_CHANGED, "MSG_INFO_AUDIO_ENCODER_FORMAT_CHANGED");
        CODE_MAP.put(MSG_INFO_CAPTURE_FIRST_FRAME, "MSG_INFO_CAPTURE_FIRST_FRAME");
        CODE_MAP.put(MSG_INFO_ADM_EARMONITOR, "MSG_INFO_ADM_EARMONITOR");
        CODE_MAP.put(MSG_INFO_ADM_ACTUAL_AUDIO_CAPTURE_CHANGE, "MSG_INFO_ADM_ACTUAL_AUDIO_CAPTURE_CHANGE");
        CODE_MAP.put(MSG_INFO_ADM_ACTUAL_AUDIO_PLAYER_CHANGE, "MSG_INFO_ADM_ACTUAL_AUDIO_PLAYER_CHANGE");
        CODE_MAP.put(MSG_INFO_VIDEO_FPS_CHANGE_INTERNAL, "MSG_INFO_VIDEO_FPS_CHANGE_INTERNAL");
        CODE_MAP.put(MSG_INFO_AUTO_BRIGHTEN_STATUS_CHANGE, "MSG_INFO_AUTO_BRIGHTEN_STATUS_CHANGE");
        CODE_MAP.put(MSG_REPORT_NETWORK_QUALITY, "MSG_REPORT_NETWORK_QUALITY");
        CODE_MAP.put(MSG_REPORT_TRANSPORT_FPS, "MSG_REPORT_TRANSPORT_FPS");
        CODE_MAP.put(MSG_REPORT_TRANSPORT_BPS, "MSG_REPORT_TRANSPORT_BPS");
        CODE_MAP.put(MSG_NOTIFY_TOGGLE_CAMERA, "MSG_NOTIFY_TOGGLE_CAMERA");
    }

    public static String get(int code) {
        final String msg = CODE_MAP.get(code);
        return msg == null ? String.valueOf(code) : msg;
    }
}
