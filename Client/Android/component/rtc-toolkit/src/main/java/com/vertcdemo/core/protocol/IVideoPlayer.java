// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.protocol;

import android.content.Context;
import android.view.View;

import androidx.core.util.Consumer;

public interface IVideoPlayer {

    /**
     * configuration Player
     */
    void startWithConfiguration(Context context, Consumer<String> seiCallback);

    /**
     * Set playback address, parent view
     * @param url stream URL
     * @param container parent class view
     */
    void setPlayerUrl(String url, View container);

    /**
     * update playback scale mode
     * @param scalingMode playback scale mode
     */
    void updatePlayScaleModel(@ScalingMode int scalingMode);

    /**
     * start playing
     */
    void play();

    /**
     * Update the new playback address
     * @param url new play URL
     */
    void replacePlayWithUrl(String url);

    /**
     * stop playback
     */
    void stop();


    /**
     * Whether the player supports SEI function
     * @return BOOL YES supports SEI, NO does not support SEI
     */
    boolean isSupportSEI();

    /**
     * release player resources
     */
    void destroy();
}
