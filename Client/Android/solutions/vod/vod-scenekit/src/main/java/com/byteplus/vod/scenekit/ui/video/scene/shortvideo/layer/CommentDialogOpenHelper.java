// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.scene.shortvideo.layer;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

@FunctionalInterface
public interface CommentDialogOpenHelper {
    enum Style {
        Portrait,
        Landscape
    }

    void show(@NonNull FragmentActivity activity, @NonNull String vid, @NonNull Style style);
}
