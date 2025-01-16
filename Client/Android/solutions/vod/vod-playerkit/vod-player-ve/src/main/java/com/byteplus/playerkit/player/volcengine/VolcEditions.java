// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.ss.ttvideoengine.TTVideoEngine;

import com.byteplus.playerkit.player.ve.BuildConfig;

public class VolcEditions {
    private static final String PLAYER_EDITION = BuildConfig.TTSDK_PLAYER_EDITION;

    public static final String PLAYER_EDITION_LITE = "lite";
    public static final String PLAYER_EDITION_PREMIUM = "premium";
    public static final String PLAYER_EDITION_STANDARD = "standard";

    public static int engineCoreType() {
        switch (PLAYER_EDITION) {
            case PLAYER_EDITION_PREMIUM:
            case PLAYER_EDITION_STANDARD:
                return TTVideoEngine.PLAYER_TYPE_OWN;
            case PLAYER_EDITION_LITE:
                return TTVideoEngine.PLAYER_TYPE_EXO;
            default:
                throw new IllegalArgumentException("unsupported playerEdition " + PLAYER_EDITION);
        }
    }

    @NonNull
    public static String dumpEngineCoreType(TTVideoEngine engine) {
        String enginePlayerType = "";
        if (engine != null) {
            if (engine.isPlayerType(TTVideoEngine.PLAYER_TYPE_EXO)) {
                enginePlayerType = "exo";
            } else if (engine.isPlayerType(TTVideoEngine.PLAYER_TYPE_OWN)) {
                enginePlayerType = "own " + PLAYER_EDITION;
            } else if (engine.isPlayerType(TTVideoEngine.PLAYER_TYPE_OS)) {
                enginePlayerType = "os";
            }
        }
        return enginePlayerType;
    }

    public static boolean isSupportTextureRender() {
        return engineCoreType() == TTVideoEngine.PLAYER_TYPE_OWN;
    }

    public static boolean isSupportSuperResolution() {
        return TextUtils.equals(PLAYER_EDITION, PLAYER_EDITION_PREMIUM);
    }

    public static boolean isSupportEngineLooper() {
        return engineCoreType() == TTVideoEngine.PLAYER_TYPE_OWN;
    }

    public static boolean isSupportDash() {
        return engineCoreType() == TTVideoEngine.PLAYER_TYPE_OWN;
    }

    public static boolean isSupportMp4SeamLessSwitch() {
        return engineCoreType() == TTVideoEngine.PLAYER_TYPE_OWN;
    }

    public static boolean isSupportHLSSeamLessSwitch() {
        return engineCoreType() == TTVideoEngine.PLAYER_TYPE_OWN;
    }

    public static boolean isSupportStartUpABR() {
        return engineCoreType() == TTVideoEngine.PLAYER_TYPE_OWN;
    }
}
