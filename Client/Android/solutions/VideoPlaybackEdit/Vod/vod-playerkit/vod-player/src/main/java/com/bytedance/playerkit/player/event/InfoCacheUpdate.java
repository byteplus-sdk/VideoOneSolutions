// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent.Info;
import com.bytedance.playerkit.utils.event.Event;

public class InfoCacheUpdate extends Event {

    public long cachedBytes;

    public InfoCacheUpdate() {
        super(Info.CACHE_UPDATE);
    }

    public InfoCacheUpdate init(long cachedBytes) {
        this.cachedBytes = cachedBytes;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        cachedBytes = 0;
    }
}
