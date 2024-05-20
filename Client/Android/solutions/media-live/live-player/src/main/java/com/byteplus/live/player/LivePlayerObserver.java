// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player;

import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame;

public interface LivePlayerObserver {
    void onCycleInfoUpdate(LivePlayerCycleInfo info);
    void onCallbackRecordUpdate(String content);
    void onResolutionUpdate(String resolution);
    void onRenderVideoFrame(VeLivePlayer player, VeLivePlayerVideoFrame videoFrame);
}
