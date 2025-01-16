// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.event;

import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.event.Event;


public class InfoBufferingStart extends Event {

    public static final int BUFFERING_TYPE_IO = 0;
    public static final int BUFFERING_TYPE_DECODER = 1;

    public static final int BUFFERING_STAGE_BEFORE_FIRST_FRAME = 0;
    public static final int BUFFERING_STAGE_AFTER_FIRST_FRAME = 1;

    public static final int BUFFERING_REASON_DEFAULT = 0;
    public static final int BUFFERING_REASON_SEEK = 1;
    public static final int BUFFERING_REASON_TRACK_CHANGE = 2;
    public int bufferId;

    public int bufferingType;
    public int bufferingStage;
    public int bufferingReason;

    public InfoBufferingStart() {
        super(PlayerEvent.Info.BUFFERING_START);
    }

    public InfoBufferingStart init(int bufferId, int bufferingType, int bufferingStage, int bufferingReason) {
        this.bufferId = bufferId;
        this.bufferingType = bufferingType;
        this.bufferingStage = bufferingStage;
        this.bufferingReason = bufferingReason;
        return this;
    }

    @Override
    public void recycle() {
        super.recycle();
        this.bufferId = 0;
        this.bufferingType = 0;
        this.bufferingStage = 0;
        this.bufferingReason = 0;
    }

    public static String mapBufferingType(int bufferingType) {
        switch (bufferingType) {
            case BUFFERING_TYPE_IO:
                return "io";
            case BUFFERING_TYPE_DECODER:
                return "decoder";
        }
        return null;
    }

    public static String mapBufferingStage(int bufferingStage) {
        switch (bufferingStage) {
            case BUFFERING_STAGE_BEFORE_FIRST_FRAME:
                return "before";
            case BUFFERING_STAGE_AFTER_FIRST_FRAME:
                return "after";
        }
        return null;
    }

    public static String mapBufferingReason(int bufferingReason) {
        switch (bufferingReason) {
            case BUFFERING_REASON_DEFAULT:
                return "default";
            case BUFFERING_REASON_SEEK:
                return "seek";
            case BUFFERING_REASON_TRACK_CHANGE:
                return "track";
        }
        return null;
    }
}
