// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import java.io.Serializable;

public class VolcSuperResolutionConfig implements Serializable {
    public static final String sSuperResolutionBinPath = "bytedance/playerkit/volcplayer/bmf";
    public boolean enableSuperResolutionAbility = true;
    public boolean enableSuperResolutionOnStartup = false;
    public boolean enableAsyncInitSuperResolution = false;
    public boolean enableSuperResolutionMaliGPUOpt = true;
    public int maxTextureWidth = 720;
    public int maxTextureHeight = 1280;
}
