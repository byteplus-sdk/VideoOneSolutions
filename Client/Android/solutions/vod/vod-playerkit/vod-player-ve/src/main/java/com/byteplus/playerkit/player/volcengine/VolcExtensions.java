// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

public class VolcExtensions {
    public static final String PLAYER_EXTENSIONS = "";

    public static final String PLAYER_EXTENSION_SUPER_RESOLUTION = "super_resolution";
    public static final String PLAYER_EXTENSION_ABR = "abr";
    public static final String PLAYER_EXTENSION_ECDN = "ecdn";

    public static boolean isIntegrate(String extension) {
        return PLAYER_EXTENSIONS.contains(extension);
    }
}
