// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.config;


import com.byteplus.playerkit.player.playback.ext.IStrategy;

public interface IPreloadConfig extends IStrategy {
    boolean enableStrategy();
}
