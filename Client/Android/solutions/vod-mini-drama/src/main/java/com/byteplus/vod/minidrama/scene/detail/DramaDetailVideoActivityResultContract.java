// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail;

import android.content.Context;
import android.content.Intent;

import androidx.activity.result.contract.ActivityResultContract;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.scene.data.DramaItem;

import java.io.Serializable;
import java.util.List;

public class DramaDetailVideoActivityResultContract extends
        ActivityResultContract<DramaDetailVideoActivityResultContract.Input, DramaDetailVideoActivityResultContract.Output> {
    public static final String EXTRA_INPUT = "extra_input";
    public static final String EXTRA_OUTPUT = "extra_output";
    public static final String EXTRA_DRAMA_ITEM = "extra_drama_item";

    public static class Input implements Serializable {
        public final List<DramaItem> dramaItems;
        public final int currentDramaIndex;
        public final boolean continuesPlayback;
        public final DramaInfo.Orientation orientation;
        @Nullable
        public final String mediaKey;

        public Input(@NonNull List<DramaItem> dramaItems) {
            this(dramaItems, 0, null);
        }

        public Input(@NonNull List<DramaItem> dramaItems, @Nullable String mediaKey) {
            this(dramaItems, 0, mediaKey);
        }

        public Input(@NonNull List<DramaItem> dramaItems,
                     int currentDramaIndex) {
            this(dramaItems, currentDramaIndex, null);
        }

        public Input(@NonNull List<DramaItem> dramaItems,
                     int currentDramaIndex,
                     @Nullable String mediaKey) {
            this.dramaItems = dramaItems;
            this.currentDramaIndex = currentDramaIndex;
            this.mediaKey = mediaKey;
            this.continuesPlayback = (mediaKey != null);
            this.orientation = dramaItems.get(currentDramaIndex).dramaInfo.orientation;
        }
    }

    public static class Output implements Serializable {
        public DramaItem currentDramaItem;
        public final boolean continuesPlayback;

        public Output(DramaItem currentDramaItem, boolean continuesPlayback) {
            this.currentDramaItem = currentDramaItem;
            this.continuesPlayback = continuesPlayback;
        }
    }

    @NonNull
    @Override
    public Intent createIntent(@NonNull Context context, Input input) {
        Intent intent = new Intent(context, DramaDetailVideoActivity.class);
        intent.putExtra(EXTRA_INPUT, input);
        return intent;
    }

    @Override
    @Nullable
    public Output parseResult(int resultCode, @Nullable Intent intent) {
        if (intent == null) return null;
        return (Output) intent.getSerializableExtra(EXTRA_OUTPUT);
    }

}