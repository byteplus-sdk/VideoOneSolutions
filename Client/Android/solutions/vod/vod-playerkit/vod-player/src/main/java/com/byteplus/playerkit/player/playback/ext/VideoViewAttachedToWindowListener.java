// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.playback.ext;

import androidx.annotation.NonNull;

import com.byteplus.playerkit.player.playback.VideoView;

public interface VideoViewAttachedToWindowListener {
    void onVideoViewAttachedToWindow(@NonNull VideoView videoView);

    void onVideoViewDetachedFromWindow(@NonNull VideoView videoView);
}
