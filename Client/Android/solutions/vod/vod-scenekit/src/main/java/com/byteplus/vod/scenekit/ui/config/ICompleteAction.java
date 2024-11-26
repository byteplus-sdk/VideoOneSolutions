package com.byteplus.vod.scenekit.ui.config;

import com.byteplus.playerkit.player.config.IStrategy;

public interface ICompleteAction extends IStrategy {
    int LOOP = 0;
    int NEXT = 1;

    int completeAction();
}
