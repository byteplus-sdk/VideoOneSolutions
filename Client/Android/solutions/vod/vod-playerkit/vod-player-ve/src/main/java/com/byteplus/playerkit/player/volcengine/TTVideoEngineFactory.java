// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import android.content.Context;

import com.byteplus.playerkit.player.source.MediaSource;
import com.ss.ttvideoengine.TTVideoEngine;

public interface TTVideoEngineFactory {

    class Default {

        private static TTVideoEngineFactory sInstance = new TTVideoEngineFactoryDefault();

        public static TTVideoEngineFactory get() {
            return sInstance;
        }

        public static void set(TTVideoEngineFactory instance) {
            sInstance = instance;
        }
    }

    TTVideoEngine create(Context context, MediaSource mediaSource);

    TTVideoEngine setup(Context context, TTVideoEngine ttVideoEngine, MediaSource mediaSource);
}
