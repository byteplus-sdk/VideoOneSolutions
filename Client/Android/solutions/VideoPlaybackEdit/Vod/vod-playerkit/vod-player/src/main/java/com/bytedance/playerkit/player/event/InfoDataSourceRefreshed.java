// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.bytedance.playerkit.player.event;

import com.bytedance.playerkit.player.PlayerEvent;
import com.bytedance.playerkit.utils.event.Event;


public class InfoDataSourceRefreshed extends Event {

    public static final int REFRESHED_TYPE_PLAY_INFO_FETCHED = 1;
    public static final int REFRESHED_TYPE_SUBTITLE = 2;
    public static final int REFRESHED_TYPE_MASK = 3;

    public int mRefreshedType;

    public InfoDataSourceRefreshed() {
        super(PlayerEvent.Info.DATA_SOURCE_REFRESHED);
    }

    public InfoDataSourceRefreshed init(int refreshedType) {
        this.mRefreshedType = refreshedType;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        mRefreshedType = 0;
    }
}
