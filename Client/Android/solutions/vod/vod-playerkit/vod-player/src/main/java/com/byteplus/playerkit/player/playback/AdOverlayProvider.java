// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.playback;

import android.content.Context;
import android.view.View;

/**
 * Bridge that lets a higher-level module (e.g. vod-mini-drama) provide a custom, display-only
 * overlay to be shown on top of in-stream ads by {@link AdsPlaybackController}. This avoids a
 * reverse module dependency from vod-player onto the scene module.
 */
public interface AdOverlayProvider {

    /**
     * A display-only overlay view driven by ad playback callbacks.
     */
    interface AdOverlay {
        View getView();

        void updateProgress(long currentTimeMs, long totalTimeMs);

        void reset();
    }

    AdOverlay createOverlay(Context context);

    /**
     * Optional global provider. When set, {@link AdsPlaybackController} creates and drives a
     * custom ad overlay; when null, no overlay is shown.
     */
    class Holder {
        private static volatile AdOverlayProvider sProvider;

        public static void set(AdOverlayProvider provider) {
            sProvider = provider;
        }

        public static AdOverlayProvider get() {
            return sProvider;
        }
    }
}
