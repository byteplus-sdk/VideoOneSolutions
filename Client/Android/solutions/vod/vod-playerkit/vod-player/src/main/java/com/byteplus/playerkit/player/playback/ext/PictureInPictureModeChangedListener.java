// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.playback.ext;

import android.content.res.Configuration;

import androidx.annotation.NonNull;

public interface PictureInPictureModeChangedListener {
    void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig);
}
