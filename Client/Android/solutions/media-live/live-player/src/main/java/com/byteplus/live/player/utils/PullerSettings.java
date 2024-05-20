// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.utils;

import static com.byteplus.live.settings.PreferenceUtil.PULL_FORMAT_FLV;
import static com.byteplus.live.settings.PreferenceUtil.PULL_FORMAT_HLS;
import static com.byteplus.live.settings.PreferenceUtil.PULL_FORMAT_RTM;
import static com.byteplus.live.settings.PreferenceUtil.PULL_PROTOCOL_QUIC;
import static com.byteplus.live.settings.PreferenceUtil.PULL_PROTOCOL_TCP;
import static com.byteplus.live.settings.PreferenceUtil.PULL_PROTOCOL_TLS;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatFLV;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatHLS;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatRTM;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerProtocol.*;

import android.net.Uri;
import android.util.Log;

import com.byteplus.live.settings.PreferenceUtil;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;

public class PullerSettings {
    private static final String TAG = "PullerSettings";

    public static VeLivePlayerDef.VeLivePlayerFormat getPullFormat() {
        int format = PreferenceUtil.getInstance().getPullFormat(PULL_FORMAT_FLV);
        switch (format) {
            case PULL_FORMAT_FLV:
                return VeLivePlayerFormatFLV;
            case PULL_FORMAT_HLS:
                return VeLivePlayerFormatHLS;
            case PULL_FORMAT_RTM:
                return VeLivePlayerFormatRTM;
            default:
                Log.w(TAG, "getPullProtocol: unknown format:" + format + ";  fallback to [FormatFLV]");
                return VeLivePlayerFormatFLV;
        }
    }

    public static VeLivePlayerDef.VeLivePlayerProtocol getPullProtocol() {
        int protocol = PreferenceUtil.getInstance().getPullProtocol(PULL_PROTOCOL_TCP);
        switch (protocol) {
            case PULL_PROTOCOL_TCP:
                return VeLivePlayerProtocolTCP;
            case PULL_PROTOCOL_TLS:
                return VeLivePlayerProtocolTLS;
            case PULL_PROTOCOL_QUIC:
                return VeLivePlayerProtocolQUIC;
            default:
                Log.w(TAG, "getPullProtocol: unknown protocol:" + protocol + ";  fallback to [ProtocolTCP]");
                return VeLivePlayerProtocolTCP;
        }
    }

    public static VeLivePlayerDef.VeLivePlayerFormat guessUrlFormat(String url) {
        Uri uri = Uri.parse(url);
        String path = uri.getPath();
        if (path == null) {
            return VeLivePlayerFormatFLV;
        } else if (path.endsWith(".sdp")) {
            return VeLivePlayerFormatRTM;
        } else if (path.endsWith(".m3u8")) {
            return VeLivePlayerFormatHLS;
        } else {
            return VeLivePlayerFormatFLV;
        }
    }
}
