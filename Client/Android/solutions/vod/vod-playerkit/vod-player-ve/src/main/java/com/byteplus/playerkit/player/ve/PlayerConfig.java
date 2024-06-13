// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.ve;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.ss.ttvideoengine.source.Source;

import java.io.Serializable;


public class PlayerConfig implements Serializable {
    public static final PlayerConfig DEFAULT = new PlayerConfig();
    public static final String EXTRA_VE_CONFIG = "extra_ve_config";

    @NonNull
    public static PlayerConfig get(MediaSource mediaSource) {
        if (mediaSource == null) return PlayerConfig.DEFAULT;

        PlayerConfig playerConfig = mediaSource.getExtra(PlayerConfig.EXTRA_VE_CONFIG, PlayerConfig.class);
        if (playerConfig == null) {
            return PlayerConfig.DEFAULT;
        }
        return playerConfig;
    }

    public static final int CODEC_STRATEGY_DISABLE = 0;
    public static final int CODEC_STRATEGY_COST_SAVING_FIRST = Source.KEY_COST_SAVING_FIRST;
    public static final int CODEC_STRATEGY_HARDWARE_DECODE_FIRST = Source.KEY_HARDWARE_DECODE_FIRST;

    public int codecStrategyType;
    @Player.DecoderType
    public int playerDecoderType;
    @Track.EncoderType
    public int sourceEncodeType;

    public boolean enableAudioTrackVolume = false;
    public boolean enableTextureRender = true;
    public boolean enableHlsSeamlessSwitch = true;
    public boolean enableMP4SeamlessSwitch = true;
    public boolean enableDash = true;
    public boolean enableEngineLooper = true;
    public boolean enableSeekEnd = true;
    public boolean enableSuperResolutionAbility = true;
    public boolean enableSuperResolution = false;

    public String tag;
    public String subTag;

}
