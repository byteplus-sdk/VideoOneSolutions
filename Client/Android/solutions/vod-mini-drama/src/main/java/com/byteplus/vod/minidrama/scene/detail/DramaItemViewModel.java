// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail;

import androidx.lifecycle.ViewModel;

import com.byteplus.vod.minidrama.scene.data.DramaItem;

public class DramaItemViewModel extends ViewModel {
    public DramaItem dramaItem;

    public void setItem(DramaItem item) {
        dramaItem = item;
    }

    public String getDramaId() {
        return dramaItem.getDramaId();
    }
}
