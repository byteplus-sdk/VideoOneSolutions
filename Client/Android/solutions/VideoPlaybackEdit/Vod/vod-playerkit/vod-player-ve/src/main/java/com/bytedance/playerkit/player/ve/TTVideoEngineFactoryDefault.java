// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.playerkit.player.ve;

import static com.ss.ttvideoengine.ITTVideoEngineInternal.PLAYER_TYPE_OWN;
import static com.ss.ttvideoengine.TTVideoEngineInterface.IMAGE_LAYOUT_TO_FILL;
import static com.ss.ttvideoengine.TTVideoEngineInterface.PLAYER_OPTION_SEGMENT_FORMAT_FLAG;
import static com.ss.ttvideoengine.TTVideoEngineInterface.SEGMENT_FORMAT_FMP4;
import static com.ss.ttvideoengine.TTVideoEngineInterface.SEGMENT_FORMAT_MP4;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.bytedance.playerkit.player.Player;
import com.bytedance.playerkit.player.source.MediaSource;
import com.bytedance.playerkit.player.source.Track;
import com.bytedance.playerkit.utils.L;
import com.ss.ttvideoengine.SubInfoSimpleCallBack;
import com.ss.ttvideoengine.TTVideoEngine;
import com.ss.ttvideoengine.utils.Error;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class TTVideoEngineFactoryDefault implements TTVideoEngineFactory {

    @Override
    public TTVideoEngine create(Context context, MediaSource mediaSource) {
        PlayerConfig playerConfig = PlayerConfig.get(mediaSource);

        final TTVideoEngine player;
        if (playerConfig.enableEngineLooper) {
            Map<String, Object> params = new HashMap<>();
            params.put("enable_looper", true);
            player = new TTVideoEngine(context, PLAYER_TYPE_OWN, params);
        } else {
            player = new TTVideoEngine(context, PLAYER_TYPE_OWN);
        }

        player.setIntOption(TTVideoEngine.PLAYER_OPTION_OUTPUT_LOG, L.ENABLE_LOG ? 1 : 0);
        player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_DATALOADER, 1);
        player.setIntOption(TTVideoEngine.PLAYER_OPTION_USE_VIDEOMODEL_CACHE, 1);
        player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_DEBUG_UI_NOTIFY, 1);

        if (playerConfig.codecStrategyType == PlayerConfig.CODEC_STRATEGY_DISABLE) {
            switch (playerConfig.playerDecoderType) {
                case Player.DECODER_TYPE_HARDWARE:
                    player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_HARDWARE_DECODE, 1);
                    break;
                case Player.DECODER_TYPE_SOFTWARE:
                    player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_HARDWARE_DECODE, 0);
                    break;
            }
            switch (playerConfig.sourceEncodeType) {
                case Track.ENCODER_TYPE_H264:
                    player.setStringOption(TTVideoEngine.PLAYER_OPTION_STRING_SET_VIDEO_CODEC_TYPE, TTVideoEngine.CODEC_TYPE_H264);
                    break;
                case Track.ENCODER_TYPE_H265:
                    player.setStringOption(TTVideoEngine.PLAYER_OPTION_STRING_SET_VIDEO_CODEC_TYPE, TTVideoEngine.CODEC_TYPE_h265);
                    break;
                case Track.ENCODER_TYPE_H266:
                    player.setStringOption(TTVideoEngine.PLAYER_OPTION_STRING_SET_VIDEO_CODEC_TYPE, TTVideoEngine.CODEC_TYPE_h266);
                    break;
            }
        }

        if (playerConfig.enableTextureRender) {
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_USE_TEXTURE_RENDER, 1);
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_IMAGE_LAYOUT, IMAGE_LAYOUT_TO_FILL);
        }

        if (playerConfig.enableHlsSeamlessSwitch) {
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_HLS_SEAMLESS_SWITCH, 1);
        }
        if (playerConfig.enableDash) {
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_DASH, 1);
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_BASH, 1);
        }
        if (playerConfig.enableMP4SeamlessSwitch) {
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_BASH, 1);
            player.setIntOption(PLAYER_OPTION_SEGMENT_FORMAT_FLAG, (1 << SEGMENT_FORMAT_FMP4) | (1 << SEGMENT_FORMAT_MP4));
        }
        player.setIntOption(TTVideoEngine.PLAYER_OPTION_SET_TRACK_VOLUME, playerConfig.enableAudioTrackVolume ? 1 : 0);

        if (playerConfig.enableSeekEnd) {
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_KEEP_FORMAT_THREAD_ALIVE, 1);
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_SEEK_END, 1);
        }

        player.setIntOption(TTVideoEngine.PLAYER_OPTION_POSITION_UPDATE_INTERVAL, 200);

        if (!TextUtils.isEmpty(playerConfig.tag)) {
            player.setTag(playerConfig.tag);
        }
        if (!TextUtils.isEmpty(playerConfig.subTag)) {
            player.setSubTag(playerConfig.subTag);
        }

        if (!TextUtils.isEmpty(mediaSource.getSubtitleAuthToken()) || !mediaSource.getSubtitles().isEmpty()) {
            // Enable or disable subtitle
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_OPEN_SUB, 1);
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_OPEN_SUB_THREAD, 1);
            player.setIntOption(TTVideoEngine.PLAYER_OPTION_ENABLE_OPT_SUB_LOAD_TIME, 1);
        }

        return player;
    }


}
