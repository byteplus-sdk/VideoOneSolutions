// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.video.layer;


public class Layers {

    public static final class BackPriority {
        public static final int DIALOG_LAYER_BACK_PRIORITY = 10000;
        private static int sIndex = 0;
        public static final int QUALITY_SELECT_DIALOG_LAYER_BACK_PRIORITY = DIALOG_LAYER_BACK_PRIORITY + (sIndex++);
        public static final int SPEED_SELECT_DIALOG_LAYER_BACK_PRIORITY = DIALOG_LAYER_BACK_PRIORITY + (sIndex++);
        public static final int VOLUME_BRIGHTNESS_DIALOG_BACK_PRIORITY = DIALOG_LAYER_BACK_PRIORITY + (sIndex++);
        public static final int TIME_PROGRESS_DIALOG_LAYER_PRIORITY = DIALOG_LAYER_BACK_PRIORITY + (sIndex++);
        public static final int MORE_DIALOG_LAYER_BACK_PRIORITY = DIALOG_LAYER_BACK_PRIORITY + (sIndex++);
        public static final int PLAYLIST_DIALOG_BACK_PRIORITY = DIALOG_LAYER_BACK_PRIORITY + (sIndex++);
    }

    public static final class VisibilityRequestReason {
        public static final String REQUEST_DISMISS_REASON_DIALOG_SHOW = "request_dismiss_reason_dialog_show";
    }
}
